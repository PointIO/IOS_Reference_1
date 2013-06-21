#import "connectionsManagerViewController.h"

@interface connectionsManagerViewController ()
{
    NSInteger row;
    NSString* storageName;
}
@end

@implementation connectionsManagerViewController

@synthesize list = _list;
@synthesize sharedFolderData = _sharedFolderData;
@synthesize JSONArrayList = _JSONArrayList;
@synthesize appDel = _appDel;
@synthesize sessionKey = _sessionKey;
@synthesize storageIDs = _storageIDs;

UIImageView* imgView;
UIImageView* imgView2;

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
    for (UIView *view in self.navigationController.navigationBar.subviews) {
        [view removeFromSuperview];
    }

    self.navigationItem.backBarButtonItem.title = @"Back";
    _appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    _list = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(enableBackButton:) name:@"enableBackButton" object:nil];
    
    if(![self isConnectedToInternet]){
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
        for(int i=0; i<[data count];i++){
            NSArray* data2 = [data objectAtIndex:i];
            _sharedFolderData = [NSDictionary dictionaryWithObjects:data2 forKeys:columns];
            [_list addObject:[_sharedFolderData valueForKey:@"SITETYPENAME"]];
        }
        [_list setArray:[[NSSet setWithArray:_list] allObjects]];
    }
}

- (void) viewDidAppear:(BOOL)animated{
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void) viewWillDisappear:(BOOL)animated{
    [NSThread sleepForTimeInterval:0.125f];
    [UIView animateWithDuration:0.25 animations:^(void) {
        imgView.alpha = 0;
        imgView2.alpha = 0;
    }];
    imgView = nil;
    imgView2 = nil;
}

- (void) viewWillAppear:(BOOL)animated{
    if(!imgView){
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 320, 44)];
        imgView.image = [UIImage imageNamed:@"blueBarImage.png"];
        [self.navigationController.view addSubview:imgView];
        imgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(5, 27, 50, 29)];
        imgView2.image = [UIImage imageNamed:@"backButton.png"];
        [self.navigationController.view addSubview:imgView2];
    }
    imgView.alpha = 0;
    imgView2.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^(void) {
        imgView.alpha = 1;
        imgView2.alpha = 1;
    }];
    [self.tableView reloadData];
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
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UISwitch *tableViewSwitch = [[UISwitch alloc] init];
    cell.accessoryView = tableViewSwitch;
    NSDictionary* result = [_JSONArrayList valueForKey:@"RESULT"];
    NSArray* columns = [result valueForKey:@"COLUMNS"];
    NSArray* data = [result valueForKey:@"DATA"];
    for(int i=0; i<[data count];i++){
        NSArray* data2 = [data objectAtIndex:i];
        _sharedFolderData = [NSDictionary dictionaryWithObjects:data2 forKeys:columns];
        if([[_appDel.enabledConnections objectAtIndex:indexPath.row] integerValue] == 1){
            tableViewSwitch.on = YES;
        } else {
            tableViewSwitch.on = NO;
        }
    }

    [tableViewSwitch addTarget:self action:@selector(valueChanged:withIndex:) forControlEvents:UIControlEventValueChanged];
    row = indexPath.row;
    cell.textLabel.text = [_list objectAtIndex:indexPath.row];
    return cell;
}


- (void) valueChanged:(id) sender withIndex:(NSInteger) index{
    UISwitch *controlSwitch = sender;
    UITableViewCell *myCell = [controlSwitch superview];
    storageName = myCell.textLabel.text;
    UITableView* tableView = (UITableView*)[myCell superview];
    NSIndexPath* path = [tableView indexPathForCell:myCell];
    row = path.row;
    NSLog(@"ROW IS %i",row);
    if (controlSwitch.isOn) {
        [_appDel.enabledConnections setObject:@"1" atIndexedSubscript:row];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLists" object:nil];
        // self.navigationItem.hidesBackButton = YES;
        imgView2.alpha = 0.5;
        NSLog(@"ENABLED CONNECTIONS IS NOW %@",_appDel.enabledConnections);
    }
    if(!controlSwitch.isOn){
        [_appDel.enabledConnections setObject:@"0" atIndexedSubscript:row];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLists" object:nil];
        // self.navigationItem.hidesBackButton = YES;
        imgView2.alpha = 0.5;
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
    [TestFlight passCheckpoint:@"User changed enabled connections value"];
}

- (void) enableBackButton:(NSNotification*)notification{
    self.navigationItem.hidesBackButton = NO;
    imgView2.alpha = 1;
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
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    UISwitch* controlSwitch = [tableView cellForRowAtIndexPath:indexPath].accessoryView;
//    [controlSwitch setOn:YES animated:YES];
//    storageName = [_list objectAtIndex:indexPath.row];
//    if (controlSwitch.isOn) {
//        [self performSelector:@selector(goToStorage) withObject:nil afterDelay:0.35];
//    }
//    if(!controlSwitch.isOn){
//       
//    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) goToStorage {
    [self performSegueWithIdentifier:@"goToStorage" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"goToStorage"]){
        storageViewController *svc = [segue destinationViewController];
        [svc setText:storageName];
    }
}

- (BOOL) isConnectedToInternet{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

@end
