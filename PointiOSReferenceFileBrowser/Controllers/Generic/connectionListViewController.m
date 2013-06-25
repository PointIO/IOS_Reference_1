//
//  connectionListViewController.m
//  PointiOSReferenceFileBrowser
//
//  Created by jimmyboyle on 6/15/13.
//  Copyright (c) 2013 PointIO. All rights reserved.
//

#import "connectionListViewController.h"
#import "StorageViewController.h"
#import "ConnectionListCell.h"
#import "Common.h"
#import <QuartzCore/QuartzCore.h>

@interface connectionListViewController () {
    NSInteger row;
    NSString* storageName;
}
@end

int i;
NSString *requestedConnectionName;

@implementation connectionListViewController

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
    _list = [NSMutableArray array];
    
    // JB 6/25/13 Comment all enable/disabled code
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enableBackButton:)
                                                 name:@"enableBackButton"
                                               object:nil];
    */

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
         for (i=0; i<[_storageSitesArrayOfDictionaries count]; i++) {
            NSArray *storageSiteItem;
            storageSiteItem = [_storageSitesArrayOfDictionaries objectAtIndex:i];
            [_list addObject:storageSiteItem];
        }
    }
}

- (void) viewDidAppear:(BOOL)animated{
    _userStorageInput = nil;
    /*
    if(!_appDel.connectionsTypesAndEnabledStates) {
        _appDel.connectionsTypesAndEnabledStates = [[NSMutableDictionary alloc] init];
    }
    for(int i = [_list count]-1; i >=0; i--){
        NSDictionary* tempDict = [NSDictionary dictionaryWithObject:[_appDel.enabledConnections objectAtIndex:i]
                                                             forKey:[_list objectAtIndex:i]];
        [_appDel.connectionsTypesAndEnabledStates addEntriesFromDictionary:tempDict];
    }
    NSLog(@"Inside ViewDidAppear CONNECTION TYPES AND ENABLED STATES = %@",_appDel.connectionsTypesAndEnabledStates);
    */
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ConnectionListCell *cell = (ConnectionListCell *)[tableView dequeueReusableCellWithIdentifier:@"ConnectionListCell"];
    
    UISwitch *statusSwitch = [[UISwitch alloc] init];
    cell.accessoryView = statusSwitch;

    NSDictionary* result = [_JSONArrayList valueForKey:@"RESULT"];
    NSArray* columns = [result valueForKey:@"COLUMNS"];
    NSArray* data = [result valueForKey:@"DATA"];
    
    row = indexPath.row;
    cell.nameLabel.text = [[_list objectAtIndex:indexPath.row] valueForKey:@"StorageSiteName"];
    
    // cell.nameLabel.text = [[_list objectAtIndex:indexPath.row] stringValue];
    
    for(int i=0; i<[data count];i++){
        NSArray* data2 = [data objectAtIndex:i];
        _sharedFolderData = [NSDictionary dictionaryWithObjects:data2 forKeys:columns];

        /*
        if(!_appDel.connectionsNameAndTypes){
            _appDel.connectionsNameAndTypes = [[NSMutableDictionary alloc] init];
        }

        NSDictionary* tempDict = [NSDictionary dictionaryWithObject:[_sharedFolderData valueForKey:@"SITETYPENAME"] forKey:[_sharedFolderData valueForKey:@"NAME"]];
        // [_appDel.connectionsNameAndTypes addEntriesFromDictionary:tempDict];

         if([[_appDel.connectionsTypesAndEnabledStates valueForKey:[_list objectAtIndex:indexPath.row]] integerValue] == 1){
            NSLog(@"%@ should be on",[_list objectAtIndex:indexPath.row]);
            statusSwitch.on = YES;
        } else {
            statusSwitch.on = NO;
        }
        */
    }
    
    // [statusSwitch addTarget:self action:@selector(valueChanged:withIndex:) forControlEvents:UIControlEventValueChanged];

    return cell;
    
}

#pragma mark
#pragma Core Graphics

-(UIColor*)colorForIndex:(NSInteger) index
{
    NSUInteger itemCount = [_list count];
    return [Common theColor:index:itemCount];
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [self colorForIndex:indexPath.row];
}


#pragma mark - Business Logic
- (IBAction)valueChanged:(id) sender withIndex:(NSInteger) index{
    
    UISwitch *controlSwitch = sender;
    // UITableViewCell *myCell = [controlSwitch superview];
    NSLog(@"Index is %i",index);
    ConnectionListCell *myCell = (ConnectionListCell*)[sender superview];

    NSLog(@"My cell  %@",myCell);
    storageName = myCell.nameLabel.text;
    NSLog(@"Storage name = %@",storageName);
    UITableView* tableView = (UITableView*)[myCell superview];
    NSIndexPath* path = [tableView indexPathForCell:myCell];
    row = path.row;
    if (controlSwitch.isOn) {
        [_appDel.enabledConnections setObject:@"1" atIndexedSubscript:row];
        [_appDel.connectionsTypesAndEnabledStates setObject:@"1" forKey:storageName];
    }
    
    if(!controlSwitch.isOn){
        [_appDel.enabledConnections setObject:@"0" atIndexedSubscript:row];
        [_appDel.connectionsTypesAndEnabledStates setObject:@"0" forKey:storageName];
    }
    
    NSString* temp = [[NSString alloc] init];
    for(int i = 0;i < [_list count];i++){
        if([[_appDel.enabledConnections objectAtIndex:i] isEqualToString:@"1"]){
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
    
    NSLog(@"APPDEL CONNECTIONS ENABLED STATES = %@",_appDel.connectionsTypesAndEnabledStates);
    
    [[NSUserDefaults standardUserDefaults] setObject:temp forKey:@"ENABLEDCONNECTIONS"];
    [[NSUserDefaults standardUserDefaults] setObject:_appDel.connectionsNameAndTypes forKey:@"NAMETYPES"];
    [[NSUserDefaults standardUserDefaults] setObject:_appDel.connectionsTypesAndEnabledStates forKey:@"ENABLEDTYPES"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [TestFlight passCheckpoint:@"User changed enabled connections value"];
}

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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void) viewWillAppear:(BOOL)animated{
    [self.tableView reloadData];
}

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
