//
//  StorageTypesViewController.h
//  PointiOSReferenceFileBrowser
//
//  Created by jb on 6/27/13.
//  Copyright (c) 2013 PointIO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"


@interface StorageTypesViewController : UITableViewController

@property (nonatomic) NSString* sessionKey;
@property (nonatomic) AppDelegate* appDel;
@property (nonatomic,strong) NSMutableArray *storageTypesArray;
@property (nonatomic, strong) NSMutableArray *storageTypesIDsArray;
@property (nonatomic, strong) NSMutableArray *storageTypesNamesArray;
@property (nonatomic, strong) NSArray *storageTypesArrayOfDictionaries;


@end
