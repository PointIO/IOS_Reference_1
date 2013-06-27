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
#import "Common.h"
#import <QuartzCore/QuartzCore.h>


@interface shareListViewController()

@end

@implementation shareListViewController

{
    CAGradientLayer* _gradientLayer;
}


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
    _list = [[NSMutableArray alloc] init];
    _tempArray = [[NSMutableArray alloc] init];
    
    _appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
      
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{

        NSArray *enabledSharesArray = [[NSArray alloc] init];
        enabledSharesArray = _appDel.accessRulesEnabledArray;
        NSLog(@"Inside ShareListViewController.ViewDidLoad, enabledShares from appDelegate is %@", enabledSharesArray);
        
        for (i=0; i<[enabledSharesArray count]; i++) {
            NSArray *accessRuleItem;
            accessRuleItem = [enabledSharesArray objectAtIndex:i];
             [_tempArray addObject:accessRuleItem];
        }
    
        NSSortDescriptor *nameDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"AccessRuleShareName"
                                    ascending:YES
                                     selector:@selector(localizedCaseInsensitiveCompare:)];
        
        NSArray *descriptors = [NSArray arrayWithObjects:nameDescriptor, nil];
        NSArray *sortedArray = [_tempArray sortedArrayUsingDescriptors:descriptors];
        _list = sortedArray;
        NSLog(@"Sorted Access Rules is %@", _list);

          
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.tableView reloadData];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    });
    
}

- (void) viewWillDisappear:(BOOL)animated{
}

- (void) viewDidDisappear:(BOOL)animated{
}

- (void) viewWillAppear:(BOOL)animated{
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
        [self.tableView reloadData];
    }
}

/*
- (void) reloadLists:(NSNotification *)notification{
    [self performSelectorOnMainThread:@selector(getConnections) withObject:nil waitUntilDone:YES];
    [self.tableView reloadData];
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
    ShareListCell *cell = (ShareListCell *)[tableView dequeueReusableCellWithIdentifier:@"ShareListCell"];
    
    if([_list count] != 0){
        
        cell.nameLabel.text = [[_list objectAtIndex:indexPath.row] valueForKey:@"AccessRuleShareName"];
        NSString *storageSiteSiteName = [[_list objectAtIndex:indexPath.row] valueForKey:@"AccessRuleSiteTypeName"];
        
        // Set Cell Image
        // Values are stored in sorted Dictionary in AppContent.plist
        NSString *tmpFileName               = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"AppContent"];
        NSString *tmpFilePath               = [[NSBundle mainBundle] pathForResource:tmpFileName ofType:@"plist"];
        NSMutableDictionary *tmpDictionary  = [[NSMutableDictionary alloc] initWithContentsOfFile:tmpFilePath];
        NSDictionary *cloudProviderDict     = [tmpDictionary valueForKey:@"storageProviderArtwork"];
        NSString *tmpImageName  = [cloudProviderDict valueForKey:storageSiteSiteName];
        cell.storageImage.image = [UIImage imageNamed:tmpImageName];
    }
    return cell;
}



#pragma mark
#pragma Core Graphics

-(UIColor*)colorForIndex:(NSInteger) index
{
    NSUInteger itemCount = [_list count];
    return [Common theColor:index:itemCount];
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [self colorForIndex:indexPath.row];
}

#pragma mark - Table view delegate

// Handle Disclosure Button Tap
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}




- (void)viewDidUnload {
    [super viewDidUnload];
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if(![Common isConnectedToInternet]){
        UIAlertView* err = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Looks like there is no internet connection, please check the settings" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        UIImageView* temp = [[UIImageView alloc] initWithFrame:CGRectMake(2, 0, 280, 174)];
        temp.image = [UIImage imageNamed:@"noInternetConnection.png"];
        [err addSubview:temp];
        [err setBackgroundColor:[UIColor clearColor]];
        [err show];
    }
    else if ([[segue identifier] isEqualToString:@"goToFilesFromTableViewCell"]){
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        selectedRow = indexPath.row;
        NSDictionary *selectedAccessRuleDictionary = [[NSDictionary alloc] initWithDictionary:[_list objectAtIndex:selectedRow]];
        
        UINavigationController *navigationController    = segue.destinationViewController;
        shareDetailViewController *wvc                  = [[navigationController viewControllers] objectAtIndex:0];
        
        [wvc setShareID:[selectedAccessRuleDictionary valueForKey:@"AccessRuleShareID"]];
        [wvc setFolderName:[selectedAccessRuleDictionary valueForKey:@"AccessRuleName"]];
        [wvc setSessionKey:_sessionKey];
        wvc.selectedShareID = [selectedAccessRuleDictionary valueForKey:@"AccessRuleShareID"];
        wvc.selectedShareName = [selectedAccessRuleDictionary valueForKey:@"AccessRuleName"];
    }
    else if([[segue identifier] isEqualToString:@"addConnection"]){
        // newConnectionViewController* ncvc = [segue destinationViewController];
        // [ncvc setUserStorageInput:_userStorageInput];
        // [ncvc setSessionKey:_sessionKey];
        // [ncvc setSiteTypeID:[_storageIDs objectAtIndex:i]];
        // [ncvc setAllPossibleConnections:_allPossibleConnections];
        // [ncvc setRequestedConnectionName:requestedConnectionName];
    }

}

@end
