//
//  AppDelegate.m
//  PointiOSReferenceFileBrowser
//
//  Created by jimmyboyle on 6/11/13.
//  Copyright (c) 2013 PointIO. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "Flurry.h"
#import "Common.h"
#import "JMC.h"
#import "accessRulesListViewController.h"
#import "storageSitesListViewController.h"


@implementation AppDelegate


static NSString *const kFlurryAPIKey = @"2XMYBQX7DPHPK96SQ9H9";
static NSString *const kPointAPIKey = @"apikey=b022de6e-9bf6-11e2-b014-12313b093415";
static NSString *const kPointDemoUserName = @"demo@point.io";
static NSString *const kPointDemoPassword = @"demo";

static NSString *resetPointFirstLaunchKey = @"1";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    ///*
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    [TestFlight takeOff:@"a16c5748-0fde-45d6-b1f5-6874d4388987"];
    _hasLoggedIn = NO;
    //*/
    
    [Flurry startSession:kFlurryAPIKey];

    
    [[JMC sharedInstance] configureJiraConnect:@"https://pointio.atlassian.net/"
                                    projectKey:@"IOS"
                                        apiKey:@"b85906bc-f3aa-4fd7-afb7-df3b7f4b2853"];
    
    _accessRulesEnabledArray = [[NSMutableArray alloc] init];

    if([[defaults valueForKey:@"USERNAME"] length] != 0 && [[defaults valueForKey:@"PASSWORD"] length] !=0){
        _username = [defaults valueForKey:@"USERNAME"];
        _password = [defaults valueForKey:@"PASSWORD"];
    }
    else {
        _username = kPointDemoUserName;
        _password = kPointDemoPassword;
    }
    [self signIn];
    
    // send Session Key to 1st View Controllers
    UITabBarController* mainController = (UITabBarController*)  self.window.rootViewController;
    NSArray *navControllersArray = [mainController viewControllers];
    UINavigationController *rootNavController = [navControllersArray objectAtIndex:0];
    NSArray *viewControllersArray = rootNavController.viewControllers;
    accessRulesListViewController *aRLTVC = [viewControllersArray objectAtIndex:0];
    aRLTVC.sessionKey = _sessionKey;
    
    UINavigationController *navController2 = [navControllersArray objectAtIndex:1];
    NSArray *viewControllersArray2 = navController2.viewControllers;
    storageSitesListViewController *sSLVC = [viewControllersArray2 objectAtIndex:0];
    sSLVC.sessionKey = _sessionKey;
    
        
    return YES;
}

- (void) signIn{
    if([_username isEqualToString:@""] || [_password isEqualToString:@""]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"No username/password available.  Please Sign Up"
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles: nil];
        [alert show];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
    else if(![Common isConnectedToInternet]){
        UIAlertView* err = [[UIAlertView alloc] initWithTitle:@"Error"
                                                      message:@"Looks like there is no internet connection, please check the settings"
                                                     delegate:nil
                                            cancelButtonTitle:@"Dismiss"
                                            otherButtonTitles:nil];
        UIImageView* temp = [[UIImageView alloc] initWithFrame:CGRectMake(2, 0, 280, 174)];
        temp.image = [UIImage imageNamed:@"noInternetConnection.png"];
        [err addSubview:temp];
        [err setBackgroundColor:[UIColor clearColor]];
        [err show];
    }
    else {
        _postString = [kPointAPIKey stringByAppendingFormat:@"&email=%@&password=%@",_username,_password];
        [self performSelectorOnMainThread:@selector(performAuthCall) withObject:nil waitUntilDone:YES];
    }
}


