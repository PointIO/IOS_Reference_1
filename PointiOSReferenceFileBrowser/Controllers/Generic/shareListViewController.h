//
//  shareListViewController.h
//  PointiOSReferenceFileBrowser
//
//  Created by jb on 6/13/13.
//  Copyright (c) 2013 PointIO. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Reachability.h"
#import "SystemConfiguration/SystemConfiguration.h"
#import "workspaceViewController.h"

@interface shareListViewController : UITableViewController


@property (nonatomic) NSMutableArray* list;
@property (nonatomic) AppDelegate* appDel;
@property (nonatomic) NSString* label;
@property (nonatomic, retain) NSString *selectedShareName;
@property (nonatomic, retain) NSString *selectedShareID;

// REST API
@property (nonatomic,strong) NSArray* JSONSharedFoldersArray;
@property (nonatomic) NSMutableArray* folderNames;
@property (nonatomic) NSMutableArray* folderShareIDs;
@property (nonatomic) NSString* sessionKey;
@property (nonatomic) NSArray* result;


- (void) reloadLists:(NSNotification*) notification;

@end
