#import <UIKit/UIKit.h>
#import "docViewerViewController.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "SystemConfiguration/SystemConfiguration.h"

@interface workspaceViewController : UITableViewController
{
    NSArray *documentsArray;
}

@property (nonatomic) NSString* folderName;

//REST API

@property (nonatomic,strong) NSArray* JSONSharedFoldersArray;
@property (nonatomic) NSString* sessionKey;
@property (nonatomic,strong) NSMutableArray* fileNames;
@property (nonatomic,strong) NSMutableArray* fileIDs;
@property (nonatomic) NSString* containerID;
@property (nonatomic) NSString* remotePath;
@property (nonatomic) NSString* shareID;
@property (nonatomic) NSMutableArray* fileShareIDs;
@property (nonatomic) NSMutableArray* containerIDs;
@property (nonatomic) NSMutableArray* filePaths;
@property (nonatomic) NSMutableArray* isFolder; //TIP IOS-12
@property (nonatomic) NSMutableArray* containerIDHistory;

@property (nonatomic) NSString* lastFolderTitle;

@property (nonatomic) int i;
@property (nonatomic) int nestedFoldersCounter;

- (void) getFileNamesAndFileIDs;

@end
