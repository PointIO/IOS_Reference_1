//
//  signupViewController.m
//  point.io
//
//  Created by Constantin Lungu on 4/16/13.
//  Copyright (c) 2013 FusionWorks. All rights reserved.
//

#import "signupViewController.h"
// #import "LoginViewController.h"

@interface signupViewController ()

@end

@implementation signupViewController

static NSString *const kPointAPIKey = @"b022de6e-9bf6-11e2-b014-12313b093415";
static NSString *const kPointAPISecret = @"NX6KLn8nQWy1mz0QI8KlNquUqEArkpqmyv5ic7Vtee2vRWGONROnqSEMSHGmYtp";

@synthesize partnerSession = _partnerSession;
@synthesize emailTextField = _emailTextField;
@synthesize firstNameTextField = _firstNameTextField;
@synthesize lastNameTextField = _lastNameTextField;
@synthesize sessionKey = _sessionKey;
@synthesize username = _username;
@synthesize password = _password;
@synthesize passwordsDontMatchLabel = _passwordsDontMatchLabel;
@synthesize passwordTextField = _passwordTextField;
@synthesize reEnterPasswordTextField = _reEnterPasswordTextField;
@synthesize submitButton = _submitButton;

NSArray* temp;
UIImageView* imgView;
UIImageView* imgView2;

BOOL passwordsDontMatch;

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    if ( [(NSString*)[UIDevice currentDevice].model isEqualToString:@"iPad"] ) {
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
    return NO;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(_splitViewController){
        _splitViewController.delegate = nil;
        _splitViewController.delegate = self;
    }
    _emailTextField.delegate = self;
    _firstNameTextField.delegate = self;
    _lastNameTextField.delegate = self;
    _passwordTextField.delegate = self;
    _reEnterPasswordTextField.delegate = self;
    _passwordsDontMatchLabel.hidden = YES;
}

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationItem.hidesBackButton = YES;
    [UIView animateWithDuration:0.25 animations:^(void) {
        imgView.alpha = 0;
        imgView2.alpha = 0;
    }];
    imgView = nil;
    imgView2 = nil;
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationItem.hidesBackButton = YES;
    if(!imgView){
    imgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    imgView2.image = [UIImage imageNamed:@"barImageWithLogoCentered.png"];
    [self.navigationController.navigationBar addSubview:imgView2];
    imgView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 7, 51, 29)];
    imgView.image = [UIImage imageNamed:@"backButton.png"];
    [self.navigationController.navigationBar addSubview:imgView];
    }
    imgView2.alpha = 0;
    imgView.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^(void) {
        imgView2.alpha = 1;
        imgView.alpha = 1;
    }];
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationItem.hidesBackButton = NO;
    [self.navigationController.navigationBar addSubview:imgView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) getPartnerSession{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        NSDictionary* params = @{
                                 @"email":@"alex@valexconsulting.com",
                                 @"password":@"Valex123",
                                 @"apikey":@"b022de6e-9bf6-11e2-b014-12313b093415"
                                };
        

        /*
        @"email":@"demo@point.io",
        @"password":@"demo",
        @"apikey":kPointAPIKey
        */
        
        NSMutableArray* pairs = [[NSMutableArray alloc] initWithCapacity:0];
        for(NSString* key in params){
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, params[key]]];
        }
        NSString* requestParams = [pairs componentsJoinedByString:@"&"];
        
        NSURLResponse* urlResponseList;
        NSError* requestErrorList;
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:@"https://api.point.io/api/v2/users/preauth.json"]];
        [request setHTTPMethod:@"POST"];
        NSData* payload = [requestParams dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:payload];
        NSData* response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponseList error:&requestErrorList];
        if(!response){
            UIAlertView* alert = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:@"Request response is nil"
                                  delegate:nil
                                  cancelButtonTitle:@"Dismiss"
                                  otherButtonTitles: nil];
            [alert show];
        }
        else {
            NSArray* temp = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
            _partnerSession = [temp valueForKey:@"PARTNERKEY"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self createUser];
            });
        }
    });

}

- (void)viewDidUnload {
    [self setPasswordTextField:nil];
    [self setReEnterPasswordTextField:nil];
    [self setPasswordsDontMatchLabel:nil];
    [self setSubmitButton:nil];
    [super viewDidUnload];
}

