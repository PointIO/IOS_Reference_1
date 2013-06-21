#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "AppDelegate.h"

@interface newConnectionViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *enabledSwitch;
@property (weak, nonatomic) IBOutlet UILabel *enabledLabel;
@property (weak, nonatomic) IBOutlet UISwitch *loggingEnabled;
@property (weak, nonatomic) IBOutlet UILabel *loggingLabel;
@property (weak, nonatomic) IBOutlet UISwitch *revisionControl;
@property (weak, nonatomic) IBOutlet UILabel *revisionLabel;
@property (weak, nonatomic) IBOutlet UITextField *maxRevisions;
@property (weak, nonatomic) IBOutlet UILabel *maxRevisionsLabel;
@property (weak, nonatomic) IBOutlet UISwitch *checkinCheckout;
@property (weak, nonatomic) IBOutlet UILabel *checkinCheckoutLabel;
@property (weak, nonatomic) IBOutlet UIButton *createButton;

@property (nonatomic) NSDictionary* userStorageInput;
@property (nonatomic) NSString* sessionKey;
@property (nonatomic) NSString* siteTypeID;
@property (nonatomic) NSString* userInputString;
@property (nonatomic) NSString* siteTypeName;

@property (nonatomic) AppDelegate* appDel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

// NEW STORAGE
@property (nonatomic) NSMutableArray* userKeys;
@property (nonatomic) NSMutableArray* userValues;
@property (nonatomic) NSString* connectionSiteTypeID;
@property (nonatomic) NSMutableArray* allPossibleConnections;
@property (nonatomic) NSString* requestedConnectionName;

@property (nonatomic) NSMutableArray* allUIInputs;

- (IBAction)revisionControlEnabledValueChanged;
- (IBAction)screenPressed;

- (IBAction)createPressed;

@end
