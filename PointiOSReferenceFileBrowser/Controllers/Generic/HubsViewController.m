//
//  HubsViewController.m
//  point.io
//
//  Created by Constantin Lungu on 6/3/13.
//  Copyright (c) 2013 FusionWorks. All rights reserved.
//

#import "HubsViewController.h"
#import "Common.h"


@implementation HubsViewController

UIImageView* imgView2;
int i;
BOOL manageHubsPressed;
NSDictionary* sitesAndShareIDs;

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    if ( [(NSString*)[UIDevice currentDevice].model isEqualToString:@"iPad"] ) {
        //        return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
        return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
    } else {
        if(toInterfaceOrientation == UIInterfaceOrientationPortrait){
            return YES;
        } else {
            return NO;
        }
    }
}

- (void) viewDidLoad{
    _appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    manageHubsPressed = NO;
    _centralBorderBar.alpha = 0;
    _activeUsersTableView.alpha = 0;
    _activeStorageConnectionsTableView.alpha = 0;
    _foldersInHubTableView.alpha = 0;
    _permissionsTableView.alpha = 0;
    _viewActivityButton.alpha = 0;
    _viewFilesButton.alpha = 0;
    _viewUsersButton.alpha = 0;
    _removeHubButton.alpha = 0;
    _hubNameLabel.alpha = 0;
    _horizontalBorderBar.alpha = 0;
    _sharedFoldersTableView.frame = CGRectMake(321, 0, _sharedFoldersTableView.frame.size.width, _sharedFoldersTableView.frame.size.height);
    _hubsTableView.frame = CGRectMake(0, 0, _hubsTableView.frame.size.width, _hubsTableView.frame.size.height);
    _manageHubsButton.enabled = NO;
    
    if(![Common isConnectedToInternet]){
        UIAlertView* err = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Looks like there is no internet connection, please check the settings" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        UIImageView* temp = [[UIImageView alloc] initWithFrame:CGRectMake(2, 0, 280, 174)];
        temp.image = [UIImage imageNamed:@"noInternetConnection.png"];
        [err addSubview:temp];
        [err setBackgroundColor:[UIColor clearColor]];
        [err show];
    } else {
    _hubsTableView.delegate = self;
    _hubsTableView.dataSource = self;
    _sharedFoldersTableView.delegate = self;
    _sharedFoldersTableView.dataSource = self;
    _activeUsersTableView.delegate = self;
    _activeUsersTableView.dataSource = self;
    _activeStorageConnectionsTableView.delegate = self;
    _activeStorageConnectionsTableView.dataSource = self;
    _foldersInHubTableView.delegate = self;
    _foldersInHubTableView.dataSource = self;
    _permissionsTableView.delegate = self;
    _permissionsTableView.dataSource = self;
    
    _sharedFoldersTableView.alpha = 0;
    [MBProgressHUD showHUDAddedTo:self.hubsTableView animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self getConnections];
        [self getHubActiveUsers];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.hubsTableView animated:YES];
            [_hubsTableView reloadData];
            });
        });
    }
}

- (void) getConnections{
    NSURLResponse* urlResponseList;
    NSError* requestErrorList;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://api.point.io/api/v2/storagesites/list.json"]];
    [request setHTTPMethod:@"GET"];
    [request addValue:_appDel.sessionKey forHTTPHeaderField:@"Authorization"];
    NSData* response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponseList error:&requestErrorList];
    if(!response){
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Request response is nil" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
    } else {
        _JSONArrayList = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
        _connectionSharedFolders = nil;
        _list = nil;
        _displayList = nil;
        NSMutableArray* shareIDs = [NSMutableArray array];
        _list = [NSMutableArray array];
        _storageIDs = [NSMutableArray array];
        _displayList  = [NSMutableArray array];
        _connectionSharedFolders = [NSMutableArray array];
        self.navigationItem.backBarButtonItem.title = @"Back";
        NSDictionary* result = [_JSONArrayList valueForKey:@"RESULT"];
        NSArray* columns = [result valueForKey:@"COLUMNS"];
        NSArray* data = [result valueForKey:@"DATA"];
        NSDictionary* tempDict;
        for(int j=0; j<[data count];j++){
            NSArray* data2 = [data objectAtIndex:j];
            NSDictionary* temp = [NSDictionary dictionaryWithObjects:data2 forKeys:columns];
            [_list addObject:[temp valueForKey:@"SITETYPENAME"]];
            [shareIDs addObject:[temp valueForKey:@"SITEID"]];
            tempDict = [NSDictionary dictionaryWithObject:[temp valueForKey:@"NAME"] forKey:[temp valueForKey:@"SITETYPENAME"]];
            [_connectionSharedFolders addObject:tempDict];
        }
        sitesAndShareIDs = [NSDictionary dictionaryWithObjects:shareIDs forKeys:_list];
        NSArray* tempCpy = [NSArray arrayWithArray:_list];
        [_list setArray:[[NSSet setWithArray:_list] allObjects]];
        /*
        if([tempCpy count] - [_list count] == 1){
            if([_appDel.enabledConnections count] - [_list count] == 1){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"removeOneIndex" object:nil];
            }
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if([_appDel.enabledConnections count] == 0 || ([_appDel.enabledConnections count] != [_list count])){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getEnabledStates" object:nil];
        }
        if([_appDel.enabledConnections count] != [_list count]){
            _appDel.enabledConnections = nil;
            _appDel.enabledConnections = [NSMutableArray array];
            for(int j = 0; j< [_list count];j++){
                [_appDel.enabledConnections addObject:@"1"];
            }
        }
        for (int j = 0; j < [_list count];j++){
            if([[_appDel.enabledConnections objectAtIndex:j] integerValue] == 1){
                [_displayList addObject:[_list objectAtIndex:j]];
            }
        }
        */
    }
}

