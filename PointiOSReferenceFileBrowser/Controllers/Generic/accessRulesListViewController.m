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
    
    
}

- (void) viewWillDisappear:(BOOL)animated{
}

- (void) viewDidDisappear:(BOOL)animated{
}

- (void) viewWillAppear:(BOOL)animated{
    
    if (_sessionKey == nil) {
        _list = [[NSMutableArray alloc] init];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Not Logged In, Please Login First"
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else {
        _list = [[NSMutableArray alloc] init];
        _accessRulesEnabledArray = [[NSMutableArray alloc] init];
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            [self performListCall];
            
            if (![_accessRulesEnabledArray count]==0){
                for (i=0; i<[_accessRulesEnabledArray count]; i++) {
                    NSArray *accessRuleItem;
                    accessRuleItem = [_accessRulesEnabledArray objectAtIndex:i];
                    [tempArray addObject:accessRuleItem];
                }
                
                NSSortDescriptor *nameDescriptor =
                [[NSSortDescriptor alloc] initWithKey:@"AccessRuleShareName"
                                            ascending:YES
                                             selector:@selector(localizedCaseInsensitiveCompare:)];
                
                NSMutableArray *descriptors = [NSArray arrayWithObjects:nameDescriptor, nil];
                NSMutableArray *sortedArray = [tempArray sortedArrayUsingDescriptors:descriptors];
                _list = sortedArray;
                NSLog(@"Sorted Access Rules is %@", _list);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self.tableView reloadData];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                });
                /*
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"There are no enabled shares"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Dismiss"
                                                      otherButtonTitles:nil];
                [alert show];
                */
            }
        });
    }
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
        NSString *tmpImageName              = [cloudProviderDict valueForKey:storageSiteSiteName];
        cell.storageImage.image             = [UIImage imageNamed:tmpImageName];
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
    /*
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
    */
    
    //
    // get storageSites
    //
    NSMutableArray *storageSitesArray = [[NSMutableArray alloc] init];
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
        storageSitesArray = [NSJSONSerialization JSONObjectWithData:response2 options:NSJSONReadingMutableContainers error:nil];
    }
    NSLog(@"Inside accessRulesListViewController, performListCall where storageSites are %@", storageSitesArray);
    
    
    //
    // create storageSites Arrays for Names, IDs, Enabled Status, SiteTypeID and SiteTypeName
    //
    NSDictionary *resultStorageSitesDictionary = [storageSitesArray valueForKey:@"RESULT"];
    NSArray *resultColumns = [resultStorageSitesDictionary valueForKey:@"COLUMNS"];
    NSArray *resultData = [resultStorageSitesDictionary valueForKey:@"DATA"];
    
    NSMutableArray *storageSitesNamesArray = [[NSMutableArray alloc] init];
    NSMutableArray *storageSitesIDsArray = [[NSMutableArray alloc] init];
    NSMutableArray *storageSitesEnabledStatusArray = [[NSMutableArray alloc] init];
    NSMutableArray *storageSitesSiteTypeNameArray = [[NSMutableArray alloc] init];
    NSMutableArray *storageSitesSiteTypeIDArray = [[NSMutableArray alloc] init];
    NSMutableArray *storageSitesArrayOfDictionaries = [[NSMutableArray alloc] init];
    
    for(int i=0; i<[resultData count];i++){
        NSArray* data2 = [resultData objectAtIndex:i];
        NSDictionary* temp = [NSDictionary dictionaryWithObjects:data2 forKeys:resultColumns];
        [storageSitesIDsArray addObject:[temp valueForKey:@"SITEID"]];
        [storageSitesNamesArray addObject:[temp valueForKey:@"NAME"]];
        [storageSitesEnabledStatusArray addObject:[temp valueForKey:@"ENABLED"]];
        [storageSitesSiteTypeIDArray addObject:[temp valueForKey:@"SITETYPEID"]];
        [storageSitesSiteTypeNameArray addObject:[temp valueForKey:@"SITETYPENAME"]];
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
                                [storageSitesIDsArray objectAtIndex:i],
                                [storageSitesNamesArray objectAtIndex:i],
                                [storageSitesEnabledStatusArray objectAtIndex:i],
                                [storageSitesSiteTypeIDArray objectAtIndex:i],
                                [storageSitesSiteTypeNameArray objectAtIndex:i],
                                nil];
        
        NSDictionary *storageSiteDictionary = [[NSDictionary alloc] initWithObjects:valuesArray forKeys:keysArray];
        [storageSitesArrayOfDictionaries addObject:storageSiteDictionary];
    }
    
    //
    // get accessRules
    //
    NSMutableArray *accessRulesArray = [[NSMutableArray alloc] init];
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
        accessRulesArray = [NSJSONSerialization JSONObjectWithData:response3 options:NSJSONReadingMutableContainers error:nil];
    }
    NSLog(@"Inside accessRulesListViewController, performListCall where accessRules are %@", accessRulesArray);
    
    
    //
    // create Dictionary of AccessRulesName, AccessRuleID, AccessRuleEnabled Status
    //
    NSDictionary *resultAccessRulesDictionary = [accessRulesArray valueForKey:@"RESULT"];
    NSArray *resultColumns1 = [resultAccessRulesDictionary valueForKey:@"COLUMNS"];
    NSArray *resultData1 = [resultAccessRulesDictionary valueForKey:@"DATA"];
    
    NSMutableArray *accessRulesNamesArray = [[NSMutableArray alloc] init];
    NSMutableArray *accessRulesShareIDArray = [[NSMutableArray array] init];
    NSMutableArray *accessRulesSiteIDArray = [[NSMutableArray array] init];
    NSMutableArray *accessRulesSiteTypeNameArray = [[NSMutableArray array] init];
    
    for(int i=0; i<[resultData1 count];i++){
        NSArray* data2 = [resultData1 objectAtIndex:i];
        NSDictionary* temp = [NSDictionary dictionaryWithObjects:data2 forKeys:resultColumns1];
        [accessRulesNamesArray addObject:[temp valueForKey:@"SHARENAME"]];
        [accessRulesShareIDArray addObject:[temp valueForKey:@"SHAREID"]];
        [accessRulesSiteIDArray addObject:[temp valueForKey:@"SITEID"]];
        [accessRulesSiteTypeNameArray addObject:[temp valueForKey:@"SITETYPENAME"]];
        //
        // evaluate _storageSitesIDArray until finding a matching siteID, then determine if enabled or disabled
        //
        for(int j=0; j<[storageSitesIDsArray count];j++){
            if ([[accessRulesSiteIDArray objectAtIndex:i] isEqualToString:[storageSitesIDsArray objectAtIndex:j]]) {
                NSString *storageSiteEnabledStatus = [[storageSitesEnabledStatusArray objectAtIndex:j] stringValue];
                if ([storageSiteEnabledStatus isEqualToString:@"1"]) {
                    
                    NSArray *keysArray = [[NSArray alloc] initWithObjects:@"AccessRuleShareID",@"AccessRuleShareName", @"AccessRuleSiteTypeName", nil];
                    NSArray *valuesArray = [[NSArray alloc] initWithObjects:[accessRulesShareIDArray objectAtIndex:i], [accessRulesNamesArray objectAtIndex:i], [accessRulesSiteTypeNameArray objectAtIndex:i], nil];
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
}

@end
