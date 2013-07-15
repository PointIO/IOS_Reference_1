//
//  storageSitesListViewController.m
//  PointiOSReferenceFileBrowser
//
//  Created by jb on 6/25/13.
//  Copyright (c) 2013 PointIO. All rights reserved.
//

#import "storageSitesListViewController.h"
#import "StorageViewController.h"
#import "StorageConnectionListCell.h"
#import "Common.h"
#import <QuartzCore/QuartzCore.h>
#import "StorageTypesViewController.h"



@interface storageSitesListViewController () {
    NSInteger row;
    NSString* storageName;
}
@end

int i;
NSString *requestedConnectionName;

@implementation storageSitesListViewController

{
    CAGradientLayer* _gradientLayer;
}



- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}


- (void) viewWillAppear:(BOOL)animated{
    if (_sessionKey == nil) {
        _storageSiteTypesInUse = [[NSMutableArray alloc] init];
        _storageSitesArrayOfDictionaries = [[NSMutableArray alloc] init];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Not Logged In, Please Login First"
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else {
        _storageSiteTypesInUse = [[NSMutableArray alloc] init];
        _storageSitesArrayOfDictionaries = [[NSMutableArray alloc] init];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
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
                
                [self performListCall];
                
                NSMutableArray *temp = [[NSMutableArray alloc] init];
                NSMutableArray *tmpArrayOfDictionaries = [[NSMutableArray alloc] init];
                
                NSString *firstStorageSiteID = [[[_storageSitesArrayOfDictionaries objectAtIndex:0] valueForKey:@"StorageSiteSiteTypeID"] stringValue];
                [tmpArrayOfDictionaries addObject:[_storageSitesArrayOfDictionaries objectAtIndex:0]];
                [temp addObject:firstStorageSiteID];
                
                for(int i=0; i<[_storageSitesArrayOfDictionaries count];i++){
                    NSString *storageSiteID = [[[_storageSitesArrayOfDictionaries objectAtIndex:i] valueForKey:@"StorageSiteSiteTypeID"] stringValue];
                    if (![temp containsObject: storageSiteID]) {
                        [temp addObject:[[[_storageSitesArrayOfDictionaries objectAtIndex:i] valueForKey:@"StorageSiteSiteTypeID"] stringValue]];
                        [tmpArrayOfDictionaries addObject:[_storageSitesArrayOfDictionaries objectAtIndex:i]];
                    }
                }
                
                NSSortDescriptor *nameDescriptor =
                [[NSSortDescriptor alloc] initWithKey:@"StorageSiteSiteTypeName"
                                            ascending:YES
                                             selector:@selector(localizedCaseInsensitiveCompare:)];
                
                NSArray *descriptors = [NSArray arrayWithObjects:nameDescriptor, nil];
                NSArray *sortedArray = [tmpArrayOfDictionaries sortedArrayUsingDescriptors:descriptors];
                _storageSiteTypesInUse = sortedArray;
                NSLog(@"Sorted StorageTypesInUse is %@", _storageSiteTypesInUse);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self.tableView reloadData];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                });
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_storageSiteTypesInUse count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StorageConnectionListCell *cell = (StorageConnectionListCell *)[tableView dequeueReusableCellWithIdentifier:@"StorageConnectionListCell"];
    
    // set Cell Name
    NSString *tmpSiteName = [[_storageSiteTypesInUse objectAtIndex:indexPath.row] valueForKey:@"StorageSiteSiteTypeName"];
    cell.nameLabel.text = tmpSiteName;
    
    // Set Cell Image
    // Values are stored in sorted Dictionary in AppContent.plist
    NSString *tmpFileName               = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"AppContent"];
    NSString *tmpFilePath               = [[NSBundle mainBundle] pathForResource:tmpFileName ofType:@"plist"];
    NSMutableDictionary *tmpDictionary  = [[NSMutableDictionary alloc] initWithContentsOfFile:tmpFilePath];
    NSDictionary *cloudProviderDict     = [tmpDictionary valueForKey:@"storageProviderArtwork"];
    NSString *tmpImageName  = [cloudProviderDict valueForKey:tmpSiteName];
    cell.storageImage.image = [UIImage imageNamed:tmpImageName];

    return cell;
}



#pragma mark
#pragma Core Graphics

-(UIColor*)colorForIndex:(NSInteger) index
{
    NSUInteger itemCount = [_storageSiteTypesInUse count];
    return [Common theColor:index:itemCount];
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [self colorForIndex:indexPath.row];
}


#pragma mark - Business Logic

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}


#pragma mark - Segue
- (void) goToStorage {
    [self performSegueWithIdentifier:@"goToStorage" sender:self];
}


- (void) performListCall{
    
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
    NSLog(@"Inside storageSitesListViewController, performListCall where storageSites are %@", storageSitesArray);
    
    
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
        [_storageSitesArrayOfDictionaries addObject:storageSiteDictionary];
    }
    
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"addConnection"]){
        StorageTypesViewController * ncvc = [segue destinationViewController];
        [ncvc setSessionKey:_sessionKey];
    }
}

/*
- (void) getAllPossibleConnections{
    //
    // called by addConnection
    //
    NSMutableArray* tempy = [NSMutableArray array];
    NSURLResponse* urlResponseList;
    NSError* requestErrorList;
    _storageIDs = [NSMutableArray array];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://api.point.io/api/v2/storagetypes/list.json"]];
    [request setHTTPMethod:@"GET"];
    NSLog(@"Session key = %@",_sessionKey);
    [request addValue:_sessionKey forHTTPHeaderField:@"Authorization"];
    NSData* response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponseList error:&requestErrorList];
    
    if(!response){
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Request response is nil" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
    } else {
        NSArray* availableConnectionsArray = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
        if([[availableConnectionsArray valueForKey:@"ERROR"] integerValue] == 0){
            NSArray* result = [availableConnectionsArray valueForKey:@"RESULT"];
            NSArray* columns = [result valueForKey:@"COLUMNS"];
            NSArray* data = [result valueForKey:@"DATA"];
            for (int i = 0; i<[data count]; i++) {
                NSArray* data2 = [data objectAtIndex:i];
                NSDictionary* temp = [NSDictionary dictionaryWithObjects:data2 forKeys:columns];
                NSLog(@"TEMP LIST = %@",temp);
                if([[temp valueForKey:@"ENABLED"] integerValue] == 1){
                    [tempy addObject:[temp valueForKey:@"SITETYPENAME"]];
                    [_storageIDs addObject:[temp valueForKey:@"SITETYPEID"]];
                }
            }
            NSLog(@"ALL STORAGE IDs = %@",_storageIDs);
            _allPossibleConnections = [NSMutableArray arrayWithArray:tempy];
        }
    }
}
*/




@end
