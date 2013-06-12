//
//  AppDelegate.h
//  PointiOSReferenceFileBrowser
//
//  Created by jimmyboyle on 6/11/13.
//  Copyright (c) 2013 PointIO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestFlight.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) NSMutableDictionary* storageStatus;
@property (nonatomic) BOOL hasLoggedIn;
@property (nonatomic, strong) NSMutableArray* enabledConnections;
@property (nonatomic, strong) NSString* sessionKey;
@property (nonatomic, strong) NSString* user;
@property (nonatomic, strong) NSString* password;
@property (nonatomic, strong) NSString* shareExpirationDate;


@property (nonatomic, strong) id vc;

// DetailViewManager is assigned as the Split View Controller's delegate.
// However, UISplitViewController maintains only a weak reference to its
// delegate.  Someone must hold a strong reference to DetailViewManager
// or it will be deallocated after the interface is finished unarchieving.

- (void) getEnabledStates:(NSNotification*)notification;
- (void) removeOneIndex:(NSNotification*)notification;

@end