- (void)applicationWillResignActive:(UIApplication *)application{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void) performAuthCall{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://api.point.io/api/v2/auth.json"]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[_postString dataUsingEncoding:NSUTF8StringEncoding]];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if(![Common isConnectedToInternet]){
            UIAlertView* err = [[UIAlertView alloc] initWithTitle:@"Error"
                                                          message:@"Looks like there is no internet connection, please check the settings"
                                                         delegate:nil
                                                cancelButtonTitle:@"Dismiss"
                                                otherButtonTitles:nil];
            UIImageView* temp = [[UIImageView alloc] initWithFrame:CGRectMake(2, 0, 280, 174)];
            temp.image = [UIImage imageNamed:@"noInternetConnection.png"];
            [err addSubview:temp];
            [err setBackgroundColor:[UIColor clearColor]];
            [err show];
        }
        else {
            NSURLResponse* urlResponseList;
            NSError* requestErrorList;
            NSData* response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponseList error:&requestErrorList];
            if(!response){
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Request response is nil"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Dismiss"
                                                      otherButtonTitles: nil];
                [alert show];
            }
            else {
                _JSONArrayAuth = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
                NSString* errorFlagString = [_JSONArrayAuth valueForKey:@"ERROR"];
                int errorFlag = [errorFlagString integerValue];
                if(errorFlag == 1){
                    [self performSelectorOnMainThread:@selector(displayError) withObject:nil waitUntilDone:YES];
                }
                else {
                    _successfulLogin = YES;
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:_username forKey:@"USERNAME"];
                    [defaults setObject:_password forKey:@"PASSWORD"];
                    [defaults synchronize];
                    NSDictionary* result = [_JSONArrayAuth valueForKey:@"RESULT"];
                    _sessionKey = [result valueForKey:@"SESSIONKEY"];
                    NSLog(@"SESSION KEY = %@",_sessionKey);
                    // [self performSelectorOnMainThread:@selector(performListCall) withObject:nil waitUntilDone:YES];
                }
            }
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            // dispatch_async(dispatch_get_main_queue(), ^{
                // [MBProgressHUD hideHUDForView:self.view animated:YES];
                // if(_JSONArrayAuth != NULL){
                    // [self goToConnectionsView];
                // }
            // });
        }
   //});
}

/*
if ([resetPointFirstLaunchKey isEqualToString:@"1"]) {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PointFirstLaunch"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
*/

/*
- (void) getEnabledStatesOnFirstLaunch{
    //
    // On First Time Launch only, populate NSUserDefaults with each Storage Connection's Enabled Status
    // Subsequent launches will look to NSUserDefaults to determine Storage Connection's Enabled/Disabled Status
    // since the user can change this status from within the app, and we can save network calls by tracking
    // this information locally.
    //
    NSInteger firstLaunch = [[NSUserDefaults standardUserDefaults] integerForKey:@"PointFirstLaunch"];

    if(![Common isConnectedToInternet]){
        UIAlertView* err = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Looks like there is no internet connection, please check the settings" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        UIImageView* temp = [[UIImageView alloc] initWithFrame:CGRectMake(2, 0, 280, 174)];
        temp.image = [UIImage imageNamed:@"noInternetConnection.png"];
        [err addSubview:temp];
        [err setBackgroundColor:[UIColor clearColor]];
        [err show];
    }
    else if (firstLaunch != 1) {

        _enabledConnections = [NSMutableArray array];
        NSURLResponse* urlResponseList;
        NSError* requestErrorList;
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:@"https://api.point.io/api/v2/storagesites/list.json"]];
        [request setHTTPMethod:@"GET"];
        [request addValue:_sessionKey forHTTPHeaderField:@"Authorization"];
        NSData* response = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&urlResponseList
                                                             error:&requestErrorList];
        if(response){
            NSArray* JSONArrayList = [NSJSONSerialization JSONObjectWithData:response
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:nil];
            NSDictionary* result = [JSONArrayList valueForKey:@"RESULT"];
            NSArray* columns = [result valueForKey:@"COLUMNS"];
            NSArray* data = [result valueForKey:@"DATA"];
            NSLog(@"StorageSites from API are %@", JSONArrayList);
            for(int i=0; i<[data count];i++){
                NSArray* data2 = [data objectAtIndex:i];
                NSDictionary* temp = [NSDictionary dictionaryWithObjects:data2 forKeys:columns];
                if([[temp valueForKey:@"ENABLED"] integerValue] == 1){
                    [_enabledConnections addObject:@"1"];
                } else {
                    [_enabledConnections addObject:@"0"];
                }
            }
            [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"PointFirstLaunch"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            NSLog(@"NSUserDefaults Object Contents are %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"ENABLEDCONNECTIONS"]);
            NSLog(@"NSUserDefaults Object Contents are %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"PointFirstLaunch"]);

        }
    }
}
*/

/*
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
*/


@end



