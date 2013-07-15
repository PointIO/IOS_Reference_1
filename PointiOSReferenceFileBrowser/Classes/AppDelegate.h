//
//  AppDelegate.h
//  PointiOSReferenceFileBrowser
//
//  Created by jimmyboyle on 6/11/13.
//  Copyright (c) 2013 PointIO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestFlight.h"
#import "accessRulesListViewController.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>


@property (strong, nonatomic) UIWindow *window;
// @property (nonatomic, strong) id vc;


@property (nonatomic) BOOL hasLoggedIn;
@property (nonatomic) BOOL successfulLogin;
@property (nonatomic, strong) NSString* sessionKey;
@property (nonatomic, strong) NSString* username;
@property (nonatomic, strong) NSString* password;
@property (nonatomic, strong) NSString* postString;
@property (nonatomic, strong) NSArray* JSONArrayAuth;
@property (nonatomic, strong) NSString* shareExpirationDate;

@property (nonatomic, strong) NSArray* accessRulesEnabledArray;
@property (nonatomic, retain) IBOutlet accessRulesListViewController *accessRulesLVC;

// @property (nonatomic, strong) NSMutableArray* enabledConnections;
// @property (nonatomic) NSMutableDictionary* storageStatus;
// @property (nonatomic, strong) NSMutableDictionary* connectionsNameAndTypes;
// @property (nonatomic, strong) NSMutableDictionary* connectionsTypesAndEnabledStates;


@end
