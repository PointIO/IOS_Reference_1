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


@interface connectionListViewController () {
    NSInteger row;
    NSString* storageName;
}
@end

int i;
NSString *requestedConnectionName;

@implementation connectionListViewController


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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enableBackButton:)
                                                 name:@"enableBackButton"
                                               object:nil];
    
    if(![self isConnectedToInternet]){
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
        NSDictionary* result    = [_JSONArrayList valueForKey:@"RESULT"];
        NSArray* columns        = [result valueForKey:@"COLUMNS"];
        NSDictionary* result2   = [_JSONArrayList valueForKey:@"RESULT"];
        NSArray* data           = [result2 valueForKey:@"DATA"];
        for(int i=0; i<[data count];i++){
            NSArray* data2 = [data objectAtIndex:i];
            _sharedFolderData = [NSDictionary dictionaryWithObjects:data2 forKeys:columns];
            [_list addObject:[_sharedFolderData valueForKey:@"SITETYPENAME"]];
        }
        [_list setArray:[[NSSet setWithArray:_list] allObjects]];
    }
    
    if(!_appDel.enabledConnections){
        _appDel.enabledConnections = [NSMutableArray array];
    }
    for(int i = 0;i<[_list count];i++){
        [_appDel.enabledConnections addObject:@"0"];
    }

}

- (void) viewDidAppear:(BOOL)animated{
    _userStorageInput = nil;
    if(!_appDel.connectionsTypesAndEnabledStates) {
        _appDel.connectionsTypesAndEnabledStates = [[NSMutableDictionary alloc] init];
    }
    for(int i = [_list count]-1; i >=0; i--){
        NSDictionary* tempDict = [NSDictionary dictionaryWithObject:[_appDel.enabledConnections objectAtIndex:i]  forKey:[_list objectAtIndex:i]];
        [_appDel.connectionsTypesAndEnabledStates addEntriesFromDictionary:tempDict];
    }
    NSLog(@"CONNECTION TYPES AND ENABLED STATES = %@",_appDel.connectionsTypesAndEnabledStates);

}


