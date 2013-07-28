//
//  getAccountViewController.m
//  PointiOSReferenceFileBrowser
//
//  Created by jimboyle on 7/27/13.
//  Copyright (c) 2013 PointIO. All rights reserved.
//

#import "getAccountViewController.h"
#import "MBProgressHUD.h"
#import "Common.h"


@interface getAccountViewController ()

@end

@implementation getAccountViewController


static NSString *const kPointAPIKey = @"b022de6e-9bf6-11e2-b014-12313b093415";
static NSString *const kPointAPISecret = @"NX6KLn8nQWy1mz0QI8KlNquUqEArkpqmyv5ic7Vtee2vRWGONROnqSEMSHGmYtp";

NSArray* temp;


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

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}


- (IBAction)okButtonPressed:(id)sender  {
    [self.delegate getAccountViewController:self didSelectValue:nil];
}


- (IBAction)cancelButtonPressed:(id)sender {
    [self.delegate getAccountViewController:self didSelectValue:nil];
}

- (void) getPartnerSession{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        NSDictionary* params = @{
                                 @"email":@"alex@valexconsulting.com",
                                 @"password":@"Valex123",
                                 @"apikey":@"b022de6e-9bf6-11e2-b014-12313b093415"
                                 };
        
        NSMutableArray* pairs = [[NSMutableArray alloc] initWithCapacity:0];
        for(NSString* key in params){
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, params[key]]];
        }
        NSString* requestParams = [pairs componentsJoinedByString:@"&"];
        
        NSURLResponse* urlResponseList;
        NSError* requestErrorList;
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:@"https://api.point.io/api/v2/users/preauth.json"]];
        [request setHTTPMethod:@"POST"];
        NSData* payload = [requestParams dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:payload];
        NSData* response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponseList error:&requestErrorList];
        if(!response){
            UIAlertView* alert = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:@"Request response is nil"
                                  delegate:nil
                                  cancelButtonTitle:@"Dismiss"
                                  otherButtonTitles: nil];
            [alert show];
        }
        else {
            NSArray* temp = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
            _partnerSession = [temp valueForKey:@"PARTNERKEY"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self createUser];
            });
        }
    });
    
}


- (void) createUser{
    
    // NSString *kPAPIKey = [Common getAppKey:@"kPointAppId"];
    // NSString *kPAPISecret = [Common getAppKey:@"keyPointAppSecret"];
    NSArray* objects = [NSArray arrayWithObjects:
                        [_emailTextField text],
                        [_firstNameTextField text],
                        [_lastNameTextField text],
                        [_passwordTextField text],
                        kPointAPIKey,
                        kPointAPISecret,
                        nil];
    NSArray* keys = [NSArray arrayWithObjects:
                     @"email",
                     @"firstname",
                     @"lastname",
                     @"password",
                     @"appId",
                     @"appSecret",
                     nil];
    NSDictionary* params = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    NSMutableArray* pairs = [[NSMutableArray alloc] initWithCapacity:0];
    for(NSString* key in params){
        if(params[key] == nil){
            break;
        }
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, params[key]]];
    }
    NSString* requestParams = [pairs componentsJoinedByString:@"&"];
    NSURLResponse* urlResponseList;
    NSError* requestErrorList;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://api.point.io/api/v2/users/create.json"]];
    [request setHTTPMethod:@"POST"];
    NSData* payload = [requestParams dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:payload];
    [request addValue:_partnerSession forHTTPHeaderField:@"Authorization"];
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
        NSArray *temp = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
        if([[temp valueForKey:@"ERROR"]integerValue] == 1){
            NSString* message = [temp valueForKey:@"MESSAGE"];
            message = [message stringByReplacingOccurrencesOfString:@"ERROR - " withString:@""];
            UIAlertView* alert = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:message
                                  delegate:nil
                                  cancelButtonTitle:@"Dismiss"
                                  otherButtonTitles:nil];
            [alert show];
        } else {
            UIAlertView* alert = [[UIAlertView alloc]
                                  initWithTitle:@"Success"
                                  message:@"Account Created"
                                  delegate:nil
                                  cancelButtonTitle:@"Dismiss"
                                  otherButtonTitles:nil];
            [alert show];
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    }
}


#pragma mark
#pragma Implement Delegate Methods
- (void)passwordPickerViewControllerDidCancel:(passwordPickerViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)passwordPickerViewController:(passwordPickerViewController *)controller didSelectValue:(NSString *)theSelectedValue {
    [self dismissViewControllerAnimated:YES completion:nil];
    _passwordTextField.text = theSelectedValue;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"goToPasswordPicker"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        passwordPickerViewController *pickerVC  = [[navigationController viewControllers] objectAtIndex:0];
        pickerVC.delegate = self;
    }
}




@end
