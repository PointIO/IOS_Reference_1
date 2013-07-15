#import "connectionsTableViewController.h"
#import "Common.h"

@interface connectionsTableViewController ()

@end

@implementation connectionsTableViewController

@synthesize list = _list;
@synthesize displayList = _displayList;
@synthesize storageName = _storageName;
@synthesize sessionKey = _sessionKey;

// REST API

@synthesize JSONArrayList = _JSONArrayList;
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
UIImageView* imgView2;
UIImageView* imgView3;
UIImageView* imgView4;

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
    
    self.navigationItem.title = @"My Storage Connections";
    /*
    for (UIView *view in self.navigationController.navigationBar.subviews) {
        [view removeFromSuperview];
    }
     */
    
    _appDel = (AppDelegate*) [[UIApplication sharedApplication] delegate];
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
        [self performSelectorOnMainThread:@selector(getConnections) withObject:nil waitUntilDone:YES];
        [self getAllPossibleConnections];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadLists:) name:@"reloadLists" object:nil];
    [_appDel setSessionKey:_sessionKey];
    _EmailFields = [NSMutableArray array];
    i = 0;

    /*
    _manageStoredConnectionsButton.width = 0.01;
    NSMutableArray* toolbarButtons = [self.toolbarItems mutableCopy];
    // lol
    [toolbarButtons addObject: _manageStoredConnectionsButton];
    [toolbarButtons addObject: _manageStoredConnectionsButton];
    [toolbarButtons addObject: _manageStoredConnectionsButton];
    [toolbarButtons addObject: _manageStoredConnectionsButton];
    [toolbarButtons addObject: _manageStoredConnectionsButton];
    [toolbarButtons addObject: _manageStoredConnectionsButton];
    [self setToolbarItems:toolbarButtons];
    */
    
    // JB 6/9/13: unhiding NavController has messy results...need to re-evaluate
    // [[self navigationController] setNavigationBarHidden:YES animated:YES];
    /*
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                  target:self
                                  action:@selector(addNewConnectionPressed:)];
    self.navigationItem.rightBarButtonItem = addButton;
    */
}

- (void) viewWillDisappear:(BOOL)animated{
    
    /*
    imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    imgView.image = [UIImage imageNamed:@"barImageWithLogo.png"];
    [self.navigationController.navigationBar addSubview:imgView];
    
    imgView.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^(void) {
        imgView.alpha = 1;
    }];
     */
    /*
    [UIView animateWithDuration:0.25 animations:^(void) {
        imgView.alpha = 0;
        imgView2.alpha = 0;
        imgView4.alpha = 0;
    }];
    imgView = nil;
    imgView2 = nil;
    imgView4 = nil;
    */
}

- (void) viewDidDisappear:(BOOL)animated{

}

- (void) viewWillAppear:(BOOL)animated{
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
        imgView4 = [[UIImageView alloc] initWithFrame:CGRectMake(45, 7, 200, 30)];
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
            
           /*
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
            */
            
            _displayList = [NSMutableArray array];
            for (int i = 0; i < [_list count];i++){
                // if([[_appDel.enabledConnections objectAtIndex:i] integerValue] == 1){
                  //  [_displayList addObject:[_list objectAtIndex:i]];
                    // NSLog(@"from getConnections, displayList array contents are: %@", _displayList);
               // }
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

    return [_displayList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ConnectionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if([_displayList count] != 0){
        cell.textLabel.text = [_displayList objectAtIndex:indexPath.row];
    }
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _storageName = [_displayList objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"goToFolders" sender:self];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (IBAction)manageStoredConnectionsPressed:(id)sender {
    [self performSegueWithIdentifier:@"manageConnections" sender:self];
}

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

- (IBAction)addNewConnectionPressed:(id)sender {
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


- (void) addNewConnection{
    [self performSegueWithIdentifier:@"getOtherParams" sender:nil];
}

- (void)tableAlert:(SBTableAlert *)tableAlert didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if(buttonIndex == -1){
        
    }
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
    } else {
        if([[segue identifier] isEqualToString:@"getOtherParams"]){
            newConnectionViewController* ncvc = [segue destinationViewController];
            [ncvc setUserStorageInput:_userStorageInput];
            [ncvc setSessionKey:_sessionKey];
            [ncvc setSiteTypeID:[_storageIDs objectAtIndex:i]];
            [ncvc setAllPossibleConnections:_allPossibleConnections];
            [ncvc setRequestedConnectionName:requestedConnectionName];
        }
        if([[segue identifier] isEqualToString:@"goToFolders"]){
            sharedFoldersViewController* sfvc = [segue destinationViewController];
            [sfvc setStorageName:_storageName];
            [sfvc setSessionKey:_sessionKey];
            [sfvc setConnectionSharedFolders:_connectionSharedFolders];
        }
        if([[segue identifier] isEqualToString:@"manageConnections"]){
            connectionsManagerViewController *cmvc = [segue destinationViewController];
            [cmvc setJSONArrayList:_JSONArrayList];
            [cmvc setStorageIDs:_storageIDs];
            [cmvc setSessionKey:_sessionKey];
        }
    }
    
}



- (void)viewDidUnload {
    [self setManageStoredConnectionsButton:nil];
    [super viewDidUnload];
}
@end
