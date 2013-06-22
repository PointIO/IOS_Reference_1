#import "ViewController.h"
#import "Common.h"
#import "SettingsViewController.h"


#define IS_IPAD (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone)


@interface ViewController ()

@end

@implementation ViewController

@synthesize usernameTextField = _usernameTextField;
@synthesize passwordTextField = _passwordTextField;
@synthesize signInButton = _signInButton;
@synthesize signUpButton = _signUpButton;
@synthesize signOutButton = _signOutButton;
@synthesize goBackButton = _goBackButton;

// REST API
@synthesize username = _username;
@synthesize password = _password;
@synthesize sessionKey = _sessionKey;
@synthesize postString = _postString;
@synthesize JSONArrayAuth = _JSONArrayAuth;
@synthesize JSONArrayList = _JSONArrayList;
@synthesize successfulLogin = _successfulLogin;
@synthesize appDel = _appDel;
@synthesize shouldSignIn = _shouldSignIn;


UIImageView* imgView;

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    if (IS_IPAD) {
    // if ( [(NSString*)[UIDevice currentDevice].model isEqualToString:@"iPad"] ) {
        //        return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
        return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
    } else {
        if(toInterfaceOrientation == UIInterfaceOrientationPortrait){
            return YES;
        } else {
            return NO;
        }
    }
}

- (BOOL) splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _successfulLogin = NO;
    self.splitViewController.delegate = nil;
    self.splitViewController.delegate = self;
    
    [_usernameTextField setDelegate:self];
    _usernameTextField.borderStyle = UITextBorderStyleRoundedRect;

    [_passwordTextField setSecureTextEntry:YES];
    [_passwordTextField setDelegate:self];
    _passwordTextField.borderStyle = UITextBorderStyleRoundedRect;

    [_signOutButton setHidden:YES];
    [_goBackButton setHidden:YES];
    // self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.10980392156863f green:0.37254901960784f blue:0.6078431372549f alpha:1];
    // self.navigationController.toolbar.tintColor = [UIColor colorWithRed:0.10980392156863f green:0.37254901960784f blue:0.6078431372549f alpha:1];

    UISwipeGestureRecognizer* swipedUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(screenPressed)];
    [swipedUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:swipedUp];
    
    _appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _postString = @"apikey=b022de6e-9bf6-11e2-b014-12313b093415";
    if([[defaults valueForKey:@"USERNAME"] length] != 0 && [[defaults valueForKey:@"PASSWORD"] length] !=0){
        [_usernameTextField setText:[defaults valueForKey:@"USERNAME"]];
        [_passwordTextField setText:[defaults valueForKey:@"PASSWORD"]];
        _username = [defaults valueForKey:@"USERNAME"];
        _password = [defaults valueForKey:@"PASSWORD"];
        if(![Common isConnectedToInternet]){
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
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
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


- (IBAction)signInPressed {
    if(![Common isConnectedToInternet]){
        UIAlertView* err = [[UIAlertView alloc] initWithTitle:@"Error"
                                                      message:@"Looks like there is no internet connection, please check the settings"
                                                     delegate:nil
                                            cancelButtonTitle:@"Dismiss"
                                            otherButtonTitles:nil];
        UIImageView* temp = [[UIImageView alloc] initWithFrame:CGRectMake(2, 0, 280, 174)];
        temp.image = [UIImage imageNamed:@"noInternetConnection.png"];
        [err addSubview:temp];
        [err setBackgroundColor:[UIColor clearColor]];
        [err show];
    } else {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    if(![[_usernameTextField text] isEqualToString:@""] || ![[_passwordTextField text] isEqualToString:@""]){
        [UIView animateWithDuration:0.3 animations:^(void) {
            [_usernameTextField setAlpha:0];
            [_passwordTextField setAlpha:0];
            [_signInButton setAlpha:0];
            [_signUpButton setAlpha:0];
        }];
    }
    [self signIn];
   }
}

- (IBAction)screenPressed {
    [_usernameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
}

- (IBAction)signOutPressed {
    [self signOut];
}

- (IBAction)goBackPressed {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if(![Common isConnectedToInternet]){
            UIAlertView* err = [[UIAlertView alloc] initWithTitle:@"Error"
                                                          message:@"Looks like there is no internet connection, please check the settings"
                                                         delegate:nil
                                                cancelButtonTitle:@"Dismiss"
                                                otherButtonTitles:nil];
            UIImageView* temp = [[UIImageView alloc] initWithFrame:CGRectMake(2, 0, 280, 174)];
            temp.image = [UIImage imageNamed:@"noInternetConnection.png"];
            [err addSubview:temp];
            [err setBackgroundColor:[UIColor clearColor]];
            [err show];
        } else {
            
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (IS_IPAD) {
            // if ( [(NSString*)[UIDevice currentDevice].model isEqualToString:@"iPad"] ) {
                 [self performSegueWithIdentifier:@"goToDocView" sender:self];
            } else {
                // [self performSegueWithIdentifier:@"goToConnections" sender:self];
                [self performSegueWithIdentifier:@"goToShares" sender:self];
            }
        });
    });
}

