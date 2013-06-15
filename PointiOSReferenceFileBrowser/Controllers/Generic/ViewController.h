#import <UIKit/UIKit.h>
#import "connectionsTableViewController.h"
#import "AFJSONRequestOperation.h"
#import "dispatch/dispatch.h"

#import "signupViewController.h"
#import "Reachability.h"
#import "SystemConfiguration/SystemConfiguration.h"
#import <QuartzCore/QuartzCore.h>
#import "docViewerViewControlleriPad.h"
#import "shareListViewController.h"


@interface ViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *signOutButton;
@property (weak, nonatomic) IBOutlet UIButton *goBackButton;

// REST API PROPERTIES
@property (nonatomic) NSString* username;
@property (nonatomic) NSString* password;
@property (nonatomic) NSString* sessionKey;
@property (nonatomic) NSString* postString;
@property (nonatomic,strong) NSArray* JSONArrayAuth;
@property (nonatomic,strong) NSArray* JSONArrayList;
@property (nonatomic) BOOL successfulLogin;
@property (nonatomic) BOOL shouldSignIn;
@property (nonatomic) AppDelegate* appDel;

- (IBAction)signInPressed;				
- (IBAction)screenPressed;
- (IBAction)signOutPressed;
- (IBAction)goBackPressed;
- (IBAction)signUpPressed;

- (void) signIn;
- (void) signOut;

- (void) performAuthCall;
- (void) performListCall;
- (void) displayError;

- (BOOL) isConnectedToInternet;
@end