// Hubs table views

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView == _hubsTableView){
            return [_displayList count];
    }
    else if(tableView == _sharedFoldersTableView){
        return [_list count];
    }
    else if(tableView == _activeStorageConnectionsTableView){
        return [_activeStorageConnections count];
    }
    else if(tableView == _foldersInHubTableView){
        return [_activeStorageConnections count];
    }
    else if(tableView == _activeUsersTableView){
        return [_activeUsers count];
    }
    else if (tableView == _permissionsTableView){
        return [_permissions count];
    }
    else return 0;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == _hubsTableView){
    static NSString *CellIdentifier = @"HubCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.textLabel.text = [_displayList objectAtIndex:indexPath.row];
    return cell;
    }
    else if(tableView == _sharedFoldersTableView){
        static NSString *CellIdentifier = @"FolderCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.textLabel.text = [_list objectAtIndex:indexPath.row];
        return cell;
    }
    else if (tableView == _activeStorageConnectionsTableView){
        static NSString *CellIdentifier = @"ActiveStorageCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.textLabel.text = [_activeStorageConnections objectAtIndex:indexPath.row];
        return cell;
    }
    else if (tableView == _foldersInHubTableView){
        static NSString *CellIdentifier = @"FolderInHubCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        NSMutableArray* allFolders = [NSMutableArray array];
        for (NSDictionary* tempDict in _connectionSharedFolders) {
            if([[tempDict valueForKey:[_activeStorageConnections objectAtIndex:indexPath.row]] length] > 0){
                [allFolders addObject:[tempDict valueForKey:[_activeStorageConnections objectAtIndex:indexPath.row]]];
            }
        }
        cell.textLabel.text = [allFolders componentsJoinedByString:@", "];
        return cell;
    }
    else if (tableView == _activeUsersTableView){
        static NSString *CellIdentifier = @"ActiveUserCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.textLabel.text = [_activeUsers objectAtIndex:indexPath.row];
        return cell;
    }
    else if (tableView == _permissionsTableView){
        static NSString *CellIdentifier = @"PermissionCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.textLabel.text = [_permissions objectAtIndex:indexPath.row];
        return cell;
    }
    else return nil;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == _hubsTableView){
        if(!_manageHubsButton.enabled){
            _manageHubsButton.enabled = YES;
        }
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            _storageName = [_displayList objectAtIndex:indexPath.row];
            [_hubNameLabel setText:[NSString stringWithFormat:@"Hub %@ Overview",_storageName]];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [UIView animateWithDuration:0.15 animations:^(void) {
            _selectAHubLabel.alpha = 0;
        }];
            [self getSharedFolders];
            [UIView animateWithDuration:0.20f animations:^(void)  {
            _sharedFoldersTableView.alpha = 1;
        }];
    }
    else if(tableView == _sharedFoldersTableView){
        i = indexPath.row;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [self performSegueWithIdentifier:@"goToFileViewer" sender:self];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if(tableView == _activeStorageConnectionsTableView){
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void) getHubActiveUsers{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURLResponse* urlResponseList;
    NSError* requestErrorList;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.point.io/api/v2/shareables/%@/users.json",[sitesAndShareIDs valueForKey:_storageName]]]];
    [request setHTTPMethod:@"GET"];
    NSArray* JSONResponse;
    [request addValue:_appDel.sessionKey forHTTPHeaderField:@"Authorization"];
    NSData* response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponseList error:&requestErrorList];
    if(!response){
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Request response is nil" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
    } else {
        JSONResponse = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
        NSDictionary* result = [JSONResponse valueForKey:@"RESULT"];
        NSArray* columns = [result valueForKey:@"COLUMNS"];
        NSArray* datax = [result valueForKey:@"DATA"];
        NSLog(@"JSON RESPONSE = %@",JSONResponse);
        if(!JSONResponse){
            
        }
    }
}

