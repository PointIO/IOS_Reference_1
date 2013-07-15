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
#import "SBTableAlert.h"

@interface connectionListViewController : UITableViewController <SBTableAlertDataSource, SBTableAlertDelegate>

@property (nonatomic) AppDelegate* appDel;
@property (nonatomic) NSMutableArray* list;
@property (nonatomic, strong) NSMutableArray* allPossibleConnections;
@property (nonatomic, strong) NSMutableArray* userKeys;
@property (nonatomic, strong) NSMutableArray* userValues;
@property (nonatomic, strong) SBTableAlert *alert;
@property (nonatomic) NSArray* JSONArrayList;
@property (nonatomic) NSString* sessionKey;
@property (nonatomic) NSMutableArray* storageIDs;
@property (nonatomic) NSDictionary* sharedFolderData;
@property (nonatomic) NSDictionary* userStorageInput;

// JB 6/24/13
@property (nonatomic, strong) NSArray* storageSitesArrayOfDictionaries;
// @property (nonatomic, strong) IBOutlet UISwitch *statusSwitch;
@property (nonatomic) NSString *selectedStorageName;



- (BOOL) isConnectedToInternet;
- (IBAction)valueChanged:(id) sender withIndex:(NSInteger) index;
- (IBAction)addConnectionPressed:(id)sender;

@end