- (IBAction)signUpPressed {
    if([[_firstNameTextField text] isEqualToString:@""]
       || [[_lastNameTextField text] isEqualToString:@""]
       || [[_emailTextField text] isEqualToString:@""]
       || [[_passwordTextField text] isEqualToString:@""]
       || [[_reEnterPasswordTextField text] isEqualToString:@""]){
        UIAlertView* alert = [[UIAlertView alloc]
                              initWithTitle:@"Error"
                              message:@"Entered data is not valid. No blank fields allowed"
                              delegate:nil
                              cancelButtonTitle:@"Dismiss"
                              otherButtonTitles: nil];
        UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 282, 133)];
        [imgView setImage:[UIImage imageNamed:@"enteredDataIsNotValid.png"]];
        [alert addSubview:imgView];
        [alert show];
    } else {
        [self getPartnerSession];
    }
}

- (IBAction)screenPressed {
    [_firstNameTextField resignFirstResponder];
    [_lastNameTextField resignFirstResponder];
    [_emailTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    [_reEnterPasswordTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField == _emailTextField){
        [_emailTextField resignFirstResponder];
        [_firstNameTextField becomeFirstResponder];
    }
    if(textField == _firstNameTextField){
        [_firstNameTextField resignFirstResponder];
        [_lastNameTextField becomeFirstResponder];
    }
    if(textField == _lastNameTextField){
        [_lastNameTextField resignFirstResponder];
        [_passwordTextField becomeFirstResponder];
    }
    if(textField == _passwordTextField){
        [_passwordTextField resignFirstResponder];
        [_reEnterPasswordTextField becomeFirstResponder];
    }
    if(textField == _reEnterPasswordTextField){
        [_reEnterPasswordTextField resignFirstResponder];
        if([[_passwordTextField text] isEqualToString:[_reEnterPasswordTextField text]]){
        [self signUpPressed];
        }
    }
    return YES;
}

-(void) textFieldDidBeginEditing:(UITextField *)textField{
    if(textField == _reEnterPasswordTextField && ![[_passwordTextField text] isEqualToString:@""]){
        if(![[_passwordTextField text] isEqualToString:[_reEnterPasswordTextField text]]){
            _passwordsDontMatchLabel.hidden = NO;
            _submitButton.alpha = 0.6;
            _submitButton.enabled = NO;
        }
        else {
            _passwordsDontMatchLabel.hidden = YES;
            _submitButton.alpha = 1;
            _submitButton.enabled = YES;
        }
    }
    if(textField == _passwordTextField && ![[_reEnterPasswordTextField text] isEqualToString:@""]){
        if(![[_passwordTextField text] isEqualToString:[_reEnterPasswordTextField text]]){
            _passwordsDontMatchLabel.hidden = NO;
            _submitButton.alpha = 0.6;
            _submitButton.enabled = NO;
        }
        else {
            _passwordsDontMatchLabel.hidden = YES;
            _submitButton.alpha = 1;
            _submitButton.enabled = YES;
        }
    }
}

- (void) textFieldDidEndEditing:(UITextField *)textField{
    if(textField == _reEnterPasswordTextField && ![[_passwordTextField text] isEqualToString:@""]){
        if(![[_passwordTextField text] isEqualToString:[_reEnterPasswordTextField text]]){
            _passwordsDontMatchLabel.hidden = NO;
            _submitButton.alpha = 0.6;
            _submitButton.enabled = NO;
        }
        else {
            _passwordsDontMatchLabel.hidden = YES;
            _submitButton.alpha = 1;
            _submitButton.enabled = YES;
        }
    }
    if(textField == _passwordTextField && ![[_reEnterPasswordTextField text] isEqualToString:@""]){
        if(![[_passwordTextField text] isEqualToString:[_reEnterPasswordTextField text]]){
            _passwordsDontMatchLabel.hidden = NO;
            _submitButton.alpha = 0.6;
            _submitButton.enabled = NO;
        }
        else {
            _passwordsDontMatchLabel.hidden = YES;
            _submitButton.alpha = 1;
            _submitButton.enabled = YES;
        }
    }
}


- (void) createUser{
        NSArray* objects = [NSArray arrayWithObjects:
                            [_emailTextField text],
                            [_firstNameTextField text],
                            [_lastNameTextField text],
                            [_passwordTextField text],
                            kPointAPIKey,
                            kPointAPISecret,
                            nil];
        NSArray* keys = [NSArray arrayWithObjects:
                         @"email",
                         @"firstname",
                         @"lastname",
                         @"password",
                         @"appId",
                         @"appSecret",
                         nil];
        NSDictionary* params = [NSDictionary dictionaryWithObjects:objects forKeys:keys];

        NSMutableArray* pairs = [[NSMutableArray alloc] initWithCapacity:0];
        for(NSString* key in params){
            if(params[key] == nil){
                break;
            }
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, params[key]]];
        }
        NSString* requestParams = [pairs componentsJoinedByString:@"&"];
        NSURLResponse* urlResponseList;
        NSError* requestErrorList;
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:@"https://api.point.io/api/v2/users/create.json"]];
        [request setHTTPMethod:@"POST"];
        NSData* payload = [requestParams dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:payload];
        [request addValue:_partnerSession forHTTPHeaderField:@"Authorization"];
        NSData* response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponseList error:&requestErrorList];
    
        if(!response){
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Request response is nil"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles: nil];
            [alert show];
        }
        else {
            NSArray *temp = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
            if([[temp valueForKey:@"ERROR"]integerValue] == 1){
                NSString* message = [temp valueForKey:@"MESSAGE"];
                message = [message stringByReplacingOccurrencesOfString:@"ERROR - " withString:@""];
                UIAlertView* alert = [[UIAlertView alloc]
                                      initWithTitle:@"Error"
                                      message:message
                                      delegate:nil
                                      cancelButtonTitle:@"Dismiss"
                                      otherButtonTitles:nil];
                [alert show];
            } else {
                UIAlertView* alert = [[UIAlertView alloc]
                                      initWithTitle:@"Success"
                                      message:@"Account Created"
                                      delegate:nil
                                      cancelButtonTitle:@"Dismiss"
                                      otherButtonTitles:nil];
                [alert show];

                /*
                _username = [_emailTextField text];
                _password = [temp valueForKey:@"PASSWORD"];
                NSString* userID = [temp valueForKey:@"USERID"];
                
                objects = nil;
                keys = nil;
                params = nil;
                pairs = nil;
                requestParams = nil;
                payload = nil;
                objects = [NSArray arrayWithObjects:
                           kPointAPIKey,
                           _username,
                           userID,
                           _password,
                           [_passwordTextField text],
                           kPointAPIKey,
                           kPointAPISecret,
                           nil];
                keys = [NSArray arrayWithObjects:
                        @"apikey",
                        @"email",
                        @"userid",
                        @"oldpassword",
                        @"newpassword",
                        @"appId",
                        @"appSecret",
                        nil];
                params = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
                pairs = [[NSMutableArray alloc] initWithCapacity:0];
                for(NSString* key in params){
                    [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, params[key]]];
                }
                requestParams = [pairs componentsJoinedByString:@"&"];
                [request setURL:[NSURL URLWithString:@"https://api.point.io/api/v2/users/chpass.json"]];
                payload = [requestParams dataUsingEncoding:NSUTF8StringEncoding];
                [request setHTTPBody:payload];
                response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponseList error:&requestErrorList];
                NSArray *temp2 = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
                if([[temp2 valueForKey:@"ERROR"]integerValue] == 1){
                    NSString* message = [temp2 valueForKey:@"MESSAGE"];
                    message = [message stringByReplacingOccurrencesOfString:@"ERROR - " withString:@""];
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:message
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Dismiss"
                                                          otherButtonTitles:nil];
                    [alert show];
                }
                else {
                    _password = [_passwordTextField text];
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                                    message:@"Account Created, Tap Back to Sign In"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Dismiss"
                                                          otherButtonTitles:nil];
                    [alert show];
                    // [self performSegueWithIdentifier:@"goBackHome" sender:self];
                }
                */
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            }
        }
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
        
}


/*
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"goBackHome"]){
        LoginViewController* vc = [segue destinationViewController];
        [vc setUsername:_username];
        [vc setPassword:_password];
        [vc.usernameTextField setText:_username];
        [vc.passwordTextField setText:_password];
        // [vc setShouldSignIn:YES];
    }
    // self.navigationItem.backBarButtonItem.enabled = NO;
    // [self.navigationItem setHidesBackButton:YES];
}
*/

@end
