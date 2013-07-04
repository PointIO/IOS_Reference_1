//
//  accessRulesListViewController.h
//  PointiOSReferenceFileBrowser
//
//  Created by jb on 6/13/13.
//  Copyright (c) 2013 PointIO. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "SystemConfiguration/SystemConfiguration.h"

@interface accessRulesListViewController : UITableViewController

@property (nonatomic) NSArray* list;

// REST API
@property (nonatomic) NSString* sessionKey;
@property (nonatomic) NSArray* result;
@property (nonatomic) NSMutableArray* accessRulesEnabledArray;


- (void) reloadLists:(NSNotification*) notification;

@end
