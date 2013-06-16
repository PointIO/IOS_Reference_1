//
//  shareDetailViewController.h
//  PointiOSReferenceFileBrowser
//
//  Created by jimmyboyle on 6/15/13.
//  Copyright (c) 2013 PointIO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "docViewerViewController.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "SystemConfiguration/SystemConfiguration.h"

@interface shareDetailViewController : UITableViewController
{
    NSArray *documentsArray;
}

@property (nonatomic) NSString* folderName;

// JB
@property (nonatomic, retain) NSString *selectedShareName;
@property (nonatomic, retain) NSString *selectedShareID;
@property (nonatomic) NSString* shareID;


//REST API
@property (nonatomic,strong) NSArray* JSONSharedFoldersArray;
@property (nonatomic) NSString* sessionKey;
@property (nonatomic,strong) NSMutableArray* fileNames;
@property (nonatomic,strong) NSMutableArray* fileIDs;
@property (nonatomic) NSString* containerID;
@property (nonatomic) NSString* remotePath;
@property (nonatomic) NSMutableArray* fileShareIDs;
@property (nonatomic) NSMutableArray* containerIDs;
@property (nonatomic) NSMutableArray* filePaths;
@property (nonatomic) NSMutableArray* isFolder; //TIP IOS-12
@property (nonatomic) NSMutableArray* containerIDHistory;

@property (nonatomic) NSString* lastFolderTitle;

@property (nonatomic) int i;
@property (nonatomic) int nestedFoldersCounter;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;

- (void) getFileNamesAndFileIDs;

- (IBAction)showPastFolder:(id)sender;
- (IBAction)done:(id)sender;

@end