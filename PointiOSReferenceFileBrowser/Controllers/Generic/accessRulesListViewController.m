//
//  accessRulesListViewController.m
//  PointiOSReferenceFileBrowser
//
//  Created by jb on 6/13/13.
//  Copyright (c) 2013 PointIO. All rights reserved.
//

#import "accessRulesListViewController.h"
#import "Common.h"
#import "ShareListCell.h"
#import "shareDetailViewController.h"
#import <QuartzCore/QuartzCore.h>


@interface accessRulesListViewController()

@end

@implementation accessRulesListViewController

{
    CAGradientLayer* _gradientLayer;
}


int selectedRow;
int i;



- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    if ( [(NSString*)[UIDevice currentDevice].model isEqualToString:@"iPad"] ) {
        return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
    } else {
        if(toInterfaceOrientation == UIInterfaceOrientationPortrait){
            return YES;
        } else {
            return NO;
        }
    }
}

- (id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    // _appDel                 = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    // _JSONSharedFoldersArray = [NSArray array];
    _list                   = [[NSMutableArray alloc] init];
    _tempArray              = [[NSMutableArray alloc] init];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{

        [self performListCall];
        
        if (![_accessRulesEnabledArray count]==0){
            for (i=0; i<[_accessRulesEnabledArray count]; i++) {
                NSArray *accessRuleItem;
                accessRuleItem = [_accessRulesEnabledArray objectAtIndex:i];
                [_tempArray addObject:accessRuleItem];
            }
    
            NSSortDescriptor *nameDescriptor =
            [[NSSortDescriptor alloc] initWithKey:@"AccessRuleShareName"
                                        ascending:YES
                                         selector:@selector(localizedCaseInsensitiveCompare:)];
        
            NSArray *descriptors = [NSArray arrayWithObjects:nameDescriptor, nil];
            NSArray *sortedArray = [_tempArray sortedArrayUsingDescriptors:descriptors];
            _list = sortedArray;
            NSLog(@"Sorted Access Rules is %@", _list);
     
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self.tableView reloadData];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            });
        }
        else {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"There are no enabled shares"
                                                             delegate:nil
                                                    cancelButtonTitle:@"Dismiss"
                                                    otherButtonTitles:nil];
                [alert show];
        }
     });    
}

- (void) viewWillDisappear:(BOOL)animated{
}

- (void) viewDidDisappear:(BOOL)animated{
}

- (void) viewWillAppear:(BOOL)animated{
}

- (void) viewDidAppear:(BOOL)animated{
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
    } else {
        [self.tableView reloadData];
    }
}

/*
- (void) reloadLists:(NSNotification *)notification{
    [self performSelectorOnMainThread:@selector(getConnections) withObject:nil waitUntilDone:YES];
    [self.tableView reloadData];
}
*/


- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ShareListCell *cell = (ShareListCell *)[tableView dequeueReusableCellWithIdentifier:@"ShareListCell"];
    
    if([_list count] != 0){
        
        cell.nameLabel.text = [[_list objectAtIndex:indexPath.row] valueForKey:@"AccessRuleShareName"];
        NSString *storageSiteSiteName = [[_list objectAtIndex:indexPath.row] valueForKey:@"AccessRuleSiteTypeName"];
        
        // Set Cell Image
        // Values are stored in sorted Dictionary in AppContent.plist
        NSString *tmpFileName               = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"AppContent"];
        NSString *tmpFilePath               = [[NSBundle mainBundle] pathForResource:tmpFileName ofType:@"plist"];
        NSMutableDictionary *tmpDictionary  = [[NSMutableDictionary alloc] initWithContentsOfFile:tmpFilePath];
        NSDictionary *cloudProviderDict     = [tmpDictionary valueForKey:@"storageProviderArtwork"];
        NSString *tmpImageName  = [cloudProviderDict valueForKey:storageSiteSiteName];
        cell.storageImage.image = [UIImage imageNamed:tmpImageName];
    }
    return cell;
}



#pragma mark
#pragma Core Graphics

-(UIColor*)colorForIndex:(NSInteger) index{
    NSUInteger itemCount = [_list count];
    return [Common theColor:index:itemCount];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.backgroundColor = [self colorForIndex:indexPath.row];
}

#pragma mark - Table view delegate


// Handle Disclosure Button Tap
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}


- (void)viewDidUnload {
    [super viewDidUnload];
}


