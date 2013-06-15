//
//  connectionListViewController.h
//  PointiOSReferenceFileBrowser
//
//  Created by jimmyboyle on 6/15/13.
//  Copyright (c) 2013 PointIO. All rights reserved.
//
#import "AppDelegate.h"
#import "newConnectionViewController.h"
#import "Reachability.h"
#import "SystemConfiguration/SystemConfiguration.h"
#import <UIKit/UIKit.h>

@interface connectionListViewController : UITableViewController

@property (nonatomic) AppDelegate* appDel;
@property (nonatomic) NSMutableArray* list;

@property (nonatomic) NSArray* JSONArrayList;
@property (nonatomic) NSString* sessionKey;
@property (nonatomic) NSMutableArray* storageIDs;
@property (nonatomic) NSDictionary* sharedFolderData;

- (BOOL) isConnectedToInternet;

@end
