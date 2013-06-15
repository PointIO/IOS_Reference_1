//
//  workspaceListViewController.m
//  PointiOSReferenceFileBrowser
//
//  Created by jb on 6/13/13.
//  Copyright (c) 2013 PointIO. All rights reserved.
//

#import "workspaceListViewController.h"

@interface workspaceListViewController()

@end

@implementation workspaceListViewController

@synthesize list = _list;
@synthesize displayList = _displayList;
@synthesize storageName = _storageName;
@synthesize sessionKey = _sessionKey;

// JB 6/14/13 - properties added to handle drilling into folders; synthesizing for consistency only. no longer necessary to synthesize.
// @synthesize JSONSharedFoldersArray = _JSONSharedFoldersArray;
@synthesize folderNames = _folderNames;
@synthesize folderShareIDs = _folderShareIDs;

// REST API
@synthesize JSONArrayList = _JSONArrayList;
@synthesize JSONSharedFoldersArray = _JSONSharedFoldersArray;
@synthesize shareIDs = _shareIDs;
@synthesize fileNames = _fileNames;
@synthesize containerID = _containerID;
@synthesize remotePath = _remotePath;
@synthesize fileIDs = _fileIDs;
@synthesize storageIDs = _storageIDs;
@synthesize allPossibleConnections = _allPossibleConnections;
@synthesize alert = _alert;
@synthesize userStorageInput = _userStorageInput;
@synthesize connectionSiteTypeID = _connectionSiteTypeID;
@synthesize appDel = _appDel;
@synthesize label = _label;
@synthesize EmailFields = _EmailFields;
@synthesize globalAlert = _globalAlert;
@synthesize manageStoredConnectionsButton = _manageStoredConnectionsButton;
@synthesize connectionSharedFolders = _connectionSharedFolders;

BOOL isUsernameOrPassword;
BOOL isEmail;
int i;
NSString* requestedConnectionName;

UIImageView* imgView;
// UIImageView* imgView2;
UILabel* sharedFolderLabel;
/*
UIImageView* imgView3;
UIImageView* imgView4;
*/


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

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"My Folders";
    for (UIView *view in self.navigationController.navigationBar.subviews) {
        [view removeFromSuperview];
    }
    _JSONSharedFoldersArray = [NSArray array];
    _list = [NSMutableArray array];
    _shareIDs = [NSMutableArray array];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSURLResponse* urlResponseList;
        NSError* requestErrorList;
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:@"https://api.point.io/api/v2/accessrules/list"]];
        [request setHTTPMethod:@"GET"];
        [request addValue:_sessionKey forHTTPHeaderField:@"Authorization"];
        
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
            _JSONSharedFoldersArray = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"JSONSHAREDFOLDERSARRAY - %@",_JSONSharedFoldersArray);
            NSDictionary* result = [_JSONSharedFoldersArray valueForKey:@"RESULT"];
            NSArray* columns = [result valueForKey:@"COLUMNS"];
            NSArray* datax = [result valueForKey:@"DATA"];
            _folderNames = [[NSMutableArray alloc] init];
            _folderShareIDs = [[NSMutableArray array] init];
            
            for(int i=0; i<[datax count];i++){
                NSArray* data2 = [datax objectAtIndex:i];
                NSDictionary* temp = [NSDictionary dictionaryWithObjects:data2 forKeys:columns];
                [_folderNames addObject:[temp valueForKey:@"NAME"]];
                [_folderShareIDs addObject:[temp valueForKey:@"SHAREID"]];
                [_list addObject:[temp valueForKey:@"NAME"]];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self.tableView reloadData];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            });
        }
    });
    
    
    /*
     // Comment 6/14/13 - this was working to display workspaces
    [super viewDidLoad];
    
    self.navigationItem.title = @"Workspaces";
    [[self navigationController] setNavigationBarHidden:NO animated:YES];

    _appDel = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    if(![self isConnectedToInternet]){
        UIAlertView* err = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Looks like there is no internet connection, please check the settings" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        UIImageView* temp = [[UIImageView alloc] initWithFrame:CGRectMake(2, 0, 280, 174)];
        temp.image = [UIImage imageNamed:@"noInternetConnection.png"];
        [err addSubview:temp];
        [err setBackgroundColor:[UIColor clearColor]];
        [err show];
    } else {
        [self performSelectorOnMainThread:@selector(getConnections) withObject:nil waitUntilDone:YES];
        [self getAllPossibleConnections];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadLists:) name:@"reloadLists" object:nil];
    [_appDel setSessionKey:_sessionKey];
    _EmailFields = [NSMutableArray array];
    i = 0;
    */
    
    
}

