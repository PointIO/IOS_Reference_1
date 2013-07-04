//
//  accessRulesListViewController.h
//  PointiOSReferenceFileBrowser
//
//  Created by jb on 6/13/13.
//  Copyright (c) 2013 PointIO. All rights reserved.
//
#import <UIKit/UIKit.h>
// #import "AppDelegate.h"
#import "Reachability.h"
#import "SystemConfiguration/SystemConfiguration.h"

@interface accessRulesListViewController : UITableViewController


// @property (nonatomic) AppDelegate* appDel;
@property (nonatomic) NSArray* list;
@property (nonatomic) NSMutableArray* tempArray;
@property (nonatomic) NSString* label;
@property (nonatomic, retain) NSString *selectedShareName;
@property (nonatomic, retain) NSString *selectedShareID;

// REST API
@property (nonatomic,strong) NSArray* JSONSharedFoldersArray;
@property (nonatomic) NSString* sessionKey;
@property (nonatomic) NSArray* result;

@property (nonatomic,strong) NSMutableArray* storageTypesArray;
@property (nonatomic,strong) NSMutableArray* storageSitesArray;
@property (nonatomic,strong) NSMutableArray* storageSitesNamesArray;
@property (nonatomic,strong) NSMutableArray* storageSitesIDsArray;
@property (nonatomic,strong) NSMutableArray* storageSitesEnabledStatusArray;
@property (nonatomic,strong) NSMutableArray* storageSitesSiteTypeIDArray;
@property (nonatomic,strong) NSMutableArray* storageSitesSiteTypeNameArray;
@property (nonatomic,strong) NSMutableArray* storageSitesArrayOfDictionaries;
@property (nonatomic,strong) NSMutableArray* accessRulesArray;
@property (nonatomic,strong) NSMutableArray* accessRulesNamesArray;
@property (nonatomic,strong) NSMutableArray* accessRulesShareIDArray;
@property (nonatomic,strong) NSMutableArray* accessRulesSiteIDArray;
@property (nonatomic,strong) NSMutableArray* accessRulesSiteTypeNameArray;
@property (nonatomic,strong) NSMutableArray* accessRulesEnabledArray;


- (void) reloadLists:(NSNotification*) notification;

@end
