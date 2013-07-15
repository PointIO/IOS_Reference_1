#import <UIKit/UIKit.h>
#import "sharingViewController.h"
#import "TestFlight.h"
#import "MBProgressHUD.h"
#import "QuickLook/QuickLook.h"
#import "SBTableAlert.h"
#import "HubsViewController.h"

@interface docViewerViewControlleriPad : UIViewController <UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource, SBTableAlertDataSource, SBTableAlertDelegate>

@property (nonatomic) NSMutableArray* list;
@property (nonatomic) NSMutableArray* displayList;
@property (nonatomic) NSMutableArray* manageList;
@property (nonatomic,strong) NSArray* JSONArrayList;
@property (nonatomic,strong) NSMutableArray* shareIDs;
@property (nonatomic,strong) NSMutableArray* fileNames;
@property (nonatomic,strong) NSMutableArray* fileIDs;
@property (nonatomic,strong) NSMutableArray* storageIDs;
@property (nonatomic,strong) NSMutableArray* allPossibleConnections;
@property (nonatomic, strong) NSMutableArray* connectionSharedFolders;
@property (nonatomic) NSString* storageName;
@property (nonatomic) AppDelegate* appDel;


@property (nonatomic,strong) NSArray* JSONSharedFoldersArray;
@property (nonatomic) NSString* sessionKey;
@property (nonatomic) NSString* containerID;
@property (nonatomic) NSString* remotePath;
@property (nonatomic) NSString* shareID;
@property (nonatomic) NSMutableArray* fileShareIDs;
@property (nonatomic) NSMutableArray* containerIDs;
@property (nonatomic) NSMutableArray* filePaths;
@property (nonatomic) NSMutableArray* containerIDHistory;

@property (nonatomic) NSMutableArray* folderNames;
@property (nonatomic) NSMutableArray* folderShareIDs;

@property (nonatomic) NSString* lastFolderTitle;

@property (nonatomic) int i;
@property (nonatomic) int nestedFoldersCounter;

- (void) getFileNamesAndFileIDs;


// REST API

@property (nonatomic) NSString* fileName;
@property (nonatomic) NSString* fileID;
@property (nonatomic, strong) NSData* downloadData;

@property (weak, nonatomic) IBOutlet UITableView *connectionsTableView;
@property (weak, nonatomic) IBOutlet UITableView *sharedFoldersTableView;

@property (nonatomic, strong) NSURL* fileDownloadURL;

- (IBAction)manageStoredConnectionsPressed:(id)sender;

@property (nonatomic, strong) NSDictionary* sharedFolderData;

// New connection

@property (nonatomic, strong) SBTableAlert *alert;
- (IBAction)addNewConnectionPressed:(id)sender;

// Hubs

- (IBAction)hubsButtonPressed:(id)sender;


@end