- (IBAction)signUpPressed {
    if(![Common isConnectedToInternet]){
        UIAlertView* err = [[UIAlertView alloc] initWithTitle:@"Error"
                                                      message:@"Looks like there is no internet connection, please check the settings"
                                                     delegate:nil
                                            cancelButtonTitle:@"Dismiss"
                                            otherButtonTitles:nil];
        UIImageView* temp = [[UIImageView alloc] initWithFrame:CGRectMake(2, 0, 280, 174)];
        temp.image = [UIImage imageNamed:@"noInternetConnection"];
        [err addSubview:temp];
        [err setBackgroundColor:[UIColor clearColor]];
        [err show];
    } else {
        [self performSegueWithIdentifier:@"goToSignup" sender:self];
        NSLog(@"kik");
    }
}

- (void) signIn{ 
    if([[_usernameTextField text] isEqualToString:@""] || [[_passwordTextField text] isEqualToString:@""]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"You haven't entered any username/password"
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles: nil];
        UIImageView* temp = [[UIImageView alloc] initWithFrame:CGRectMake(2, 0, 280, 154)];
        temp.image = [UIImage imageNamed:@"usernamePasswordError.png"];
        [alert addSubview:temp];
        [alert setBackgroundColor:[UIColor clearColor]];
        [alert show];
        if(![[_usernameTextField text] isEqualToString:@""] || ![[_passwordTextField text] isEqualToString:@""]){
        [UIView animateWithDuration:0.3 animations:^(void) {
            [_usernameTextField setText:@""];
            [_passwordTextField setText:@""];
            [_usernameTextField setAlpha:1];
            [_passwordTextField setAlpha:1];
            [_signInButton setAlpha:1];
            [_signUpButton setAlpha:1];
        }];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    } else {
        _postString = @"apikey=b022de6e-9bf6-11e2-b014-12313b093415";
        _username = [_usernameTextField text];
        _password = [_passwordTextField text];
        NSLog(@"IN MAIN VIEW, EMAIL = %@, PASSWORD = %@",_username,_password);
        _postString = [_postString stringByAppendingFormat:@"&email=%@&password=%@",_username,_password];
        [self performSelectorOnMainThread:@selector(performAuthCall) withObject:nil waitUntilDone:YES];
    }
}

