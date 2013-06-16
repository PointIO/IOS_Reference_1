//
//  shareListViewController.m
//  PointiOSReferenceFileBrowser
//
//  Created by jb on 6/13/13.
//  Copyright (c) 2013 PointIO. All rights reserved.
//

#import "shareListViewController.h"
#import "ShareListCell.h"
#import "shareDetailViewController.h"


@interface shareListViewController()

@end

@implementation shareListViewController

int selectedRow;
int i;



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
     
    _JSONSharedFoldersArray = [NSArray array];
    _list = [NSMutableArray array];
      
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
                [_folderNames addObject:[temp valueForKey:@"SHARENAME"]];
                [_folderShareIDs addObject:[temp valueForKey:@"SHAREID"]];
                [_list addObject:[temp valueForKey:@"SHARENAME"]];
                // NSLog(@"Folder Names are %@", _folderNames);
                // NSLog(@"List contents are%@", _list);
                // NSLog(@"Folder Share IDs are %@", _folderShareIDs);
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self.tableView reloadData];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            });
        }
    });
 }

- (void) viewWillDisappear:(BOOL)animated{
}

- (void) viewDidDisappear:(BOOL)animated{
}

- (void) viewWillAppear:(BOOL)animated{
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
        [self.tableView reloadData];
    }
}

- (void) reloadLists:(NSNotification *)notification{
    [self performSelectorOnMainThread:@selector(getConnections) withObject:nil waitUntilDone:YES];
    [self.tableView reloadData];
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
    return [_list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShareListCell *cell = (ShareListCell *)[tableView dequeueReusableCellWithIdentifier:@"ShareListCell"];
    
    if([_list count] != 0){
        cell.nameLabel.text = [_list objectAtIndex:indexPath.row];
    }
    return cell;
}



#pragma mark - Table view delegate

// Handle Disclosure Button Tap
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"goToFiles" sender:indexPath];
    /*
    selectedRow = indexPath.row;
    NSDictionary *allFolderNamesForAllShareIDs = [NSDictionary dictionaryWithObjects:_folderNames forKeys:_folderShareIDs];
    _selectedShareName = [allFolderNamesForAllShareIDs valueForKey:[_folderShareIDs objectAtIndex:selectedRow]];
    NSLog(@"Chosen Folder Name from inside didSelectRowAtIndexPath %@", _selectedShareName);

    [self performSegueWithIdentifier:@"goToFiles" sender:indexPath];
    */
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    selectedRow = indexPath.row;
    NSDictionary *allFolderNamesForAllShareIDs = [NSDictionary dictionaryWithObjects:_folderNames forKeys:_folderShareIDs];
    _selectedShareName = [allFolderNamesForAllShareIDs valueForKey:[_folderShareIDs objectAtIndex:selectedRow]];
    NSLog(@"Chosen Folder Name from inside didSelectRowAtIndexPath %@", _selectedShareName);
    
    [self performSegueWithIdentifier:@"goToFiles" sender:indexPath];
    */
}



- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if(![self isConnectedToInternet]){
        UIAlertView* err = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Looks like there is no internet connection, please check the settings" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        UIImageView* temp = [[UIImageView alloc] initWithFrame:CGRectMake(2, 0, 280, 174)];
        temp.image = [UIImage imageNamed:@"noInternetConnection.png"];
        [err addSubview:temp];
        [err setBackgroundColor:[UIColor clearColor]];
        [err show];
    }
    else{
        if([[segue identifier] isEqualToString:@"goToFiles"]){
            
            NSIndexPath *indexPath = sender;
            selectedRow = indexPath.row;
            NSDictionary *allFolderNamesForAllShareIDs = [NSDictionary dictionaryWithObjects:_folderNames forKeys:_folderShareIDs];
            _selectedShareName = [allFolderNamesForAllShareIDs valueForKey:[_folderShareIDs objectAtIndex:selectedRow]];
            NSLog(@"Chosen Folder Name from inside didSelectRowAtIndexPath %@", _selectedShareName);

            
            NSDictionary* allFoldersForAllShareIDs = [NSDictionary dictionaryWithObjects:_folderShareIDs forKeys:_folderNames];
            NSString* chosenShareID = [allFoldersForAllShareIDs valueForKey:[_list objectAtIndex:selectedRow]];
            
            UINavigationController *navigationController = segue.destinationViewController;
            shareDetailViewController *wvc = [[navigationController viewControllers] objectAtIndex:0];
            
            [wvc setShareID:chosenShareID];
            [wvc setFolderName:[_list objectAtIndex:i]];
            [wvc setSessionKey:_sessionKey];
            wvc.selectedShareID = _selectedShareID;
            wvc.selectedShareName = _selectedShareName;
        }
        else if ([[segue identifier] isEqualToString:@"goToFilesFromTableViewCell"]){
            
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            selectedRow = indexPath.row;
            NSDictionary *allFolderNamesForAllShareIDs = [NSDictionary dictionaryWithObjects:_folderNames forKeys:_folderShareIDs];
            _selectedShareName = [allFolderNamesForAllShareIDs valueForKey:[_folderShareIDs objectAtIndex:selectedRow]];
            NSLog(@"Chosen Folder Name from inside didSelectRowAtIndexPath %@", _selectedShareName);

            NSDictionary* allFoldersForAllShareIDs = [NSDictionary dictionaryWithObjects:_folderShareIDs forKeys:_folderNames];
            NSString* chosenShareID = [allFoldersForAllShareIDs valueForKey:[_list objectAtIndex:selectedRow]];
                
            UINavigationController *navigationController    = segue.destinationViewController;
            shareDetailViewController *wvc                  = [[navigationController viewControllers] objectAtIndex:0];
                
            [wvc setShareID:chosenShareID];
            [wvc setFolderName:[_list objectAtIndex:i]];
            [wvc setSessionKey:_sessionKey];
            wvc.selectedShareID = _selectedShareID;
            wvc.selectedShareName = _selectedShareName;
            
            /*
             UINavigationController *navigationController            = segue.destinationViewController;
             PlayerDetailViewController *playerDetailViewController  = [[navigationController viewControllers] objectAtIndex:0];
             playerDetailViewController.delegate                     = self;
             
             NSIndexPath *indexPath                                  = [self.tableView indexPathForCell:sender];
             
             Player *player                                          = [self.fetchedResultsController objectAtIndexPath:indexPath];
             playerDetailViewController.playerToEdit                 = player;
             */
        }
    }
}

- (BOOL) isConnectedToInternet{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
