#import "storageViewController.h"

@interface storageViewController ()

@end

@implementation storageViewController

@synthesize text = _text;
@synthesize textLabel = _textLabel;
@synthesize usernameTextField = _usernameTextField;
@synthesize passwordTextField = _passwordTextField;
@synthesize signingActivityIndicator = _signingActivityIndicator;
@synthesize signingInLabel = _signingInLabel;
@synthesize signInButton = _signInButton;
@synthesize signUpButton = _signUpButton;
@synthesize appDel = _appDel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        	
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [_textLabel setText:_text];
    [_passwordTextField setSecureTextEntry:YES];
    [_usernameTextField setDelegate:self];
    [_passwordTextField setDelegate:self];
    [_signingInLabel setHidden:YES];
    [_signingActivityIndicator setHidden:YES];
    _appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signInPressed {
    if(![self isConnectedToInternet]){
        UIAlertView* err = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Looks like there is no internet connection, please check the settings" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        UIImageView* temp = [[UIImageView alloc] initWithFrame:CGRectMake(2, 0, 280, 174)];
        temp.image = [UIImage imageNamed:@"noInternetConnection.png"];
        [err addSubview:temp];
        [err setBackgroundColor:[UIColor clearColor]];
        [err show];
    } else {
        [self signIn];
    }
}

- (IBAction)screenPressed {
    [_usernameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    if(textField == _usernameTextField){
        [_usernameTextField resignFirstResponder];
        [_passwordTextField becomeFirstResponder];
    }
    if(textField == _passwordTextField){
        [_passwordTextField resignFirstResponder];
        [self signInPressed];
    }
    return YES;
}

- (void) signIn{
    if([[_usernameTextField text] isEqualToString:@""] || [[_passwordTextField text] isEqualToString:@""]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You haven't entered any username/password" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
    } else {
        if([[_usernameTextField text] isEqualToString:@"user"] && [[_passwordTextField text] isEqualToString:@"password"]){
            self.signingInLabel.alpha = 0;
            self.signingActivityIndicator.alpha = 0;
            [UIView animateWithDuration:0.75 animations:^(void) {
                self.signingInLabel.alpha = 1;
                self.signingActivityIndicator.alpha = 1;
                [_usernameTextField setHidden:YES];
                [_passwordTextField setHidden:YES];
                [_signInButton setHidden:YES];
                [_signUpButton setHidden:YES];
                [_signingActivityIndicator setHidden:NO];
                [_signingInLabel setHidden:NO];
            }];
            
            [_signingActivityIndicator startAnimating];
            NSArray* words = [_text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString* storage = [words componentsJoinedByString:@""];
            storage = [storage lowercaseString];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            [self performSelector:@selector(timerFinished) withObject:nil afterDelay:2.0];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The password or the username is incorrect. Please try again." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
            [alert show];
            [_usernameTextField setText:@""];
            [_passwordTextField setText:@""];
        }
    }
}

- (void) timerFinished{
    NSString* message = [NSString stringWithFormat:@"You've logged into %@",_text];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Success" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles: @"Dismiss", nil];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    alert.tag = 0;
    alert.delegate = self;
    [alert show];
    [TestFlight passCheckpoint:@"User added a storage service"];
    _appDel.hasLoggedIn = YES;
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 0) {
    if (buttonIndex == 0){
        [[self navigationController] popViewControllerAnimated:YES];
    }
    }
}



- (IBAction)signUp {
    [self performSegueWithIdentifier:@"goToSignup" sender:nil];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"goToSignup"]){
        storageSignupViewController *ssvc = [segue destinationViewController];
        [ssvc setStorageName:_text];
    }
}

- (BOOL) isConnectedToInternet{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

@end
