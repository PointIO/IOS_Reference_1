//
//  LoginViewController.h
//  PointiOSReferenceFileBrowser
//
//  Created by jimboyle on 7/6/13.
//  Copyright (c) 2013 PointIO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFJSONRequestOperation.h"
#import "dispatch/dispatch.h"
#import "signupViewController.h"
#import "Reachability.h"
#import "SystemConfiguration/SystemConfiguration.h"
#import <QuartzCore/QuartzCore.h>


@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *signOutButton;
@property (weak, nonatomic) IBOutlet UIButton *demoButton;

// REST API PROPERTIES
@property (nonatomic) NSString* username;
@property (nonatomic) NSString* password;
@property (nonatomic) NSString* sessionKey;
@property (nonatomic) NSString* postString;
@property (nonatomic,strong) NSArray* JSONArrayAuth;
@property (nonatomic) BOOL hasLoggedIn;

- (IBAction)signInPressed;
- (IBAction)screenPressed;
- (IBAction)signOutPressed;
- (IBAction)demoPressed;
- (IBAction)signUpPressed;

- (void) signIn;
- (void) signOut;
- (void) performAuthCall;
- (void) displayError;
- (BOOL) isConnectedToInternet;

@end
