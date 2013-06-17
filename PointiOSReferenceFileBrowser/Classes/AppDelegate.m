//
//  AppDelegate.m
//  PointiOSReferenceFileBrowser
//
//  Created by jimmyboyle on 6/11/13.
//  Copyright (c) 2013 PointIO. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    [TestFlight takeOff:@"0ed81236-cf70-4f5e-9ac4-b1cd91995b10"];
    _hasLoggedIn = NO;
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(getEnabledStates:) name:@"getEnabledStates" object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(removeOneIndex:) name:@"removeOneIndex" object:nil];
    
    NSString* temp = [[NSUserDefaults standardUserDefaults] objectForKey:@"ENABLEDCONNECTIONS"];
    if([temp length] > 0){
        _enabledConnections = [NSMutableArray array];
        for(int i = 0; i < [temp length]; i++){
            if([temp characterAtIndex:i] == '1'){
                [_enabledConnections addObject:@"1"];
            } else {
                [_enabledConnections addObject:@"0"];
            }
        }
    }
    NSLog(@"Enabled Connections Status is %@",_enabledConnections);
    return YES;
}

- (void) removeOneIndex:(NSNotification*)notification{
    [_enabledConnections removeLastObject];
    NSString* temp = [[NSString alloc] init];
    for(int i = 0;i < [_enabledConnections count];i++){
        if([[_enabledConnections objectAtIndex:i] isEqualToString:@"1"]){
            if(i==0){
                temp = [NSString stringWithFormat:@"1"];
            } else {
                temp = [temp stringByAppendingString:@"1"];
            }
        } else {
            if(i==0){
                temp = [NSString stringWithFormat:@"0"];
            } else {
                temp = [temp stringByAppendingString:@"0"];
            }
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:temp forKey:@"ENABLEDCONNECTIONS"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) getEnabledStates:(NSNotification*)notification{
    if([_enabledConnections count] == 0){
        
        _enabledConnections = [NSMutableArray array];
        NSURLResponse* urlResponseList;
        NSError* requestErrorList;
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:@"https://api.point.io/api/v2/storagesites/list.json"]];
        [request setHTTPMethod:@"GET"];
        [request addValue:_sessionKey forHTTPHeaderField:@"Authorization"];
        NSData* response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponseList error:&requestErrorList];
        if(response){
            NSArray* JSONArrayList = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
            NSDictionary* result = [JSONArrayList valueForKey:@"RESULT"];
            NSArray* columns = [result valueForKey:@"COLUMNS"];
            NSArray* data = [result valueForKey:@"DATA"];
            for(int i=0; i<[data count];i++){
                NSArray* data2 = [data objectAtIndex:i];
                NSDictionary* temp = [NSDictionary dictionaryWithObjects:data2 forKeys:columns];
                if([[temp valueForKey:@"ENABLED"] integerValue] == 1){
                    [_enabledConnections addObject:@"1"];
                } else {
                    [_enabledConnections addObject:@"0"];
                }
            }
        }
    }
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
