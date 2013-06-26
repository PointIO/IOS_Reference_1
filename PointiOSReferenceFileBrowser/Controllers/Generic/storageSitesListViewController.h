//
//  storageSitesListViewController.h
//  PointiOSReferenceFileBrowser
//
//  Created by jb on 6/25/13.
//  Copyright (c) 2013 PointIO. All rights reserved.
//

#import "AppDelegate.h"
#import "newConnectionViewController.h"
#import "Reachability.h"
#import "SystemConfiguration/SystemConfiguration.h"
#import <UIKit/UIKit.h>
#import "SBTableAlert.h"

@interface storageSitesListViewController : UITableViewController
<
SBTableAlertDataSource,
SBTableAlertDelegate
>

@property (nonatomic) AppDelegate* appDel;
// @property (nonatomic) NSMutableArray* list;
@property (nonatomic, strong) NSArray *storageSitesArrayOfDictionaries;
@property (nonatomic, strong) NSMutableArray *storageSiteTypes;







@property (nonatomic, strong) SBTableAlert *alert;
@property (nonatomic) NSString* sessionKey;
@property (nonatomic) NSString *selectedStorageName;




@property (nonatomic, strong) NSMutableArray* allPossibleConnections;
@property (nonatomic, strong) NSMutableArray* userKeys;
@property (nonatomic, strong) NSMutableArray* userValues;
@property (nonatomic) NSArray* JSONArrayList;
@property (nonatomic) NSMutableArray* storageIDs;
@property (nonatomic) NSDictionary* sharedFolderData;
@property (nonatomic) NSDictionary* userStorageInput;
// @property (nonatomic, strong) IBOutlet UISwitch *statusSwitch;



- (BOOL) isConnectedToInternet;
- (IBAction)valueChanged:(id) sender withIndex:(NSInteger) index;
- (IBAction)addConnectionPressed:(id)sender;

@end