//
//  SignInViewController.m
//  PointiOSReferenceFileBrowser
//
//  Created by jimboyle on 8/2/13.
//  Copyright (c) 2013 PointIO. All rights reserved.
//

#import "SignInViewController.h"
#import "Common.h"
#import "MBProgressHUD.h"
#import "accessRulesListViewController.h"
#import "storageSitesListViewController.h"


@interface SignInViewController ()

@end

@implementation SignInViewController




- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    if (_hasLoggedIn){
        [_loggedInAsNameLabel setHidden:NO];
        [_loggedInAsNameText setHidden:NO];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [_loggedInAsNameText setText:[defaults valueForKey:@"USERNAME"]];
    }
    else {
        [_loggedInAsNameLabel setHidden:YES];
        [_loggedInAsNameText setHidden:YES];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if([[defaults valueForKey:@"USERNAME"] length] != 0 && [[defaults valueForKey:@"PASSWORD"] length] !=0){
            
            [_usernameTextField setText:[defaults valueForKey:@"USERNAME"]];
            _username = [defaults valueForKey:@"USERNAME"];
            [_usernameTextField setDelegate:self];
            
            [_passwordTextField setText:[defaults valueForKey:@"PASSWORD"]];
            _password = [defaults valueForKey:@"PASSWORD"];
            [_passwordTextField setSecureTextEntry:YES];
            [_passwordTextField setDelegate:self];
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        } else {
            
            [_usernameTextField resignFirstResponder];
            [_passwordTextField resignFirstResponder];
            
            _postString = [Common getAppKey:@"AppKeyPostString"];
            _username = [_usernameTextField text];
            _password = [_passwordTextField text];
            NSLog(@"Inside LoginViewController.signIn EMAIL = %@, PASSWORD = %@",_username,_password);
            _postString = [_postString stringByAppendingFormat:@"&email=%@&password=%@",_username,_password];
            [self performSelectorOnMainThread:@selector(performAuthCall) withObject:nil waitUntilDone:YES];
        }
    }
}

/*
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
                // [_signInButton setAlpha:1];
                // [_signUpButton setAlpha:1];
                // [_demoButton setAlpha:1];
            }];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    } else {
        _postString = [Common getAppKey:@"AppKeyPostString"];
        _username = [_usernameTextField text];
        _password = [_passwordTextField text];
        NSLog(@"Inside LoginViewController.signIn EMAIL = %@, PASSWORD = %@",_username,_password);
        _postString = [_postString stringByAppendingFormat:@"&email=%@&password=%@",_username,_password];
        [self performSelectorOnMainThread:@selector(performAuthCall) withObject:nil waitUntilDone:YES];
    }
}
*/

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
                
                self.navigationItem.title=_username;
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
    [_loggedInAsNameText setHidden:YES];
    [_loggedInAsNameLabel setHidden:YES];
    self.navigationItem.title=@"";
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"The username or the password is incorrect. Please try again."
                                                   delegate:nil
                                          cancelButtonTitle:@"Dismiss"
                                          otherButtonTitles: nil];
    // UIImageView* temp = [[UIImageView alloc] initWithFrame:CGRectMake(2, 0, 280, 154)];
    // temp.image = [UIImage imageNamed:@"passwordUsernameIncorrect.png"];
    // [alert addSubview:temp];
    // [alert setBackgroundColor:[UIColor clearColor]];
    [alert show];
}


@end
