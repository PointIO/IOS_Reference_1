#import <UIKit/UIKit.h>
#import "AFJSONRequestOperation.h"
#import "dispatch/dispatch.h"

#import "signupViewController.h"
#import "Reachability.h"
#import "SystemConfiguration/SystemConfiguration.h"
#import <QuartzCore/QuartzCore.h>

#import "docViewerViewControlleriPad.h"
#import "accessRulesListViewController.h"
#import "ConnectionListViewController.h"
#import "connectionsTableViewController.h"
#import "SettingsViewController.h"


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


// JB 6/24
@property (nonatomic,strong) NSMutableArray* storageTypesArray;

@property (nonatomic,strong) NSMutableArray* storageSitesArray;
@property (nonatomic,strong) NSMutableArray* storageSitesNamesArray;
@property (nonatomic,strong) NSMutableArray* storageSitesIDsArray;
@property (nonatomic,strong) NSMutableArray* storageSitesEnabledStatusArray;
@property (nonatomic,strong) NSMutableArray* storageSitesSiteTypeIDArray;
@property (nonatomic,strong) NSMutableArray* storageSitesSiteTypeNameArray;
@property (nonatomic,strong) NSMutableArray* storageSitesArrayOfDictionaries;

@property (nonatomic,strong) NSMutableArray* accessRulesArray;
@property (nonatomic,strong) NSMutableArray* accessRulesNamesArray;
@property (nonatomic,strong) NSMutableArray* accessRulesShareIDArray;
@property (nonatomic,strong) NSMutableArray* accessRulesSiteIDArray;
@property (nonatomic,strong) NSMutableArray* accessRulesSiteTypeNameArray;

@property (nonatomic,strong) NSMutableArray* accessRulesEnabledArray;


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
