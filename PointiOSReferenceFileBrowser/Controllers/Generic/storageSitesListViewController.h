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

@interface storageSitesListViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *storageSitesArrayOfDictionaries;
@property (nonatomic, strong) NSArray *storageSiteTypesInUse;
@property (nonatomic) NSString *sessionKey;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *addButton;
@property (nonatomic) AppDelegate* appDel;

// - (IBAction)addConnectionPressed:(id)sender;

@end