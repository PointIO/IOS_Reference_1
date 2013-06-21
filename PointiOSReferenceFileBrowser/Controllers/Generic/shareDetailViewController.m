//
//  shareDetailViewController.m
//  PointiOSReferenceFileBrowser
//
//  Created by jimmyboyle on 6/15/13.
//  Copyright (c) 2013 PointIO. All rights reserved.
//

#import "shareDetailViewController.h"
#import "ShareDetailCell.h"


@interface shareDetailViewController ()

@end

@implementation shareDetailViewController

@synthesize i;
@synthesize nestedFoldersCounter;

NSString* chosenFolderTitle;
NSString* rootFolderTitle;
NSMutableArray* tempContainer;

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

- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = _selectedShareName;
    
    // [_backButton setEnabled:NO];
    
    i = 0;
    nestedFoldersCounter = 0;
    [_backButton setEnabled:NO];
    // self.navigationItem.backBarButtonItem.enabled = YES;
    // self.navigationItem.backBarButtonItem.title = @"Back";
    // self.navigationItem.title = _folderName;
    
    _remotePath = @"/";
    // rootFolderTitle = self.navigationItem.title;
    
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
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [self getFileNamesAndFileIDs];
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self.tableView reloadData];
                [TestFlight passCheckpoint:@"User loaded his workspace successfully"];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            });
        });
    }
}

- (void) viewWillAppear:(BOOL)animated{
}

- (void) viewWillDisappear:(BOOL)animated{
}

- (void) viewDidAppear:(BOOL)animated{
    // [self.navigationController setToolbarHidden:YES animated:YES];
    self.navigationItem.title = _selectedShareName;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_fileNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    int row = indexPath.row;
    ShareDetailCell *cell = (ShareDetailCell *)[tableView dequeueReusableCellWithIdentifier:@"ShareDetailCell"];
    
    if([_fileNames count] != 0){
        
        cell.nameLabel.text = [_fileNames objectAtIndex:indexPath.row];
        cell.dateModifiedLabel.text = [_fileDateModified objectAtIndex:indexPath.row];
        
        if([[_isFolder objectAtIndex:row] boolValue] == NO) {
            cell.typeImage.image = [UIImage imageNamed:@"Document"];
        } else {
            cell.typeImage.image = [UIImage imageNamed:@"FileCabinet.png"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // [_backButton setEnabled:YES];
    
    i = indexPath.row;
    NSLog(@"%@",_fileIDs);
    
    //TIP IOS-12
    if([[_isFolder objectAtIndex:i] boolValue] == NO) {
        NSLog(@"IS NOT A FOLDER");
        [self performSegueWithIdentifier:@"viewDocument" sender:nil];
    } else {
        NSLog(@"IS A FOLDER");
        if (!_containerIDHistory) {
            _containerIDHistory = [NSMutableArray array];
        }
        [_containerIDHistory addObject:_containerID];
        [self setRemotePath:[_remotePath stringByAppendingFormat:@"%@/",[_fileNames objectAtIndex:i]]];
        [self setContainerID:[_containerIDs objectAtIndex:i]];
        NSLog(@"REMOTE PATH = %@",_remotePath);
        
        nestedFoldersCounter++;
        chosenFolderTitle = [_fileNames objectAtIndex:indexPath.row];
        NSLog(@"CHOSEN FOLDER = %@",chosenFolderTitle);
        
        _lastFolderTitle = chosenFolderTitle;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            [self getFileNamesAndFileIDs];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self.navigationItem setTitle:chosenFolderTitle];
                [_backButton setEnabled:YES];
                [self.tableView reloadData];
                /*
                [UIView animateWithDuration:0.15 animations:^(void) {
                    [sharedFolderLabel setAlpha:0];
                }];
                [sharedFolderLabel setText:chosenFolderTitle];
                [UIView animateWithDuration:0.15 animations:^(void) {
                    [sharedFolderLabel setAlpha:1];
                }];
                */
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                /*
                UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                         style:UIBarButtonItemStyleBordered
                                                                        target:self
                                                                        action:@selector(showPastFolder)];
                self.navigationItem.hidesBackButton = YES;
                self.navigationItem.leftBarButtonItem = item;
                */
            });
        });
    }
}


