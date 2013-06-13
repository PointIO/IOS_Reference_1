//
//  workspaceListViewController.m
//  PointiOSReferenceFileBrowser
//
//  Created by jb on 6/13/13.
//  Copyright (c) 2013 PointIO. All rights reserved.
//

#import "workspaceListViewController.h"

@interface workspaceListViewController ()

@end

@implementation workspaceListViewController

int i;
UIImageView* imgView;
UIImageView* imgView2;
UILabel* sharedFolderLabel;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark View Lifecycle
- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.navigationItem.title = _storageName;
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
            
            _folderNames = [NSMutableArray array];
            _folderShareIDs = [NSMutableArray array];
            for(int i=0; i<[datax count];i++){
                NSArray* data2 = [datax objectAtIndex:i];
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
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self.tableView reloadData];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            });
        }
    });
}

- (void) viewWillDisappear:(BOOL)animated{
    [UIView animateWithDuration:0.25 animations:^(void) {
        imgView.alpha = 0;
        imgView2.alpha = 0;
        sharedFolderLabel.alpha = 0;
    }];
    imgView = nil;
    imgView2 = nil;
    sharedFolderLabel = nil;
}

- (void) viewWillAppear:(BOOL)animated{
    if(!imgView){
        sharedFolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 16, 150, 50)];
        sharedFolderLabel.backgroundColor = [UIColor clearColor];
        sharedFolderLabel.text = _storageName;
        sharedFolderLabel.textColor = [UIColor whiteColor];
        [sharedFolderLabel setTextAlignment:UITextAlignmentCenter];
        sharedFolderLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:18.0];
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 320, 44)];
        imgView.image = [UIImage imageNamed:@"blueBarImageClean.png"];
        [self.navigationController.view addSubview:imgView];
        imgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(5, 27, 50, 29)];
        imgView2.image = [UIImage imageNamed:@"backButton.png"];
        [self.navigationController.view addSubview:imgView2];
        [self.navigationController.view addSubview:sharedFolderLabel];
    }
    
    imgView.alpha = 0;
    imgView2.alpha = 0;
    sharedFolderLabel.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^(void) {
        imgView.alpha = 1;
        imgView2.alpha = 1;
        sharedFolderLabel.alpha = 1;
    }];
}

- (void) viewDidAppear:(BOOL)animated{
    // [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning{
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
    cell.textLabel.text = [_list objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;}

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
    i = indexPath.row;
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary* allFoldersForAllShareIDs = [NSDictionary dictionaryWithObjects:_folderShareIDs forKeys:_folderNames];
    NSLog(@"ALL FOLDERS FOR ALL SHARE IDS - %@",allFoldersForAllShareIDs);
    NSString* chosenShareID = [allFoldersForAllShareIDs valueForKey:[_list objectAtIndex:i]];
    NSLog(@"SHARE ID = %@", chosenShareID);
    
    // JB 6/9/13: Add error test for Null chosenShareID which will occur if no Access Rules defined
    if (chosenShareID == NULL) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Access Rules Not Defined"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
        return;
    }
    else {
        [self performSegueWithIdentifier:@"goToFiles" sender:self];
    }
}



- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"goToFiles"]){
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

@end