- (void) performListCall{
    
    // get storageTypes
    NSURLResponse* urlResponseList1;
    NSError* requestErrorList1;
    NSMutableURLRequest *request1 = [[NSMutableURLRequest alloc] init];
    [request1 setURL:[NSURL URLWithString:@"https://api.point.io/api/v2/storagetypes/list.json"]];
    [request1 setHTTPMethod:@"GET"];
    [request1 addValue:_sessionKey forHTTPHeaderField:@"Authorization"];
    NSData* response1 = [NSURLConnection sendSynchronousRequest:request1 returningResponse:&urlResponseList1 error:&requestErrorList1];
    if(!response1){
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Request response is nil" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
    } else {
        _storageTypesArray = [NSJSONSerialization JSONObjectWithData:response1 options:NSJSONReadingMutableContainers error:nil];
    }
    NSLog(@"Inside accessRulesListViewController, performListCall where storageTypes are %@", _storageTypesArray);
    
    
    
    //
    // get storageSites
    //
    NSURLResponse* urlResponseList2;
    NSError* requestErrorList2;
    NSMutableURLRequest *request2 = [[NSMutableURLRequest alloc] init];
    [request2 setURL:[NSURL URLWithString:@"https://api.point.io/api/v2/storagesites/list.json"]];
    [request2 setHTTPMethod:@"GET"];
    [request2 addValue:_sessionKey forHTTPHeaderField:@"Authorization"];
    NSData* response2 = [NSURLConnection sendSynchronousRequest:request2 returningResponse:&urlResponseList2 error:&requestErrorList2];
    if(!response2){
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Request response is nil" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
    } else {
        _storageSitesArray = [NSJSONSerialization JSONObjectWithData:response2 options:NSJSONReadingMutableContainers error:nil];
    }
    NSLog(@"Inside accessRulesListViewController, performListCall where storageSites are %@", _storageSitesArray);
    
    
    //
    // create storageSites Arrays for Names, IDs, Enabled Status, SiteTypeID and SiteTypeName
    //
    NSDictionary *resultStorageSitesDictionary = [_storageSitesArray valueForKey:@"RESULT"];
    NSArray *resultColumns = [resultStorageSitesDictionary valueForKey:@"COLUMNS"];
    NSArray *resultData = [resultStorageSitesDictionary valueForKey:@"DATA"];
    
    _storageSitesNamesArray = [[NSMutableArray alloc] init];
    _storageSitesIDsArray = [[NSMutableArray alloc] init];
    _storageSitesEnabledStatusArray = [[NSMutableArray alloc] init];
    _storageSitesSiteTypeNameArray = [[NSMutableArray alloc] init];
    _storageSitesSiteTypeIDArray = [[NSMutableArray alloc] init];
    _storageSitesArrayOfDictionaries = [[NSMutableArray alloc] init];
    
    for(int i=0; i<[resultData count];i++){
        NSArray* data2 = [resultData objectAtIndex:i];
        NSDictionary* temp = [NSDictionary dictionaryWithObjects:data2 forKeys:resultColumns];
        [_storageSitesIDsArray addObject:[temp valueForKey:@"SITEID"]];
        [_storageSitesNamesArray addObject:[temp valueForKey:@"NAME"]];
        [_storageSitesEnabledStatusArray addObject:[temp valueForKey:@"ENABLED"]];
        [_storageSitesSiteTypeIDArray addObject:[temp valueForKey:@"SITETYPEID"]];
        [_storageSitesSiteTypeNameArray addObject:[temp valueForKey:@"SITETYPENAME"]];
        //
        // evaluate storage sites for status of enabled or disabled
        //
        NSArray *keysArray = [[NSArray alloc] initWithObjects:
                              @"StorageSiteID",
                              @"StorageSiteName",
                              @"StorageSiteEnabled",
                              @"StorageSiteSiteTypeID",
                              @"StorageSiteSiteTypeName",
                              nil];
        
        NSArray *valuesArray = [[NSArray alloc] initWithObjects:
                                [_storageSitesIDsArray objectAtIndex:i],
                                [_storageSitesNamesArray objectAtIndex:i],
                                [_storageSitesEnabledStatusArray objectAtIndex:i],
                                [_storageSitesSiteTypeIDArray objectAtIndex:i],
                                [_storageSitesSiteTypeNameArray objectAtIndex:i],
                                nil];
        
        NSDictionary *storageSiteDictionary = [[NSDictionary alloc] initWithObjects:valuesArray forKeys:keysArray];
        [_storageSitesArrayOfDictionaries addObject:storageSiteDictionary];
    }
    
    //
    // get accessRules
    //
    NSURLResponse* urlResponseList3;
    NSError* requestErrorList3;
    NSMutableURLRequest *request3 = [[NSMutableURLRequest alloc] init];
    [request3 setURL:[NSURL URLWithString:@"https://api.point.io/api/v2/accessrules/list.json"]];
    [request3 setHTTPMethod:@"GET"];
    [request3 addValue:_sessionKey forHTTPHeaderField:@"Authorization"];
    NSData* response3 = [NSURLConnection sendSynchronousRequest:request3 returningResponse:&urlResponseList3 error:&requestErrorList3];
    if(!response3){
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Request response is nil" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
    } else {
        _accessRulesArray = [NSJSONSerialization JSONObjectWithData:response3 options:NSJSONReadingMutableContainers error:nil];
    }
    NSLog(@"Inside accessRulesListViewController, performListCall where accessRules are %@", _accessRulesArray);
    
    
    //
    // create Dictionary of AccessRulesName, AccessRuleID, AccessRuleEnabled Status
    //
    NSDictionary *resultAccessRulesDictionary = [_accessRulesArray valueForKey:@"RESULT"];
    NSArray *resultColumns1 = [resultAccessRulesDictionary valueForKey:@"COLUMNS"];
    NSArray *resultData1 = [resultAccessRulesDictionary valueForKey:@"DATA"];
    
    _accessRulesNamesArray = [[NSMutableArray alloc] init];
    _accessRulesShareIDArray = [[NSMutableArray array] init];
    _accessRulesSiteIDArray = [[NSMutableArray array] init];
    _accessRulesSiteTypeNameArray = [[NSMutableArray array] init];
    _accessRulesEnabledArray = [[NSMutableArray array] init];
    
    for(int i=0; i<[resultData1 count];i++){
        NSArray* data2 = [resultData1 objectAtIndex:i];
        NSDictionary* temp = [NSDictionary dictionaryWithObjects:data2 forKeys:resultColumns1];
        [_accessRulesNamesArray addObject:[temp valueForKey:@"SHARENAME"]];
        [_accessRulesShareIDArray addObject:[temp valueForKey:@"SHAREID"]];
        [_accessRulesSiteIDArray addObject:[temp valueForKey:@"SITEID"]];
        [_accessRulesSiteTypeNameArray addObject:[temp valueForKey:@"SITETYPENAME"]];
        //
        // evaluate _storageSitesIDArray until finding a matching siteID, then determine if enabled or disabled
        //
        for(int j=0; j<[_storageSitesIDsArray count];j++){
            if ([[_accessRulesSiteIDArray objectAtIndex:i] isEqualToString:[_storageSitesIDsArray objectAtIndex:j]]) {
                NSString *storageSiteEnabledStatus = [[_storageSitesEnabledStatusArray objectAtIndex:j] stringValue];
                if ([storageSiteEnabledStatus isEqualToString:@"1"]) {
                    
                    NSArray *keysArray = [[NSArray alloc] initWithObjects:@"AccessRuleShareID",@"AccessRuleShareName", @"AccessRuleSiteTypeName", nil];
                    NSArray *valuesArray = [[NSArray alloc] initWithObjects:[_accessRulesShareIDArray objectAtIndex:i], [_accessRulesNamesArray objectAtIndex:i], [_accessRulesSiteTypeNameArray objectAtIndex:i], nil];
                    NSDictionary *accessRuleDictionary = [[NSDictionary alloc] initWithObjects:valuesArray forKeys:keysArray];
                    [_accessRulesEnabledArray addObject:accessRuleDictionary];
                    break;
                }
            }
        }
    }
    NSLog(@"Inside accessRulesListViewController, performListCall where accessRulesEnabled are %@", _accessRulesEnabledArray);

}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
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
    else if ([[segue identifier] isEqualToString:@"goToFilesFromTableViewCell"]){
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        selectedRow = indexPath.row;
        NSDictionary *selectedAccessRuleDictionary = [[NSDictionary alloc] initWithDictionary:[_list objectAtIndex:selectedRow]];
        
        UINavigationController *navigationController    = segue.destinationViewController;
        shareDetailViewController *wvc                  = [[navigationController viewControllers] objectAtIndex:0];
        
        [wvc setShareID:[selectedAccessRuleDictionary valueForKey:@"AccessRuleShareID"]];
        [wvc setFolderName:[selectedAccessRuleDictionary valueForKey:@"AccessRuleName"]];
        [wvc setSessionKey:_sessionKey];
        wvc.selectedShareID = [selectedAccessRuleDictionary valueForKey:@"AccessRuleShareID"];
        wvc.selectedShareName = [selectedAccessRuleDictionary valueForKey:@"AccessRuleName"];
    }
    else if([[segue identifier] isEqualToString:@"addConnection"]){
        // newConnectionViewController* ncvc = [segue destinationViewController];
        // [ncvc setUserStorageInput:_userStorageInput];
        // [ncvc setSessionKey:_sessionKey];
        // [ncvc setSiteTypeID:[_storageIDs objectAtIndex:i]];
        // [ncvc setAllPossibleConnections:_allPossibleConnections];
        // [ncvc setRequestedConnectionName:requestedConnectionName];
    }

}

@end
