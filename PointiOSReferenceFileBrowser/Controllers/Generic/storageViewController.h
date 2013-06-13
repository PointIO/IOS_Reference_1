#import <UIKit/UIKit.h>
#import "storageSignupViewController.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "SystemConfiguration/SystemConfiguration.h"

@class AppDelegate;

@interface storageViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate>



@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *signingActivityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *signingInLabel;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (nonatomic) NSString* text;
@property (nonatomic) AppDelegate* appDel;

- (IBAction)signInPressed;
- (IBAction)screenPressed;
- (IBAction)signUp;

- (void) signIn;

@end