- (void) viewWillDisappear:(BOOL)animated{
    imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    imgView.image = [UIImage imageNamed:@"barImageWithLogo.png"];
    [self.navigationController.navigationBar addSubview:imgView];
    
    imgView.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^(void) {
        imgView.alpha = 1;
    }];
}

- (void) viewDidDisappear:(BOOL)animated{
}

- (void) viewWillAppear:(BOOL)animated{
    if(!imgView){
        sharedFolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 16, 150, 50)];
        sharedFolderLabel.backgroundColor = [UIColor clearColor];
        sharedFolderLabel.text = _storageName;
        sharedFolderLabel.textColor = [UIColor whiteColor];
        [sharedFolderLabel setTextAlignment:UITextAlignmentCenter];
        sharedFolderLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:18.0];
        // imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 320, 44)];
        // imgView.image = [UIImage imageNamed:@"blueBarImageClean.png"];
        // [self.navigationController.view addSubview:imgView];
        // imgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(5, 27, 50, 29)];
        // imgView2.image = [UIImage imageNamed:@"backButton.png"];
        // [self.navigationController.view addSubview:imgView2];
        // [self.navigationController.view addSubview:sharedFolderLabel];
    }
    /*
    imgView.alpha = 0;
    imgView2.alpha = 0;
    sharedFolderLabel.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^(void) {
        imgView.alpha = 1;
        imgView2.alpha = 1;
        sharedFolderLabel.alpha = 1;
    }];
     */
    
    
    /*
     if(!imgView){
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 320, 44)];
        imgView.image = [UIImage imageNamed:@"blueBarImage.png"];
        [self.navigationController.view addSubview:imgView];
        
        imgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(5, 27, 50, 29)];
        imgView2.image = [UIImage imageNamed:@"backButton.png"];
        [self.navigationController.view addSubview:imgView2];
        
        imgView3 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 1.1f, 320, 44)];
        imgView3.image = [UIImage imageNamed:@"blueBarImageClean"];
        [self.navigationController.toolbar addSubview:imgView3];
        i
        mgView4 = [[UIImageView alloc] initWithFrame:CGRectMake(45, 7, 200, 30)];
        imgView4.image = [UIImage imageNamed:@"manageStoredConnections.png"];
        [self.navigationController.toolbar addSubview:imgView4];
    }
    
    imgView.alpha = 0;
    imgView2.alpha = 0;
    imgView4.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^(void) {
        imgView.alpha = 1;
        imgView2.alpha = 1;
        imgView3.alpha = 1;
        imgView4.alpha = 1;
    }];
     */
}

- (void) viewDidAppear:(BOOL)animated{
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
        // [self.navigationController setToolbarHidden:NO animated:YES];
        _userStorageInput = nil;
        _connectionSiteTypeID = nil;
        [self.tableView reloadData];
    }
}

- (void) reloadLists:(NSNotification *)notification{
    [self performSelectorOnMainThread:@selector(getConnections) withObject:nil waitUntilDone:YES];
    [self.tableView reloadData];
}

