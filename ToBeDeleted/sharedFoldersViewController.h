#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "workspaceViewController.h"

@interface sharedFoldersViewController : UITableViewController

@property (nonatomic) NSString* sessionKey;
@property (nonatomic) NSString* storageName;
@property (nonatomic,strong) NSArray* JSONSharedFoldersArray;
@property (nonatomic,strong) NSMutableArray* list;
@property (nonatomic,strong) NSMutableArray* shareIDs;

@property (nonatomic, strong) NSDictionary* connectionSharedFolders;

@property (nonatomic) NSMutableArray* folderNames;
@property (nonatomic) NSMutableArray* folderShareIDs;

@end
