#import <UIKit/UIKit.h>
#import "storageViewController.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "SystemConfiguration/SystemConfiguration.h"

@interface connectionsManagerViewController : UITableViewController

@property (nonatomic) NSMutableArray* list;

//REST API
@property (nonatomic) NSArray* JSONArrayList;
@property (nonatomic) NSDictionary* sharedFolderData;
@property (nonatomic) AppDelegate* appDel;
@property (nonatomic) NSString* sessionKey;
@property (nonatomic) NSMutableArray* storageIDs;

- (void) valueChanged:(id) sender withIndex:(NSInteger) index;

@end