#import <UIKit/UIKit.h>
#import "connectionsManagerViewController.h"
#import "sharedFoldersViewController.h"
#import "SBTableAlert.h"
#import "newConnectionViewController.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "SystemConfiguration/SystemConfiguration.h"

@interface connectionsTableViewController : UITableViewController <SBTableAlertDelegate, SBTableAlertDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *manageStoredConnectionsButton;
@property (nonatomic) NSMutableArray* list;
@property (nonatomic) NSMutableArray* displayList;
@property (nonatomic) NSString* storageName;

// REST API
@property (nonatomic, strong) SBTableAlert *alert;
@property (nonatomic,strong) NSArray* JSONArrayList;
@property (nonatomic) NSString* sessionKey;
@property (nonatomic,strong) NSMutableArray* shareIDs;
@property (nonatomic,strong) NSMutableArray* fileNames;
@property (nonatomic,strong) NSMutableArray* fileIDs;
@property (nonatomic,strong) NSMutableArray* storageIDs;
@property (nonatomic,strong) NSMutableArray* allPossibleConnections;
@property (nonatomic) NSString* containerID;
@property (nonatomic) NSString* remotePath;
@property (nonatomic) AppDelegate* appDel;
@property (nonatomic) NSString* label;
@property (nonatomic) NSString* fieldName;
@property (nonatomic) NSString* temp;
@property (nonatomic) NSArray* result;

@property (nonatomic, strong) NSMutableArray* connectionSharedFolders;

@property (nonatomic) NSMutableArray* EmailFields;
@property (nonatomic) UIAlertView* globalAlert;
// NEW STORAGE
@property (nonatomic) NSMutableArray* userKeys;
@property (nonatomic) NSMutableArray* userValues;
@property (nonatomic) NSDictionary* userStorageInput;
@property (nonatomic) NSString* connectionSiteTypeID;


- (IBAction)manageStoredConnectionsPressed:(id)sender;
- (IBAction)addNewConnectionPressed:(id)sender;

- (void) getAllPossibleConnections;
- (void) reloadLists:(NSNotification*) notification;
- (void) checkForAtSign;
@end
