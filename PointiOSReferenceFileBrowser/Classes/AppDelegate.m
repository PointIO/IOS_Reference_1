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
#import "LoginViewController.h"


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // NSLog(@"Contents of NSUserDefaults is %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    
    // [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    NSString *testFlightKey = @"a16c5748-0fde-45d6-b1f5-6874d4388987";
    // [Common getAppKey:@"keyTestFlight"];
    [TestFlight takeOff:testFlightKey];
    _hasLoggedIn = NO;
    
    NSString *flurryKey = [Common getAppKey:@"keyFlurry"];
    [Flurry startSession:flurryKey];
    
    [[JMC sharedInstance] configureJiraConnect:@"https://pointio.atlassian.net/"
                                    projectKey:@"IOS"
                                        apiKey:[Common getAppKey:@"keyJira"]];
    
    _accessRulesEnabledArray = [[NSMutableArray alloc] init];

    NSString *tableViewRowColor = [defaults objectForKey:@"defaultColorTheme"];
    if (!tableViewRowColor) {
        NSLog(@"There was no color set");
        [[NSUserDefaults standardUserDefaults] setValue:@"White" forKey:@"defaultColorTheme"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    if([[defaults valueForKey:@"USERNAME"] length] != 0 && [[defaults valueForKey:@"PASSWORD"] length] !=0){
        _username = [defaults valueForKey:@"USERNAME"];
        _password = [defaults valueForKey:@"PASSWORD"];
    }
    else {
        _username = [Common getAppKey:@"pointDemoAccount"];
        _password = [Common getAppKey:@"pointDemoPassword"];
    }
    [self signIn];
    
    // send Session Key to Relevant View Controllers
    UITabBarController* mainController = (UITabBarController*)  self.window.rootViewController;
    NSArray *navControllersArray = [mainController viewControllers];
    UINavigationController *rootNavController = [navControllersArray objectAtIndex:0];
    NSArray *viewControllersArray = rootNavController.viewControllers;
    accessRulesListViewController *aRLTVC = [viewControllersArray objectAtIndex:0];
    aRLTVC.sessionKey = _sessionKey;
    
    // send Session Key to Relevant View Controllers
    UINavigationController *navController2 = [navControllersArray objectAtIndex:1];
    NSArray *viewControllersArray2 = navController2.viewControllers;
    storageSitesListViewController *sSLVC = [viewControllersArray2 objectAtIndex:0];
    sSLVC.sessionKey = _sessionKey;
            
    // send Session Key to Relevant View Controllers
    UINavigationController *navController3 = [navControllersArray objectAtIndex:2];
    NSArray *viewControllersArray3 = navController3.viewControllers;
    LoginViewController *lVC = [viewControllersArray3 objectAtIndex:0];
    lVC.sessionKey = _sessionKey;
    lVC.hasLoggedIn = TRUE;
    
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
        _postString = [Common getAppKey:@"AppKeyPostString"];
        _postString = [_postString stringByAppendingFormat:@"&email=%@&password=%@",_username,_password];
        // _postString = [kPointAPIKey stringByAppendingFormat:@"&email=%@&password=%@",_username,_password];
        [self performSelectorOnMainThread:@selector(performAuthCall) withObject:nil waitUntilDone:YES];
    }
}


- (void) performAuthCall{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://api.point.io/api/v2/auth.json"]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[_postString dataUsingEncoding:NSUTF8StringEncoding]];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
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
    }
}


- (void) displayError{
    _successfulLogin = NO;
    // send Session Key to Relevant View Controllers
    UITabBarController* mainController = (UITabBarController*)  self.window.rootViewController;
    NSArray *navControllersArray = [mainController viewControllers];
    UINavigationController *navController = [navControllersArray objectAtIndex:2];
    NSArray *viewControllersArray = navController.viewControllers;
    LoginViewController *lVC = [viewControllersArray objectAtIndex:0];
    lVC.sessionKey = nil;
    lVC.hasLoggedIn = FALSE;

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"The password or the username is incorrect. Please try again."
                                                   delegate:nil
                                          cancelButtonTitle:@"Dismiss"
                                          otherButtonTitles: nil];
    UIImageView* temp = [[UIImageView alloc] initWithFrame:CGRectMake(2, 0, 280, 154)];
    temp.image = [UIImage imageNamed:@"passwordUsernameIncorrect.png"];
    [alert addSubview:temp];
    [alert setBackgroundColor:[UIColor clearColor]];
    [alert show];
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


@end



