#import "docViewerViewControlleriPad.h"
#import "FileViewerControllerIpad.h"
#import "newConnectionViewControlleriPad.h"
#import <QuartzCore/QuartzCore.h>
#import "Common.h"


@interface docViewerViewControlleriPad ()

@end

@implementation docViewerViewControlleriPad

@synthesize shareID = _shareID;
@synthesize fileName = _fileName;
@synthesize fileID = _fileID;
@synthesize containerID = _containerID;
@synthesize remotePath = _remotePath;
@synthesize fileDownloadURL = _fileDownloadURL;
@synthesize downloadData = _downloadData;
@synthesize i, nestedFoldersCounter;

UIImageView* imgView;
UIImageView* imgView2;
UIImageView* imgView3;
UILabel* fileNameLabel;
UILabel* sharedFolderLabel;

UIAlertView* maxDownloadsReachedError;

NSString* chosenFolderTitle, *rootFolderTitle, *requestedConnectionName;
NSMutableArray* tempContainer;

NSArray* tempArray;
BOOL manageStorageConnections;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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

- (void) reloadLists:(NSNotification *)notification{
    [self performSelectorOnMainThread:@selector(getConnections) withObject:nil waitUntilDone:YES];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Storage connections";
    manageStorageConnections = NO;
    _connectionsTableView.delegate = self;
    _connectionsTableView.dataSource = self;
    _connectionsTableView.frame = CGRectMake(0, 0, _connectionsTableView.frame.size.width, _connectionsTableView.frame.size.height);
    _sharedFoldersTableView.delegate = self;
    _sharedFoldersTableView.dataSource = self;
    _appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadLists:) name:@"reloadLists" object:nil];
    self.navigationItem.backBarButtonItem.title = @"Back";
    [self.navigationController setToolbarHidden:NO animated:YES];
    if(![Common isConnectedToInternet]){
        UIAlertView* err = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Looks like there is no internet connection, please check the settings" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        UIImageView* temp = [[UIImageView alloc] initWithFrame:CGRectMake(2, 0, 280, 174)];
        temp.image = [UIImage imageNamed:@"noInternetConnection.png"];
        [err addSubview:temp];
        [err setBackgroundColor:[UIColor clearColor]];
        [err show];
    } else {
        
        NSDictionary* result = [_JSONArrayList valueForKey:@"RESULT"];
        NSArray* columns = [result valueForKey:@"COLUMNS"];
        NSDictionary* result2 = [_JSONArrayList valueForKey:@"RESULT"];
        NSArray* data = [result2 valueForKey:@"DATA"];
        for(int j=0; j<[data count];j++){
            NSArray* data2 = [data objectAtIndex:j];
            _sharedFolderData = [NSDictionary dictionaryWithObjects:data2 forKeys:columns];
            [_list addObject:[_sharedFolderData valueForKey:@"SITETYPENAME"]];
        }
        [_list setArray:[[NSSet setWithArray:_list] allObjects]];
        
        [MBProgressHUD showHUDAddedTo:self.connectionsTableView animated:YES];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [self getConnections];
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.connectionsTableView animated:YES];
                if(tempArray && [[tempArray valueForKey:@"ERROR"]integerValue] == 1){
                    NSString* message = [tempArray valueForKey:@"MESSAGE"];
                    if([message isEqualToString:@"ERROR - Could not download file: You have exceeded the max number of monthly Downloads allowed for a member of your group"]){
                        NSLog(@"SHOULD SHOW ALERT");
                        UIAlertView* maxDownloadsReachedError = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You have exceeded the maximum number of monthly downloads allowed for a member of your group" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                        UIImageView* errorImgView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 0, 280, 174)];
                        errorImgView.image = [UIImage imageNamed:@"maxDownloadsError.png"];
                        [maxDownloadsReachedError addSubview:errorImgView];
                        [maxDownloadsReachedError setTag:99];
                        maxDownloadsReachedError.delegate = self;
                        [maxDownloadsReachedError show];
                    }
                }
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
            _list = [NSMutableArray array];
            _allPossibleConnections = [NSMutableArray array];
            _storageIDs = [NSMutableArray array];
            _displayList  = [NSMutableArray array];
            _connectionSharedFolders = [NSMutableArray array];
            self.navigationItem.backBarButtonItem.title = @"Back";
            NSDictionary* result = [_JSONArrayList valueForKey:@"RESULT"];
            NSArray* columns = [result valueForKey:@"COLUMNS"];
            NSArray* data = [result valueForKey:@"DATA"];
            NSDictionary* tempDict;
            NSLog(@"DATA COUNT IS %i",[data count]);
            for(int j=0; j<[data count];j++){
                NSArray* data2 = [data objectAtIndex:j];
                NSDictionary* temp = [NSDictionary dictionaryWithObjects:data2 forKeys:columns];
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
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                if([_appDel.enabledConnections count] == 0 || ([_appDel.enabledConnections count] != [_list count])){
                    // [[NSNotificationCenter defaultCenter] postNotificationName:@"getEnabledStates" object:nil];
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
                [_connectionsTableView reloadData];
        }
}

