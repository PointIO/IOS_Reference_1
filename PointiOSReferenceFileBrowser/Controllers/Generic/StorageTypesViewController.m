//
//  StorageTypesViewController.m
//  PointiOSReferenceFileBrowser
//
//  Created by jb on 6/27/13.
//  Copyright (c) 2013 PointIO. All rights reserved.
//

#import "StorageTypesViewController.h"
#import "StorageTypeCell.h"
#import "newConnectionViewController.h"
#import "newConnectionGoogleViewController.h"

@interface StorageTypesViewController ()

@end

@implementation StorageTypesViewController

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
    
    // get storageTypes
    NSURLResponse* urlResponseList1;
    NSError* requestErrorList1;
    NSMutableURLRequest *request1 = [[NSMutableURLRequest alloc] init];
    [request1 setURL:[NSURL URLWithString:@"https://api.point.io/v2/storagetypes/list.json"]];
    [request1 setHTTPMethod:@"GET"];
    [request1 addValue:_sessionKey forHTTPHeaderField:@"Authorization"];
    NSData* response1 = [NSURLConnection sendSynchronousRequest:request1 returningResponse:&urlResponseList1 error:&requestErrorList1];
    if(!response1){
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Request response is nil" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
    } else {
        _storageTypesArray = [NSJSONSerialization JSONObjectWithData:response1 options:NSJSONReadingMutableContainers error:nil];
    }
    NSLog(@"Inside StorageTypesViewController, performListCall where storageTypes are %@", _storageTypesArray);

    
    //
    // create storageSites Arrays for Names, IDs, Enabled Status, SiteTypeID and SiteTypeName
    //
    NSDictionary *resulDictionary = [_storageTypesArray valueForKey:@"RESULT"];
    NSArray *resultColumns = [resulDictionary valueForKey:@"COLUMNS"];
    NSArray *resultData = [resulDictionary valueForKey:@"DATA"];
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    _storageTypesIDsArray = [[NSMutableArray alloc] init];
    _storageTypesNamesArray = [[NSMutableArray alloc] init];
    
    for(int i=0; i<[resultData count];i++){
        NSArray* data2 = [resultData objectAtIndex:i];
        NSDictionary* temp = [NSDictionary dictionaryWithObjects:data2 forKeys:resultColumns];
        [_storageTypesIDsArray addObject:[temp valueForKey:@"SITETYPEID"]];
        [_storageTypesNamesArray addObject:[temp valueForKey:@"SITETYPENAME"]];
        //
        // evaluate storage sites for status of enabled or disabled
        //
        NSArray *keysArray = [[NSArray alloc] initWithObjects:
                              @"StorageTypeID",
                              @"StorageTypeName",
                              nil];
        
        NSArray *valuesArray = [[NSArray alloc] initWithObjects:
                                [_storageTypesIDsArray objectAtIndex:i],
                                [_storageTypesNamesArray objectAtIndex:i],
                                nil];
        
        NSDictionary *storageTypeDictionary = [[NSDictionary alloc] initWithObjects:valuesArray forKeys:keysArray];
        [tempArray addObject:storageTypeDictionary];
    }
    
    NSSortDescriptor *nameDescriptor =
    [[NSSortDescriptor alloc] initWithKey:@"StorageTypeName"
                                ascending:YES
                                 selector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSArray *descriptors = [NSArray arrayWithObjects:nameDescriptor, nil];
    NSArray *sortedArray = [tempArray sortedArrayUsingDescriptors:descriptors];
    _storageTypesArrayOfDictionaries = sortedArray;
    NSLog(@"Sorted StorageTypes is %@", _storageTypesArrayOfDictionaries);

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
    return [_storageTypesArrayOfDictionaries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StorageTypeCell *cell = (StorageTypeCell *)[tableView dequeueReusableCellWithIdentifier:@"StorageTypeCell"];
    
    // set Cell Name
    NSString *tmpSiteName = [[_storageTypesArrayOfDictionaries objectAtIndex:indexPath.row] valueForKey:@"StorageTypeName"];
    cell.nameLabel.text = tmpSiteName;
    
    // Set Cell Image
    // Values are stored in sorted Dictionary in AppContent.plist
    NSString *tmpFileName               = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"AppContent"];
    NSString *tmpFilePath               = [[NSBundle mainBundle] pathForResource:tmpFileName ofType:@"plist"];
    NSMutableDictionary *tmpDictionary  = [[NSMutableDictionary alloc] initWithContentsOfFile:tmpFilePath];
    NSDictionary *cloudProviderDict     = [tmpDictionary valueForKey:@"storageProviderArtwork"];
    NSString *tmpImageName  = [cloudProviderDict valueForKey:tmpSiteName];
    cell.storageImage.image = [UIImage imageNamed:tmpImageName];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([[segue identifier] isEqualToString:@"addConnection"]){
        
        /*
        newConnectionViewController* ncvc = [segue destinationViewController];
        [ncvc setSessionKey:_sessionKey];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        NSString *tmpSiteName = [[_storageTypesArrayOfDictionaries objectAtIndex:indexPath.row] valueForKey:@"StorageTypeName"];
        NSString *tmpSiteID = [[[_storageTypesArrayOfDictionaries objectAtIndex:indexPath.row] valueForKey:@"StorageTypeID"] stringValue];
        ncvc.requestedConnectionName = tmpSiteName;
        ncvc.siteTypeID = tmpSiteID;
        */
        
        newConnectionGoogleViewController* ncvc = [segue destinationViewController];
        // [ncvc setSessionKey:_sessionKey];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        NSString *tmpSiteName = [[_storageTypesArrayOfDictionaries objectAtIndex:indexPath.row] valueForKey:@"StorageTypeName"];
        NSString *tmpSiteID = [[[_storageTypesArrayOfDictionaries objectAtIndex:indexPath.row] valueForKey:@"StorageTypeID"] stringValue];
        // ncvc.requestedConnectionName = tmpSiteName;
        // ncvc.siteTypeID = tmpSiteID;
    }
}


@end
