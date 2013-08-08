//
//  SignInViewController.h
//  PointiOSReferenceFileBrowser
//
//  Created by jimboyle on 8/2/13.
//  Copyright (c) 2013 PointIO. All rights reserved.
//

#import <UIKit/UIKit.h>
// #import "AFJSONRequestOperation.h"
// #import "dispatch/dispatch.h"
// #import "Reachability.h"
// #import "SystemConfiguration/SystemConfiguration.h"
// #import <QuartzCore/QuartzCore.h>
// #import "getAccountViewController.h"
// #import "signupViewController.h"


@interface SignInViewController : UITableViewController

<
UITextFieldDelegate
>


@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *loggedInAsNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *loggedInAsNameText;
@property (nonatomic) BOOL hasLoggedIn;

// REST API PROPERTIES
@property (nonatomic) NSString* username;
@property (nonatomic) NSString* password;
@property (nonatomic) NSString* sessionKey;
@property (nonatomic) NSString* postString;
@property (nonatomic,strong) NSArray* JSONArrayAuth;


@end