/*
- (void) getConnections{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^
    {
        NSURLResponse* urlResponseList;
        NSError* requestErrorList;
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        
        [request setURL:[NSURL URLWithString:@"https://api.point.io/api/v2/storagesites/list.json"]];
        
        [request setHTTPMethod:@"GET"];
        [request addValue:_sessionKey forHTTPHeaderField:@"Authorization"];
        NSData* response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponseList error:&requestErrorList];
        
        if(!response) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Request response is nil"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles: nil];
            [alert show];
        }
        else {
            
            _JSONArrayList = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"JSON ARRAY LIST = %@",_JSONArrayList);
            _connectionSharedFolders = nil;
            _list = nil;
            _displayList = nil;
            _list = [NSMutableArray array];
            _allPossibleConnections = [NSMutableArray array];
            _storageIDs = [NSMutableArray array];
            _displayList  = [NSMutableArray array];
            _connectionSharedFolders = [NSMutableArray array];
            
            // self.navigationItem.backBarButtonItem.title = @"Back";
            
            NSDictionary* result = [_JSONArrayList valueForKey:@"RESULT"];
            NSArray* columns = [result valueForKey:@"COLUMNS"];
            NSArray* data = [result valueForKey:@"DATA"];
            NSDictionary* tempDict;
            
            for(int i=0; i<[data count];i++){
                NSArray* data2 = [data objectAtIndex:i];
                NSDictionary* temp = [NSDictionary dictionaryWithObjects:data2 forKeys:columns];
                NSLog(@"NEW TEMP = %@",temp);
                [_list addObject:[temp valueForKey:@"SITETYPENAME"]];
                tempDict = [NSDictionary dictionaryWithObject:[temp valueForKey:@"NAME"] forKey:[temp valueForKey:@"SITETYPENAME"]];
                
                [_connectionSharedFolders addObject:tempDict];
            }
            
            [self getAllPossibleConnections];
            
            NSArray* tempCpy = [NSArray arrayWithArray:_list];
            
            [_list setArray:[[NSSet setWithArray:_list] allObjects]];
            
            if([tempCpy count] - [_list count] == 1){
                if([_appDel.enabledConnections count] - [_list count] == 1){
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"removeOneIndex" object:nil];
                }
            }
            
            if([_appDel.enabledConnections count] == 0 || ([_appDel.enabledConnections count] != [_list count])){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"getEnabledStates" object:nil];
            }
            
            if([_appDel.enabledConnections count] != [_list count]){
                _appDel.enabledConnections = nil;
                _appDel.enabledConnections = [NSMutableArray array];
                
                for(int i = 0; i< [_list count];i++){
                    [_appDel.enabledConnections addObject:@"1"];
                }
            }
            
            _displayList = [NSMutableArray array];
            for (int i = 0; i < [_list count];i++){
                if([[_appDel.enabledConnections objectAtIndex:i] integerValue] == 1){
                    [_displayList addObject:[_list objectAtIndex:i]];
                    // NSLog(@"from getConnections, displayList array contents are: %@", _displayList);
                }
            }
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"enableBackButton" object:nil];
                [self.tableView reloadData];
            });
        }
    });
}
*/


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
    cell.nameLabel.text = [_list objectAtIndex:indexPath.row];
    
    for(int i=0; i<[data count];i++){
        NSArray* data2 = [data objectAtIndex:i];
        _sharedFolderData = [NSDictionary dictionaryWithObjects:data2 forKeys:columns];
//        NSLog(@"Connections user data is %@", _sharedFolderData);
        if(!_appDel.connectionsNameAndTypes){
            _appDel.connectionsNameAndTypes = [[NSMutableDictionary alloc] init];
        }
        NSDictionary* tempDict = [NSDictionary dictionaryWithObject:[_sharedFolderData valueForKey:@"SITETYPENAME"] forKey:[_sharedFolderData valueForKey:@"NAME"]];
        [_appDel.connectionsNameAndTypes addEntriesFromDictionary:tempDict];
        if([[_appDel.connectionsTypesAndEnabledStates valueForKey:[_list objectAtIndex:indexPath.row]] integerValue] == 1){
            NSLog(@"%@ should be on",[_list objectAtIndex:indexPath.row]);
            statusSwitch.on = YES;
        } else {
            statusSwitch.on = NO;
        }
    }
    
    [statusSwitch addTarget:self action:@selector(valueChanged:withIndex:) forControlEvents:UIControlEventValueChanged];

    return cell;
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Business Logic
- (IBAction)valueChanged:(id) sender withIndex:(NSInteger) index{
    UISwitch *controlSwitch = sender;
    // UITableViewCell *myCell = [controlSwitch superview];
    NSLog(@"Index is %i",index);
    ConnectionListCell *myCell = (ConnectionListCell*)[sender superview];
    // storageName = myCell.textLabel.text;
    // JB Crashing - needs more work here
    NSLog(@"My cell  %@",myCell);
    storageName = myCell.nameLabel.text;
    NSLog(@"Storage name = %@",storageName);
    UITableView* tableView = (UITableView*)[myCell superview];
    NSIndexPath* path = [tableView indexPathForCell:myCell];
    row = path.row;
    if (controlSwitch.isOn) {
        [_appDel.enabledConnections setObject:@"1" atIndexedSubscript:row];
        [_appDel.connectionsTypesAndEnabledStates setObject:@"1" forKey:storageName];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLists" object:nil];
        // self.navigationItem.hidesBackButton = YES;
        // imgView2.alpha = 0.5;
//        NSLog(@"ENABLED CONNECTIONS IS NOW %@",_appDel.enabledConnections);
    }
    if(!controlSwitch.isOn){
        [_appDel.enabledConnections setObject:@"0" atIndexedSubscript:row];
        [_appDel.connectionsTypesAndEnabledStates setObject:@"0" forKey:storageName];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLists" object:nil];
        // self.navigationItem.hidesBackButton = YES;
        // imgView2.alpha = 0.5;
//        NSLog(@"ENABLED CONNECTIONS IS NOW %@",_appDel.enabledConnections);
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
    
    // cell.nameLabel.text = [_list objectAtIndex:indexPath.row];
    // [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    // [self performSegueWithIdentifier:@"goToStorage" sender:self];
}

- (void) viewWillAppear:(BOOL)animated{
    [self.tableView reloadData];
}

- (void) getAllPossibleConnections{
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
    /*
    else if([[segue identifier] isEqualToString:@"addConnection"]){
        newConnectionViewController* ncvc = [segue destinationViewController];
        [ncvc setUserStorageInput:_userStorageInput];
        [ncvc setSessionKey:_sessionKey];
        [ncvc setSiteTypeID:[_storageIDs objectAtIndex:i]];
        [ncvc setAllPossibleConnections:_allPossibleConnections];
        [ncvc setRequestedConnectionName:requestedConnectionName];
    }
    */
}


- (BOOL) isConnectedToInternet{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}
@end
