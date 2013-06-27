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
    
    _appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    _storageSiteTypesInUse = [[NSMutableArray alloc] init];
     
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
        
        _storageSiteTypesInUse = [[NSArray alloc] init];
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
    }
}


- (void) viewDidAppear:(BOOL)animated{
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
    /*
    NSString *tmpFileName               = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"AppContent"];
    NSString *tmpFilePath               = [[NSBundle mainBundle] pathForResource:tmpFileName ofType:@"plist"];
    NSMutableDictionary *tmpDictionary  = [[NSMutableDictionary alloc] initWithContentsOfFile:tmpFilePath];
    NSDictionary *cloudProviderDict     = [[tmpDictionary valueForKey:@"cloudProviders"] objectAtIndex:indexPath.row];
    NSString *tmpImageName  = [cloudProviderDict valueForKey:@"cloudProviderArtwork"];
    cell.storageImage.image = [UIImage imageNamed:tmpImageName];
    */
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

/*
- (IBAction)addConnectionPressed:(id)sender {
    [self getAllPossibleConnections];
    if([_allPossibleConnections count] != 0){
        _alert	= [[SBTableAlert alloc] initWithTitle:@"Choose a connection" cancelButtonTitle:@"Cancel" messageFormat:nil];
        [_alert.view setTag:2];
        [_alert setStyle:SBTableAlertStyleApple];
        [_alert setDelegate:self];
        [_alert setDataSource:self];
        UIImageView* temp = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 286, 271)];
        temp.image = [UIImage imageNamed:@"connectionsAlertView"];
        [_alert.view addSubview:temp];
        [_alert show];
        _userKeys = [NSMutableArray array];
        _userValues = [NSMutableArray array];
    } else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There are no available connections for you" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        UIImageView* alertCustomView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 0, 280, 154)];
        alertCustomView.image = [UIImage imageNamed:@"noAvailableConnections.png"];
        [alert addSubview:alertCustomView];
        [alert show];
    }
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void) viewWillAppear:(BOOL)animated{
    [self.tableView reloadData];
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


#pragma mark - Segue
- (void) goToStorage {
    [self performSegueWithIdentifier:@"goToStorage" sender:self];
}

- (UITableViewCell *)tableAlert:(SBTableAlert *)tableAlert cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
    
	if (tableAlert.view.tag == 0 || tableAlert.view.tag == 1) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ConnectionCell"];
	} else {
		// Note: SBTableAlertCell
		cell = [[SBTableAlertCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
	}
	
    if(indexPath.row == [_allPossibleConnections count] || indexPath.row > [_allPossibleConnections count]){
        [cell.textLabel setText:@""];
    } else {
        [cell.textLabel setText:[_allPossibleConnections objectAtIndex:indexPath.row]];
	}
	return cell;
}

- (NSInteger)tableAlert:(SBTableAlert *)tableAlert numberOfRowsInSection:(NSInteger)section {
    if([_allPossibleConnections count] < 4){
        return 4;
    } else {
        return [_allPossibleConnections count];
    }
}

- (NSInteger)numberOfSectionsInTableAlert:(SBTableAlert *)tableAlert {
    return 1;
}

- (NSString *)tableAlert:(SBTableAlert *)tableAlert titleForHeaderInSection:(NSInteger)section {
    return nil;
}

#pragma mark - SBTableAlertDelegate

- (void)tableAlert:(SBTableAlert *)tableAlert didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    tableAlert.view.alpha = 0;
    if(indexPath.row == [_allPossibleConnections count] || indexPath.row > [_allPossibleConnections count]){
        
    } else {
        i = indexPath.row;
        NSLog(@"SITE TYPE ID = %@",[_storageIDs objectAtIndex:indexPath.row]);
        requestedConnectionName = [_allPossibleConnections objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"addConnection" sender:self];
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"addConnection"]){
        newConnectionViewController* ncvc = [segue destinationViewController];
        [ncvc setUserStorageInput:_userStorageInput];
        [ncvc setSessionKey:_sessionKey];
        [ncvc setSiteTypeID:[_storageIDs objectAtIndex:i]];
        [ncvc setAllPossibleConnections:_allPossibleConnections];
        [ncvc setRequestedConnectionName:requestedConnectionName];
    }
    else if([segue.identifier isEqualToString:@"goToStorage"]){
        // storageViewController *svc = [segue destinationViewController];
        // [svc setText:storageName];
    }
}



@end