#pragma mark - Business Logic
- (void) getFileNamesAndFileIDs{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURLResponse* urlResponseList;
    NSError* requestErrorList;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString* URLString = [NSString stringWithFormat:@"https://api.point.io/api/v2/folders/list.json"];
    
    NSMutableArray* objects;
    NSMutableArray* keys;
    if(_containerID){
        objects = [NSArray arrayWithObjects:_shareID,_remotePath,_containerID,nil];
        keys = [NSArray arrayWithObjects:@"folderid",@"path",@"containerid",nil];
    } else {
        objects = [NSArray arrayWithObjects:_shareID,_remotePath,nil];
        keys = [NSArray arrayWithObjects:@"folderid",@"path",nil];
    }
    
    NSDictionary* params = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    NSMutableArray* pairs = [[NSMutableArray alloc] initWithCapacity:0];
    for(NSString* key in params){
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, params[key]]];
    }
    
    NSString* requestParams = [pairs componentsJoinedByString:@"&"];
    URLString = [URLString stringByAppendingFormat:@"?%@",requestParams];
    URLString = [URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [request setURL:[NSURL URLWithString:URLString]];
    NSLog(@"URL STRING = %@",URLString);
    
    [request setHTTPMethod:@"POST"];
    [request addValue:_sessionKey forHTTPHeaderField:@"Authorization"];
    NSData* response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponseList error:&requestErrorList];
    if(!response){
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Request response is nil" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
    } else {
        NSArray* listFilesResponse = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"list file response = %@",listFilesResponse);
        
        _containerID = [listFilesResponse valueForKey:@"CONTAINERID"];
        _fileNames = nil;
        _fileIDs = nil;
        _fileShareIDs = nil;
        _filePaths = nil;
        _containerIDs = nil;
        //TIP IOS-12
        _isFolder = nil;
        
        _isFolder = [NSMutableArray array];
        _fileNames = [NSMutableArray array];
        _filePaths = [NSMutableArray array];
        _fileIDs = [NSMutableArray array];
        _fileShareIDs = [NSMutableArray array];
        _containerIDs = [NSMutableArray array];
        _fileDateModified = [[NSMutableArray alloc] init];
        
        NSDictionary* result = [listFilesResponse valueForKey:@"RESULT"];
        NSArray* columns = [result valueForKey:@"COLUMNS"];
        NSArray* data = [result valueForKey:@"DATA"];
        for(int j=0; j<[data count];j++){
            NSArray* data2 = [data objectAtIndex:j];
            NSDictionary* temp = [NSDictionary dictionaryWithObjects:data2 forKeys:columns];
            [_fileNames addObject:[temp valueForKey:@"NAME"]];
            [_fileIDs addObject:[temp valueForKey:@"FILEID"]];
            //TIP finish logic to distinguish between folder and file IOS-12
            if ([[temp valueForKey:@"TYPE"] rangeOfString:@"DIR"].location == NSNotFound) {
                //This is a file
                [_isFolder addObject:@0];
                //[_isFolder addObject:[NSNumber numberWithInt:0]];
            }
            else {
                //This is a folder
                [_isFolder addObject:@1];
                //[_isFolder addObject:[NSNumber numberWithInt:1]];
            }
            [_fileShareIDs addObject:[temp valueForKey:@"SHAREID"]];
            [_containerIDs addObject:[temp valueForKey:@"CONTAINERID"]];
            [_filePaths addObject:[temp valueForKey:@"PATH"]];
            [_fileDateModified addObject:[temp valueForKey:@"MODIFIED"]];
        }
    }
    NSLog(@"NUMBER OF FILES = %i",[_fileNames count]);
}


