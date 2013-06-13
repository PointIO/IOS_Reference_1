//
//  workspaceListViewController.h
//  PointiOSReferenceFileBrowser
//
//  Created by jb on 6/13/13.
//  Copyright (c) 2013 PointIO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "workspaceViewController.h"

@interface workspaceListViewController : UITableViewController


@property (nonatomic) NSString* sessionKey;
@property (nonatomic) NSString* storageName;
@property (nonatomic,strong) NSArray* JSONSharedFoldersArray;
@property (nonatomic,strong) NSMutableArray* list;
@property (nonatomic,strong) NSMutableArray* shareIDs;
@property (nonatomic, strong) NSDictionary* connectionSharedFolders;
@property (nonatomic) NSMutableArray* folderNames;
@property (nonatomic) NSMutableArray* folderShareIDs;
@property (nonatomic,strong) NSArray* JSONArrayList;


@end