/*
- (void) getConnections{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^
   {
       NSURLResponse* urlResponseList;
       NSError* requestErrorList;
       NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
       
       [request setURL:[NSURL URLWithString:@"https://api.point.io/api/v2/accessrules/list.json"]];
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
           
           _folderNames = [NSMutableArray array];
           _folderShareIDs = [NSMutableArray array];

           for(int i=0; i<[data count];i++){
               NSArray* data2 = [data objectAtIndex:i];
               NSDictionary* temp = [NSDictionary dictionaryWithObjects:data2 forKeys:columns];
               NSLog(@"NEW TEMP = %@",temp);
               [_list addObject:[temp valueForKey:@"SHARENAME"]];
               tempDict = [NSDictionary dictionaryWithObject:[temp valueForKey:@"NAME"] forKey:[temp valueForKey:@"SHARENAME"]];
               [_connectionSharedFolders addObject:tempDict];
             
               [_folderNames addObject:[temp valueForKey:@"NAME"]];
               [_folderShareIDs addObject:[temp valueForKey:@"SHAREID"]];

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
                   NSLog(@"from getConnections, displayList array contents are: %@", _displayList);
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
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if([_list count] != 0){
        cell.textLabel.text = [_list objectAtIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    i = indexPath.row;
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary* allFoldersForAllShareIDs = [NSDictionary dictionaryWithObjects:_folderShareIDs forKeys:_folderNames];
    NSLog(@"ALL FOLDERS FOR ALL SHARE IDS - %@",allFoldersForAllShareIDs);
    NSString* chosenShareID = [allFoldersForAllShareIDs valueForKey:[_list objectAtIndex:i]];
    NSLog(@"SHARE ID = %@", chosenShareID);
    
    // JB 6/9/13: Add error test for Null chosenShareID which will occur if no Access Rules defined
    if (chosenShareID == NULL) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Workspace ID Missing"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
        return;
    }
    else {
        [self performSegueWithIdentifier:@"goToFiles" sender:self];
    }
    /*
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _storageName = [_displayList objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"goToFolders" sender:self];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    */
}

/*
- (IBAction)manageStoredConnectionsPressed:(id)sender {
    [self performSegueWithIdentifier:@"manageConnections" sender:self];
}
*/




/*
- (void) getAllPossibleConnections{
    NSMutableArray* tempy = [NSMutableArray array];
    NSURLResponse* urlResponseList;
    NSError* requestErrorList;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://api.point.io/api/v2/storagetypes/list.json"]];
    [request setHTTPMethod:@"GET"];
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


/*
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
        [self performSegueWithIdentifier:@"getOtherParams" sender:self];
    }
}

*/

/*
- (void)tableAlert:(SBTableAlert *)tableAlert didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if(buttonIndex == -1){
        
    }
}
*/

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if(![self isConnectedToInternet])
    {
        UIAlertView* err = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Looks like there is no internet connection, please check the settings" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        UIImageView* temp = [[UIImageView alloc] initWithFrame:CGRectMake(2, 0, 280, 174)];
        temp.image = [UIImage imageNamed:@"noInternetConnection.png"];
        [err addSubview:temp];
        [err setBackgroundColor:[UIColor clearColor]];
        [err show];
    }
    else
    {
        if([[segue identifier] isEqualToString:@"goToFolders"]){
            sharedFoldersViewController* sfvc = [segue destinationViewController];
            [sfvc setStorageName:_storageName];
            [sfvc setSessionKey:_sessionKey];
            [sfvc setConnectionSharedFolders:_connectionSharedFolders];
        }
        else if([[segue identifier] isEqualToString:@"goToFiles"]){
            NSDictionary* allFoldersForAllShareIDs = [NSDictionary dictionaryWithObjects:_folderShareIDs forKeys:_folderNames];
            NSLog(@"ALL FOLDERS FOR ALL SHARE IDS - %@",allFoldersForAllShareIDs);
            NSString* chosenShareID = [allFoldersForAllShareIDs valueForKey:[_list objectAtIndex:i]];
            NSLog(@"SHARE ID = %@", chosenShareID);
            workspaceViewController *wvc = [segue destinationViewController];
            [wvc setShareID:chosenShareID];
            [wvc setFolderName:[_list objectAtIndex:i]];
            [wvc setSessionKey:_sessionKey];
            NSLog(@"INDEX IS %i",i);
        }

    }
}

- (BOOL) isConnectedToInternet{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

- (void)viewDidUnload {
    // [self setManageStoredConnectionsButton:nil];
    [super viewDidUnload];
}
@end
