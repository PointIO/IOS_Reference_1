//
//  LoginViewController.m
//  PointiOSReferenceFileBrowser
//
//  Created by jimboyle on 7/6/13.
//  Copyright (c) 2013 PointIO. All rights reserved.
//

#import "LoginViewController.h"
#import "Common.h"
#import "accessRulesListViewController.h"
#import "storageSitesListViewController.h"


#define IS_IPAD (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone)
static NSString *const kPointAPIKey = @"apikey=b022de6e-9bf6-11e2-b014-12313b093415";



@interface LoginViewController ()

@end

@implementation LoginViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    if (IS_IPAD) {
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
    
    self.splitViewController.delegate = nil;
    self.splitViewController.delegate = self;
    
    [_usernameTextField setDelegate:self];
    _usernameTextField.borderStyle = UITextBorderStyleRoundedRect;
    
    [_passwordTextField setSecureTextEntry:YES];
    [_passwordTextField setDelegate:self];
    _passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
    
    if (_hasLoggedIn){
        [_signOutButton setHidden:NO];
        [_loggedInAsNameLabel setHidden:NO];
        [_loggedInAsNameText setHidden:NO];
        [_demoButton setHidden:YES];
        [_signInButton setHidden:YES];
        [_signUpButton setHidden:YES];
        [_usernameTextField setHidden:YES];
        [_passwordTextField setHidden:YES];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [_loggedInAsNameText setText:[defaults valueForKey:@"USERNAME"]];
    }
    else {
        [_signOutButton setHidden:YES];
        [_loggedInAsNameLabel setHidden:YES];
        [_loggedInAsNameText setHidden:YES];
        [_demoButton setHidden:NO];
        [_signInButton setHidden:NO];
        [_signUpButton setHidden:NO];
        [_usernameTextField setHidden:NO];
        [_passwordTextField setHidden:NO];
 
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if([[defaults valueForKey:@"USERNAME"] length] != 0 && [[defaults valueForKey:@"PASSWORD"] length] !=0){
            [_usernameTextField setText:[defaults valueForKey:@"USERNAME"]];
            [_passwordTextField setText:[defaults valueForKey:@"PASSWORD"]];
            _username = [defaults valueForKey:@"USERNAME"];
            _password = [defaults valueForKey:@"PASSWORD"];
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
                [self signIn];
            }
        }
    }
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
    }
    else{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        if(![[_usernameTextField text] isEqualToString:@""] || ![[_passwordTextField text] isEqualToString:@""]){
            [UIView animateWithDuration:0.3 animations:^(void) {
                [_usernameTextField setAlpha:0];
                [_passwordTextField setAlpha:0];
                [_signInButton setAlpha:0];
                [_signUpButton setAlpha:0];
                [_demoButton setAlpha:0];
            }];
        }
        [self signIn];
        [_usernameTextField resignFirstResponder];
        [_passwordTextField resignFirstResponder];
    }
}

- (IBAction)screenPressed {
    [_usernameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
}

- (IBAction)signOutPressed {
    [self signOut];
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
    }
}

- (IBAction)demoPressed {
    [_usernameTextField setText:@"demo@point.io"];
    [_passwordTextField setText:@"demo"];
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
                [_demoButton setAlpha:1];
            }];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    } else {
        _postString = kPointAPIKey;
        _username = [_usernameTextField text];
        _password = [_passwordTextField text];
        NSLog(@"Inside LoginViewController.signIn EMAIL = %@, PASSWORD = %@",_username,_password);
        _postString = [_postString stringByAppendingFormat:@"&email=%@&password=%@",_username,_password];
        [self performSelectorOnMainThread:@selector(performAuthCall) withObject:nil waitUntilDone:YES];
    }
}


- (void) signOut{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [_signOutButton setHidden:YES];
    [_loggedInAsNameText setHidden:YES];
    [_loggedInAsNameLabel setHidden:YES];
    [_usernameTextField setText:@""];
    [_passwordTextField setText:@""];
    [_usernameTextField setHidden:NO];
    [_passwordTextField setHidden:NO];
    [_signInButton setHidden:NO];
    [_signUpButton setHidden:NO];
    [_demoButton setHidden:NO];
    [UIView animateWithDuration:0.3 animations:^(void) {
        [_usernameTextField setAlpha:1];
        [_passwordTextField setAlpha:1];
        [_signInButton setAlpha:1];
        [_signUpButton setAlpha:1];
        [_demoButton setAlpha:1];
    }];
    _sessionKey = nil;
    _JSONArrayAuth = nil;
    _hasLoggedIn = NO;
    _postString = kPointAPIKey;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:@"USERNAME"];
    [defaults setObject:nil forKey:@"PASSWORD"];
    [defaults synchronize];
    
}



