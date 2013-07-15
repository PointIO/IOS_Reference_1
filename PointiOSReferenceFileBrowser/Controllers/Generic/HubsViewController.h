//
//  HubsViewController.h
//  point.io
//
//  Created by Constantin Lungu on 6/3/13.
//  Copyright (c) 2013 FusionWorks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "FileViewerControllerIpad.h"

@interface HubsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *hubsTableView;
@property (weak, nonatomic) IBOutlet UITableView *sharedFoldersTableView;
@property (weak, nonatomic) IBOutlet UITableView *activeStorageConnectionsTableView;
@property (weak, nonatomic) IBOutlet UITableView *foldersInHubTableView;
@property (weak, nonatomic) IBOutlet UITableView *activeUsersTableView;
@property (weak, nonatomic) IBOutlet UITableView *permissionsTableView;

@property (weak, nonatomic) IBOutlet UILabel *selectAHubLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *manageHubsButton;
@property (weak, nonatomic) IBOutlet UIImageView *horizontalBorderBar;
@property (weak, nonatomic) IBOutlet UILabel *hubNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *centralBorderBar;

@property (weak, nonatomic) IBOutlet UIButton *viewActivityButton;
@property (weak, nonatomic) IBOutlet UIButton *removeHubButton;
@property (weak, nonatomic) IBOutlet UIButton *viewFilesButton;
@property (weak, nonatomic) IBOutlet UIButton *viewUsersButton;


@property (weak, nonatomic) IBOutlet UIBarButtonItem *inviteUsersButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addFilesFoldersButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addStorageButton;

@property (nonatomic, strong) AppDelegate* appDel;

@property (nonatomic) NSMutableArray* JSONArrayList;
@property (nonatomic) NSMutableArray* connectionSharedFolders;
@property (nonatomic) NSMutableArray* list;
@property (nonatomic) NSMutableArray* displayList;
@property (nonatomic) NSMutableArray* storageIDs;
@property (nonatomic) NSMutableArray* JSONSharedFoldersArray;
@property (nonatomic) NSMutableArray* folderNames;
@property (nonatomic) NSMutableArray* folderShareIDs;
@property (nonatomic) NSMutableArray* activeStorageConnections;

@property (nonatomic) NSString* storageName;

@property (nonatomic) NSMutableArray* activeUsers;
@property (nonatomic) NSMutableArray* permissions;

- (IBAction)storageConnectionsPressed:(id)sender;
- (IBAction)manageHubsPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *inviteUsersPressed;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addFilesPressed;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addStoragePressed;
@end