- (void) getAllPossibleConnections{
    NSMutableArray* tempy = [NSMutableArray array];
    NSURLResponse* urlResponseList;
    NSError* requestErrorList;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://connect.cloudxy.com/api/v1/storagetypes/list.json"]];
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
            for (int j = 0; j<[data count]; j++) {
                NSArray* data2 = [data objectAtIndex:j];
                NSDictionary* temp = [NSDictionary dictionaryWithObjects:data2 forKeys:columns];
                if([[temp valueForKey:@"ENABLED"] integerValue] == 1){
                    [tempy addObject:[temp valueForKey:@"SITETYPENAME"]];
                    [_storageIDs addObject:[temp valueForKey:@"SITETYPEID"]];
                }
            }
            _allPossibleConnections = [NSMutableArray arrayWithArray:tempy];
        }
    }
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 99){
        [[self navigationController] popViewControllerAnimated:YES];
    }
}

- (void) viewWillDisappear:(BOOL)animated{
    [UIView animateWithDuration:0.25 animations:^(void) {
        imgView.alpha = 0;
        imgView2.alpha = 0;
        fileNameLabel.alpha = 0;
    }];
    imgView = nil;
    imgView = nil;
    imgView2 = nil;
    fileNameLabel = nil;
}

/*---------------------------TABLE VIEW------------------------------*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == _connectionsTableView){
        if(manageStorageConnections){
            return [_manageList count];
        } else {
    return [_displayList count];
        }
    }
    if(tableView == _sharedFoldersTableView){
        return [_list count];
    }
    else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == _connectionsTableView){
    static NSString *CellIdentifier = @"ConnectionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(manageStorageConnections){
            UISwitch *tableViewSwitch = [[UISwitch alloc] init];
            cell.accessoryView = tableViewSwitch;
            NSDictionary* result = [_JSONArrayList valueForKey:@"RESULT"];
            NSArray* columns = [result valueForKey:@"COLUMNS"];
            NSArray* data = [result valueForKey:@"DATA"];
            for(int j=0; j<[data count];j++){
                NSArray* data2 = [data objectAtIndex:j];
                _sharedFolderData = [NSDictionary dictionaryWithObjects:data2 forKeys:columns];
                if([[_appDel.enabledConnections objectAtIndex:indexPath.row] integerValue] == 1){
                    tableViewSwitch.on = YES;
                } else {
                    tableViewSwitch.on = NO;
                }
            }
            [tableViewSwitch addTarget:self action:@selector(valueChanged:withIndex:) forControlEvents:UIControlEventValueChanged];
            cell.textLabel.text = [_manageList objectAtIndex:indexPath.row];
        } else {
            cell.accessoryView = nil;
            cell.textLabel.text = [_displayList objectAtIndex:indexPath.row];
        }
    return cell;
    } else if(tableView == _sharedFoldersTableView){
        static NSString *CellIdentifier = @"FolderCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.textLabel.text = [_list objectAtIndex:indexPath.row];
        return cell;
    }
    else return nil;
}

- (void) valueChanged:(id) sender withIndex:(NSInteger) index{
    UISwitch *controlSwitch = sender;
    UITableViewCell *myCell = [controlSwitch superview];
    _storageName = myCell.textLabel.text;
    UITableView* tableView = (UITableView*)[myCell superview];
    NSIndexPath* path = [tableView indexPathForCell:myCell];
    int row = path.row;
    NSLog(@"ROW IS %i",row);
    if (controlSwitch.isOn) {
        [_appDel.enabledConnections setObject:@"1" atIndexedSubscript:row];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLists" object:nil];
        NSLog(@"ENABLED CONNECTIONS IS NOW %@",_appDel.enabledConnections);
    }
    if(!controlSwitch.isOn){
        [_appDel.enabledConnections setObject:@"0" atIndexedSubscript:row];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLists" object:nil];
    }
    NSString* temp = [[NSString alloc] init];
    for(int j = 0;j < [_appDel.enabledConnections count];j++){
        if([[_appDel.enabledConnections objectAtIndex:j] isEqualToString:@"1"]){
            if(j==0){
                temp = [NSString stringWithFormat:@"1"];
            } else {
                temp = [temp stringByAppendingString:@"1"];
            }
        } else {
            if(j==0){
                temp = [NSString stringWithFormat:@"0"];
            } else {
                temp = [temp stringByAppendingString:@"0"];
            }
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:temp forKey:@"ENABLEDCONNECTIONS"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [TestFlight passCheckpoint:@"User changed enabled connections value"];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == _connectionsTableView){
        if(!manageStorageConnections){
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        _storageName = [_displayList objectAtIndex:indexPath.row];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self getSharedFolders];
        } else {
            [_connectionsTableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
    if(tableView == _sharedFoldersTableView){
        i = indexPath.row;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [self performSegueWithIdentifier:@"goToFileViewer" sender:self];
        [_sharedFoldersTableView deselectRowAtIndexPath:indexPath animated:YES];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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
        NSLog(@"%@",_sessionKey);
        [request addValue:_sessionKey forHTTPHeaderField:@"Authorization"];
        NSData* response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponseList error:&requestErrorList];
        if(!response){
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Request response is nil" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
            [alert show];
        } else {
            _JSONSharedFoldersArray = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"JSONSHAREDFOLDERSARRAY - %@",_JSONSharedFoldersArray);
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
            NSLog(@"CONNECTION SHARED FOLDERS - %@",_connectionSharedFolders);
            for (NSDictionary* tempDict in _connectionSharedFolders) {
                if([[tempDict valueForKey:_storageName] length] > 0){
                    [_list addObject:[tempDict valueForKey:_storageName]];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.sharedFoldersTableView animated:YES];
                [_sharedFoldersTableView reloadData];
                NSLog(@"LIST = %@",_list);
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            });
        }
    });
}


- (void) viewDidAppear:(BOOL)animated{
    [self.navigationController setToolbarHidden:NO animated:YES];
    if (self.interfaceOrientation != UIInterfaceOrientationLandscapeLeft && self.interfaceOrientation != UIInterfaceOrientationLandscapeRight) {
        [[UIDevice currentDevice] performSelector:NSSelectorFromString(@"setOrientation:") withObject:(__bridge id)((void*)UIInterfaceOrientationLandscapeLeft)];
    }
}

- (void) viewWillAppear:(BOOL)animated{
    if(!imgView){
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 320, 44)];
        imgView.image = [UIImage imageNamed:@"blueBarImageClean.png"];
//        [self.navigationController.view addSubview:imgView];
        imgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(5, 27, 50, 29)];
        imgView2.image = [UIImage imageNamed:@"backButton.png"];
        [self.navigationController.view addSubview:imgView2];
        [self.navigationController.view addSubview:fileNameLabel];
        imgView3 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 1.1f, 320, 44)];
        imgView3.image = [UIImage imageNamed:@"blueBarImageClean"];
//        [self.navigationController.toolbar addSubview:imgView3];
    }
    imgView.alpha = 0;
    imgView2.alpha = 0;
    imgView3.alpha = 0;
    fileNameLabel.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^(void) {
        imgView.alpha = 1;
        imgView2.alpha = 1;
        fileNameLabel.alpha = 1;
    }];
}

- (void) webViewDidStartLoad:(UIWebView *)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [TestFlight passCheckpoint:@"User viewed a document"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)shareFilePressed:(id)sender {
    [self performSegueWithIdentifier:@"goToShare" sender:nil];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}



- (IBAction)manageStoredConnectionsPressed:(id)sender {
    manageStorageConnections = !manageStorageConnections;
    _manageList = [NSMutableArray array];
    NSDictionary* result = [_JSONArrayList valueForKey:@"RESULT"];
    NSArray* columns = [result valueForKey:@"COLUMNS"];
    NSArray* data = [result valueForKey:@"DATA"];
    NSLog(@"DATA COUNT = %i",[data count]);
    for(int j=0; j<[data count];j++){
        NSArray* data2 = [data objectAtIndex:j];
        NSDictionary* temp = [NSDictionary dictionaryWithObjects:data2 forKeys:columns];
                [_manageList addObject:[temp valueForKey:@"SITETYPENAME"]];
    }
    [_manageList setArray:[[NSSet setWithArray:_manageList] allObjects]];
    [_connectionsTableView reloadData];
    _list = [NSMutableArray array];
    [_sharedFoldersTableView reloadData];
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
    } else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There are no available connections for you" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        UIImageView* alertCustomView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 0, 280, 154)];
        alertCustomView.image = [UIImage imageNamed:@"noAvailableConnections.png"];
        [alert addSubview:alertCustomView];
        [alert show];
    }
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

- (void)tableAlert:(SBTableAlert *)tableAlert didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    tableAlert.view.alpha = 0;
    if(indexPath.row == [_allPossibleConnections count] || indexPath.row > [_allPossibleConnections count]){
    } else {
        i = indexPath.row;
        requestedConnectionName = [_allPossibleConnections objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"addNewConnection" sender:self];
    }
}

- (IBAction)hubsButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"goToHubs" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"goToFileViewer"]){
        FileViewerControllerIpad* fvc = [segue destinationViewController];
        
        NSDictionary* allFoldersForAllShareIDs = [NSDictionary dictionaryWithObjects:_folderShareIDs forKeys:_folderNames];
        NSLog(@"ALL FOLDERS FOR ALL SHARE IDS - %@",allFoldersForAllShareIDs);
        NSString* chosenShareID = [allFoldersForAllShareIDs valueForKey:[_list objectAtIndex:i]];
        NSLog(@"SHARE ID = %@", chosenShareID);
        
        [fvc setShareID:chosenShareID];
        [fvc setFolderName:[_list objectAtIndex:i]];
        [fvc setSessionKey:_sessionKey];
    }
    else if([[segue identifier] isEqualToString:@"addNewConnection"]){
        newConnectionViewControlleriPad* ncvc = [segue destinationViewController];
        [ncvc setSessionKey:_sessionKey];
        [ncvc setSiteTypeID:[_storageIDs objectAtIndex:i]];
        [ncvc setAllPossibleConnections:_allPossibleConnections];
        [ncvc setRequestedConnectionName:requestedConnectionName];
    }
    else if([[segue identifier] isEqualToString:@"goToHubs"]){
        HubsViewController* hvc = [segue destinationViewController];
        [hvc setActiveStorageConnections:_displayList];
    }
}


@end