- (void) performAuthCall{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://api.point.io/api/v2/auth.json"]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[_postString dataUsingEncoding:NSUTF8StringEncoding]];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    // dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
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
        }
        else {
            NSURLResponse* urlResponseList;
            NSError* requestErrorList;
            NSData* response = [NSURLConnection sendSynchronousRequest:request
                                                     returningResponse:&urlResponseList
                                                                 error:&requestErrorList];
            if(!response){
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Request response is nil"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Dismiss"
                                                      otherButtonTitles: nil];
                [alert show];
            } else {
                _JSONArrayAuth = [NSJSONSerialization JSONObjectWithData:response
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:nil];
                NSString* errorFlagString = [_JSONArrayAuth valueForKey:@"ERROR"];
                int errorFlag = [errorFlagString integerValue];
                if(errorFlag == 1){
                    [self performSelectorOnMainThread:@selector(displayError) withObject:nil waitUntilDone:YES];
                } else {
                    _hasLoggedIn = YES;
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:_username forKey:@"USERNAME"];
                    [defaults setObject:_password forKey:@"PASSWORD"];
                    [defaults synchronize];
                    NSDictionary* result = [_JSONArrayAuth valueForKey:@"RESULT"];
                    _sessionKey = [result valueForKey:@"SESSIONKEY"];
                    NSLog(@"SESSION KEY = %@",_sessionKey);
                    _loggedInAsNameText.text = _username;
                    
                    [_loggedInAsNameText setHidden:NO];
                    [_loggedInAsNameLabel setHidden:NO];
                    [_signOutButton setHidden:NO];
                    
                    // send Session Key to Relevant View Controllers
                    UITabBarController* mainController = (UITabBarController*)  self.tabBarController;
                    NSArray *navControllersArray = [mainController viewControllers];
                    UINavigationController *rootNavController = [navControllersArray objectAtIndex:0];
                    NSArray *viewControllersArray = rootNavController.viewControllers;
                    accessRulesListViewController *aRLTVC = [viewControllersArray objectAtIndex:0];
                    aRLTVC.sessionKey = _sessionKey;
                    
                    // send Session Key to Relevant View Controllers
                    UINavigationController *navController2 = [navControllersArray objectAtIndex:1];
                    NSArray *viewControllersArray2 = navController2.viewControllers;
                    storageSitesListViewController *sSLVC = [viewControllersArray2 objectAtIndex:0];
                    sSLVC.sessionKey = _sessionKey;
                }
            }
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            // dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            // });
        }
    // });
}

- (void) displayError{    
    _hasLoggedIn = NO;
    [_usernameTextField setText:@""];
    [_passwordTextField setText:@""];
    [_usernameTextField setHidden:NO];
    [_passwordTextField setHidden:NO];
    [_signInButton setHidden:NO];
    [_signUpButton setHidden:NO];
    [_demoButton setHidden:NO];
    [_signOutButton setHidden:YES];
    [_loggedInAsNameText setHidden:YES];
    [_loggedInAsNameLabel setHidden:YES];
    
    [UIView animateWithDuration:0.3 animations:^(void) {
        [_usernameTextField setAlpha:1];
        [_passwordTextField setAlpha:1];
        [_signInButton setAlpha:1];
        [_signUpButton setAlpha:1];
        [_demoButton setAlpha:1];
    }];

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
}


 
- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void) viewDidAppear:(BOOL)animated{
    if(self.splitViewController){
        self.splitViewController.delegate = nil;
        self.splitViewController.delegate = self;
    }
    
    [self screenPressed];
    /*
    if(_shouldSignIn){
        [_usernameTextField setText:_username];
        [_passwordTextField setText:_password];
        [self signInPressed];
        _shouldSignIn = NO;
    }
    */
}

- (void) viewWillAppear:(BOOL)animated{
    /*
    if(_successfulLogin){
        [_signOutButton setHidden:NO];
        [_signInButton setHidden:YES];
        [_signUpButton setHidden:YES];
        [_demoButton setHidden:YES];
        [_usernameTextField setHidden:YES];
        [_passwordTextField setHidden:YES];
    }
    */
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"goToShares"]){
        accessRulesListViewController * ctvc = [segue destinationViewController];
        // [ctvc setJSONSharedFoldersArray:_JSONArrayList];
        [ctvc setSessionKey:_sessionKey];
    }
    else if([[segue identifier] isEqualToString:@"goToDocView"]){
        // docViewerViewControlleriPad* dvvc = [segue destinationViewController];
        // [dvvc setSessionKey:_sessionKey];
        // [dvvc setJSONArrayList:_JSONArrayList];
    }
    else if([[segue identifier] isEqualToString:@"goToSignup"]){
        signupViewController* svc = [segue destinationViewController];
        [svc setSessionKey:_sessionKey];
    }
}

- (void) viewWillDisappear:(BOOL)animated{
    
}



@end
