//
//  signupViewController.h
//  point.io
//
//  Created by Constantin Lungu on 4/16/13.
//  Copyright (c) 2013 FusionWorks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "ViewController.h"

@interface signupViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate, UINavigationControllerDelegate, UISplitViewControllerDelegate>

@property (nonatomic) NSString* partnerSession;

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *reEnterPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (weak, nonatomic) IBOutlet UILabel *passwordsDontMatchLabel;

@property (weak, nonatomic) NSString* sessionKey;
@property (weak, nonatomic) NSString* username;
@property (weak, nonatomic) NSString* password;

@property (nonatomic) IBOutlet UISplitViewController* splitViewController;


- (IBAction)signUpPressed;
- (IBAction)screenPressed;

@end