- (void) signOut{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [_signOutButton setHidden:YES];
    [_goBackButton setHidden:YES];
    [_usernameTextField setText:@""];
    [_passwordTextField setText:@""];
    [_usernameTextField setHidden:NO];
    [_passwordTextField setHidden:NO];
    [_signInButton setHidden:NO];
    [_signUpButton setHidden:NO];
    [UIView animateWithDuration:0.3 animations:^(void) {
        [_usernameTextField setAlpha:1];
        [_passwordTextField setAlpha:1];
        [_signInButton setAlpha:1];
        [_signUpButton setAlpha:1];
    }];
    _sessionKey = nil;
    _JSONArrayAuth = nil;
    _JSONArrayList = nil;
    _successfulLogin = NO;
    _postString = @"apikey=b022de6e-9bf6-11e2-b014-12313b093415";
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    _appDel.enabledConnections = nil;
    _appDel.sessionKey = nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:@"USERNAME"];
    [defaults setObject:nil forKey:@"PASSWORD"];
    [defaults setObject:nil forKey:@"ENABLEDCONNECTIONS"];
    [defaults setObject:nil forKey:@"NAMETYPES"];
    [defaults setObject:nil forKey:@"ENABLEDTYPES"];
    [defaults synchronize];

}



- (void) performAuthCall{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://api.point.io/api/v2/auth.json"]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[_postString dataUsingEncoding:NSUTF8StringEncoding]];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if(![Common isConnectedToInternet]){
            UIAlertView* err = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Looks like there is no internet connection, please check the settings" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            UIImageView* temp = [[UIImageView alloc] initWithFrame:CGRectMake(2, 0, 280, 174)];
            temp.image = [UIImage imageNamed:@"noInternetConnection.png"];
            [err addSubview:temp];
            [err setBackgroundColor:[UIColor clearColor]];
            [err show];
        } else {
            NSURLResponse* urlResponseList;
            NSError* requestErrorList;
            NSData* response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponseList error:&requestErrorList];
            if(!response){
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Request response is nil" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                [alert show];
            } else {
        _JSONArrayAuth = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
        NSString* errorFlagString = [_JSONArrayAuth valueForKey:@"ERROR"];
        int errorFlag = [errorFlagString integerValue];
        if(errorFlag == 1){
            [self performSelectorOnMainThread:@selector(displayError) withObject:nil waitUntilDone:YES];
        } else {
            _successfulLogin = YES;
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:_username forKey:@"USERNAME"];
            [defaults setObject:_password forKey:@"PASSWORD"];
            [defaults synchronize];
            NSDictionary* result = [_JSONArrayAuth valueForKey:@"RESULT"];
            _sessionKey = [result valueForKey:@"SESSIONKEY"];
            _appDel.sessionKey = _sessionKey;
            NSLog(@"SESSION KEY = %@",_sessionKey);
            [self performSelectorOnMainThread:@selector(performListCall) withObject:nil waitUntilDone:YES];
            
            }
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if(_JSONArrayAuth != NULL){
            [self goToConnectionsView];
            }
        });
        }
    });
}

- (void) displayError{
    _successfulLogin = NO;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"The password or the username is incorrect. Please try again."
                                                   delegate:nil
                                          cancelButtonTitle:@"Dismiss"
                                          otherButtonTitles: nil];
    UIImageView* temp = [[UIImageView alloc] initWithFrame:CGRectMake(2, 0, 280, 154)];
    temp.image = [UIImage imageNamed:@"passwordUsernameIncorrect.png"];
    [alert addSubview:temp];
    [alert setBackgroundColor:[UIColor clearColor]];
    [alert show];
    [_usernameTextField setText:@""];
    [_passwordTextField setText:@""];
    [_usernameTextField setHidden:NO];
    [_passwordTextField setHidden:NO];
    [_signInButton setHidden:NO];
    [_signUpButton setHidden:NO];
    [UIView animateWithDuration:0.3 animations:^(void) {
        [_usernameTextField setAlpha:1];
        [_passwordTextField setAlpha:1];
        [_signInButton setAlpha:1];
        [_signUpButton setAlpha:1];
    }];
}