- (void) getSharedFolders{
    [MBProgressHUD showHUDAddedTo:self.sharedFoldersTableView animated:YES];
    _list = nil;
    _list = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSURLResponse* urlResponseList;
        NSError* requestErrorList;
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:@"https://api.point.io/api/v2/accessrules/list"]];
        [request setHTTPMethod:@"GET"];
        [request addValue:_appDel.sessionKey forHTTPHeaderField:@"Authorization"];
        NSData* response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponseList error:&requestErrorList];
        if(!response){
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Request response is nil" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
            [alert show];
        } else {
            _JSONSharedFoldersArray = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
            NSDictionary* result = [_JSONSharedFoldersArray valueForKey:@"RESULT"];
            NSArray* columns = [result valueForKey:@"COLUMNS"];
            NSArray* datax = [result valueForKey:@"DATA"];
            _folderNames = [NSMutableArray array];
            _folderShareIDs = [NSMutableArray array];
            for(int j=0; j<[datax count];j++){
                NSArray* data2 = [datax objectAtIndex:j];
                NSDictionary* temp = [NSDictionary dictionaryWithObjects:data2 forKeys:columns];
                [_folderNames addObject:[temp valueForKey:@"NAME"]];
                [_folderShareIDs addObject:[temp valueForKey:@"SHAREID"]];
            }
            
            for (NSDictionary* tempDict in _connectionSharedFolders) {
                if([[tempDict valueForKey:_storageName] length] > 0){
                    [_list addObject:[tempDict valueForKey:_storageName]];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.sharedFoldersTableView animated:YES];
                [_sharedFoldersTableView reloadData];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            });
        }
    });
}

- (IBAction)storageConnectionsPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)manageHubsPressed:(id)sender {
    manageHubsPressed = !manageHubsPressed;
    if(manageHubsPressed){
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
    [UIView animateWithDuration:0.20f animations:^(void) {
        _hubsTableView.alpha = 0;
        _centralBorderBar.alpha = 1;
        _activeUsersTableView.alpha = 1;
        _activeStorageConnectionsTableView.alpha = 1;
        _foldersInHubTableView.alpha = 1;
        _permissionsTableView.alpha = 1;
        _viewActivityButton.alpha = 1;
        _viewFilesButton.alpha = 1;
        _viewUsersButton.alpha = 1;
        _removeHubButton.alpha = 1;
        _hubNameLabel.alpha = 1;
        _horizontalBorderBar.alpha = 1;
        _sharedFoldersTableView.alpha = 0;
    }];
        
                [MBProgressHUD showHUDAddedTo:self.activeStorageConnectionsTableView animated:YES];
        
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.activeStorageConnectionsTableView animated:YES];
                    [_activeStorageConnectionsTableView reloadData];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                });
        
        [MBProgressHUD showHUDAddedTo:self.foldersInHubTableView animated:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.foldersInHubTableView animated:YES];
            [_foldersInHubTableView reloadData];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
        
    }
    else {
        [UIView animateWithDuration:0.20f animations:^(void) {
            _hubsTableView.alpha = 1;
            _centralBorderBar.alpha = 0;
            _activeUsersTableView.alpha = 0;
            _activeStorageConnectionsTableView.alpha = 0;
            _foldersInHubTableView.alpha = 0;
            _permissionsTableView.alpha = 0;
            _viewActivityButton.alpha = 0;
            _viewFilesButton.alpha = 0;
            _viewUsersButton.alpha = 0;
            _removeHubButton.alpha = 0;
            _hubNameLabel.alpha = 0;
            _horizontalBorderBar.alpha = 0;
            _sharedFoldersTableView.alpha = 1;
        }];
    }
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(tableView == _activeStorageConnectionsTableView){
        return @"Active Storage Connections";
    } else if (tableView == _foldersInHubTableView){
        return @"Folders in Hub";
    } else if (tableView == _activeUsersTableView){
        return @"Active Users";
    } else if(tableView == _permissionsTableView){
        return @"Permissions";
    }
    else return nil;
}

- (void) viewWillAppear:(BOOL)animated{
    self.navigationItem.title = @"Hubs";
    imgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(5, 27, 50, 29)];
    imgView2.image = [UIImage imageNamed:@"backButton.png"];
    [self.navigationController.view addSubview:imgView2];
}

- (void) viewWillDisappear:(BOOL)animated{
    [UIView animateWithDuration:0.25 animations:^(void) {
        imgView2.alpha = 0;
    }];
    imgView2 = nil;
}
- (void)viewDidUnload {
    [self setCentralBorderBar:nil];
    [super viewDidUnload];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"goToFileViewer"]){
        FileViewerControllerIpad* fvc = [segue destinationViewController];
        NSDictionary* allFoldersForAllShareIDs = [NSDictionary dictionaryWithObjects:_folderShareIDs forKeys:_folderNames];
        NSString* chosenShareID = [allFoldersForAllShareIDs valueForKey:[_list objectAtIndex:i]];
        [fvc setShareID:chosenShareID];
        [fvc setFolderName:[_list objectAtIndex:i]];
        [fvc setSessionKey:_appDel.sessionKey];
    }
}


@end