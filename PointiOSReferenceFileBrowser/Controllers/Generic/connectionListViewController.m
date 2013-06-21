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
        NSLog(@"Connections user data is %@", _sharedFolderData);
        if([[_appDel.enabledConnections objectAtIndex:indexPath.row] integerValue] == 1){
            cell.statusSwitch.on = YES;
        } else {
            cell.statusSwitch.on = NO;
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
    // ConnectionListCell *myCell = (ConnectionListCell *)[controlSwitch superview];
    //
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(ConnectionListCell *)[sender superview]];
    row = indexPath.row;
    storageName = [_list objectAtIndex:row];
    
    NSLog(@"ROW IS %i",row);
    if (controlSwitch.isOn) {
        [_appDel.enabledConnections setObject:@"1" atIndexedSubscript:row];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLists" object:nil];
        // self.navigationItem.hidesBackButton = YES;
        // imgView2.alpha = 0.5;
        NSLog(@"ENABLED CONNECTIONS IS NOW %@",_appDel.enabledConnections);
    }
    if(!controlSwitch.isOn){
        [_appDel.enabledConnections setObject:@"0" atIndexedSubscript:row];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLists" object:nil];
        // self.navigationItem.hidesBackButton = YES;
        // imgView2.alpha = 0.5;
        NSLog(@"ENABLED CONNECTIONS IS NOW %@",_appDel.enabledConnections);
    }
    NSString* temp = [[NSString alloc] init];
    for(int i = 0;i < [_appDel.enabledConnections count];i++){
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
    [[NSUserDefaults standardUserDefaults] setObject:temp forKey:@"ENABLEDCONNECTIONS"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // [TestFlight passCheckpoint:@"User changed enabled connections value"];
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


#pragma mark - Segue
- (void) goToStorage {
    [self performSegueWithIdentifier:@"goToStorage" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"goToStorage"]){
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