- (void) showPastFolder{
    NSMutableArray* subs = [NSMutableArray arrayWithArray:[_remotePath componentsSeparatedByString:@"/"]];
    [subs removeLastObject];
    [subs removeLastObject];
    
    NSString* temp = [[NSString alloc] init];
    tempContainer = nil;
    tempContainer = [NSMutableArray array];
    for(int j = 0;j<[subs count];j++){
        if (![[subs objectAtIndex:j] isEqualToString:@""]) {
            [tempContainer addObject:[subs objectAtIndex:j]];
        }
    }
    NSLog(@"TEMP CONTAINER = %@",tempContainer);
    for(int j = 0;j<[tempContainer count];j++){
        if(j ==0){
            temp = [NSString stringWithFormat:@"/%@",[tempContainer objectAtIndex:0]];
        } else {
            temp = [temp stringByAppendingFormat:@"/%@/",[tempContainer objectAtIndex:j]];
        }
    }
    NSLog(@"TEMP STRING PATH = %@",temp);
    _remotePath = temp;
    _containerID = [_containerIDHistory lastObject];
    
    nestedFoldersCounter--;
    if(nestedFoldersCounter == 0) {
        // self.navigationItem.hidesBackButton = NO;
        // self.navigationItem.leftBarButtonItem = nil;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self getFileNamesAndFileIDs];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.tableView reloadData];
            if([tempContainer count] != 0){
                // self.navigationItem.title = [tempContainer lastObject];
                // [sharedFolderLabel setText:[tempContainer lastObject]];
            } else {
                // self.navigationItem.title = rootFolderTitle;
                /*
                [UIView animateWithDuration:0.15 animations:^(void) {
                    [sharedFolderLabel setAlpha:0];
                }];
                [sharedFolderLabel setText:rootFolderTitle];
                [UIView animateWithDuration:0.15 animations:^(void) {
                    [sharedFolderLabel setAlpha:1];
                }];
                */
            }
            [_containerIDHistory removeLastObject];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    });
    
}


- (IBAction)showPastFolder:(id)sender {
    NSMutableArray* subs = [NSMutableArray arrayWithArray:[_remotePath componentsSeparatedByString:@"/"]];
    [subs removeLastObject];
    [subs removeLastObject];
    
    NSString* temp = [[NSString alloc] init];
    tempContainer = nil;
    tempContainer = [NSMutableArray array];
    for(int j = 0;j<[subs count];j++){
        if (![[subs objectAtIndex:j] isEqualToString:@""]) {
            [tempContainer addObject:[subs objectAtIndex:j]];
        }
    }
    NSLog(@"TEMP CONTAINER = %@",tempContainer);
    for(int j = 0;j<[tempContainer count];j++){
        if(j ==0){
            temp = [NSString stringWithFormat:@"/%@",[tempContainer objectAtIndex:0]];
        } else {
            temp = [temp stringByAppendingFormat:@"/%@/",[tempContainer objectAtIndex:j]];
        }
    }
    NSLog(@"TEMP STRING PATH = %@",temp);
    _remotePath = temp;
    _containerID = [_containerIDHistory lastObject];
    
    nestedFoldersCounter--;
    if(nestedFoldersCounter == 0) {
        [_backButton setEnabled:NO];
        // self.navigationItem.hidesBackButton = NO;
        // self.navigationItem.leftBarButtonItem = nil;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self getFileNamesAndFileIDs];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.tableView reloadData];
            if([tempContainer count] != 0){
                // self.navigationItem.title = [tempContainer lastObject];
                // [sharedFolderLabel setText:[tempContainer lastObject]];
            } else {
                // self.navigationItem.title = rootFolderTitle;
                /*
                [UIView animateWithDuration:0.15 animations:^(void) {
                    [sharedFolderLabel setAlpha:0];
                }];
                [sharedFolderLabel setText:rootFolderTitle];
                [UIView animateWithDuration:0.15 animations:^(void) {
                    [sharedFolderLabel setAlpha:1];
                }];
                */
            }
            [_containerIDHistory removeLastObject];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    });
    
}


#pragma mark - Segues
- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"viewDocument"]){
        docViewerViewController* dvvc = [segue destinationViewController];
        [dvvc setShareID:[_fileShareIDs objectAtIndex:i]];
        [dvvc setFileName:[_fileNames objectAtIndex:i]];
        [dvvc setFileID:[_fileIDs objectAtIndex:i]];
        [dvvc setRemotePath:_remotePath];
        [dvvc setContainerID:_containerID];
        [dvvc setSessionKey:_sessionKey];
        NSLog(@"LAST FOLDER TITLE = %@",_lastFolderTitle);
    }
}


- (BOOL) isConnectedToInternet{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}


@end