- (void) goToConnectionsView{
    if([[_JSONArrayAuth valueForKey:@"ERROR"] integerValue] == 0){
        [TestFlight passCheckpoint:@"User logged in"];
        _successfulLogin = YES;
        if (IS_IPAD) {
        // if ([(NSString*)[UIDevice currentDevice].model isEqualToString:@"iPad"] ) {
            [self performSegueWithIdentifier:@"goToDocView" sender:self];
        } else {
            // [self performSegueWithIdentifier:@"goToConnections" sender:self];
            [self performSegueWithIdentifier:@"goToShares" sender:self];
        }
    } else {
        _successfulLogin = NO;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (void) performListCall{
    NSURLResponse* urlResponseList;
    NSError* requestErrorList;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://api.point.io/api/v2/storagesites/list.json"]];
    [request setHTTPMethod:@"GET"];
    [request addValue:_sessionKey forHTTPHeaderField:@"Authorization"];
    NSData* response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponseList error:&requestErrorList];
    if(!response){
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Request response is nil" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
    } else {
    _JSONArrayList = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
    }
}


- (void)viewDidUnload {
    [self setGoBackButton:nil];
    [super viewDidUnload];
}

- (void) viewDidAppear:(BOOL)animated{
    if(self.splitViewController){
        self.splitViewController.delegate = nil;
        self.splitViewController.delegate = self;
    }
    // [self.navigationController setToolbarHidden:NO animated:YES];
    // [self.navigationItem setHidesBackButton:YES];
    [self screenPressed];
    if(_shouldSignIn){
        [_usernameTextField setText:_username];
        [_passwordTextField setText:_password];
        [self signInPressed];
        _shouldSignIn = NO;
    }
    
}

- (void) viewWillAppear:(BOOL)animated{
    if(_successfulLogin){
        [_signOutButton setHidden:NO];
        // [_goBackButton setHidden:NO];
        [_signInButton setHidden:YES];
        [_signUpButton setHidden:YES];
        [_usernameTextField setHidden:YES];
        [_passwordTextField setHidden:YES];
    }
    /*
    if(!imgView){
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        imgView.image = [UIImage imageNamed:@"barImageWithLogo.png"];
        [self.navigationController.navigationBar addSubview:imgView];
    }
    
    imgView.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^(void) {
        imgView.alpha = 1;
    }];
    */
}

- (void) viewWillDisappear:(BOOL)animated{
    /*
    [UIView animateWithDuration:0.25 animations:^(void) {
        imgView.alpha = 0;
    }];
    imgView = nil;
    */
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"goToShares"]){
        shareListViewController * ctvc = [segue destinationViewController];
        [ctvc setJSONSharedFoldersArray:_JSONArrayList];
        [ctvc setSessionKey:_sessionKey];
    }
    else if([[segue identifier] isEqualToString:@"manageConnections"]){
        connectionsManagerViewController *cmvc = [segue destinationViewController];
        [cmvc setJSONArrayList:_JSONArrayList];
        // [cmvc setStorageIDs:_storageIDs];
        [cmvc setSessionKey:_sessionKey];
    }
    else if([[segue identifier] isEqualToString:@"goToConnections"]){
        connectionsTableViewController* ctvc = [segue destinationViewController];
        [ctvc setJSONArrayList:_JSONArrayList];
        [ctvc setSessionKey:_sessionKey];
    }
    else if([[segue identifier] isEqualToString:@"goToDocView"]){
        docViewerViewControlleriPad* dvvc = [segue destinationViewController];
        [dvvc setSessionKey:_sessionKey];
        [dvvc setJSONArrayList:_JSONArrayList];
    }
    else if([[segue identifier] isEqualToString:@"goToSignup"]){
        signupViewController* svc = [segue destinationViewController];
        [svc setSessionKey:_sessionKey];
    }
    else if([[segue identifier] isEqualToString:@"goToSettings"]){
        SettingsViewController* svc2 = [segue destinationViewController];
        // [svc2 setSessionKey:_sessionKey];
    }

}


@end
