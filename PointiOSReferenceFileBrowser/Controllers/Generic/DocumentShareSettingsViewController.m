//
//  DocumentShareSettingsViewController.m
//  PointiOSReferenceFileBrowser
//
//  Created by jimboyle on 7/18/13.
//  Copyright (c) 2013 PointIO. All rights reserved.
//

#import "DocumentShareSettingsViewController.h"
#import "Common.h"
#import "passwordPickerViewController.h"

@interface DocumentShareSettingsViewController ()

@end

@implementation DocumentShareSettingsViewController


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

    // _appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    // shouldCheck = YES;
    // shareSecurelyPressed = NO;
    
    _printSwitch = FALSE;
    _downloadSwitch = FALSE;
    _screenCaptureSwitch = FALSE;
    _downloadAsPDFSwitch = FALSE;
    _restrictByIPSwitch = FALSE;

    _expireSwitch = FALSE;
    _passwordSwitch = FALSE;
    
    _expirationDateString = nil;
    _password=nil;
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    if ((indexPath.section == 0)) {
        switch (indexPath.row) {
            case 0:
                NSLog(@"Toggle Print");
                _printSwitch = !_printSwitch;
                break;
            case 1:
                NSLog(@"Toggle Download");
                _downloadSwitch = !_downloadSwitch;
                break;
            case 2:
                NSLog(@"Toggle PDF Download");
                _downloadAsPDFSwitch = !_downloadAsPDFSwitch;
                break;
            default:
                break;
        }
    }
    else if ((indexPath.section == 1)) {
        switch (indexPath.row) {
            case 0:
                NSLog(@"Toggle Expire");
                if (!_expireSwitch){
                    _expireSwitch = !_expireSwitch;
                    [self performSegueWithIdentifier:@"goToDatePicker" sender:self];
                }
                else {
                    _expireDateLabel.text = nil;
                    _expireSwitch = !_expireSwitch;
                }
                break;
            case 1:
                NSLog(@"Toggle Password");
                if (!_passwordSwitch){
                    _passwordSwitch = !_passwordSwitch;
                    [self performSegueWithIdentifier:@"goToPasswordPicker" sender:self];
                }
                else {
                    _passwordSwitch = !_passwordSwitch;
                }
                break;
        }
    }
    else if ((indexPath.section == 2)) {
        switch (indexPath.row) {
            case 0:
                NSLog(@"Toggle Capture");
                _screenCaptureSwitch = !_screenCaptureSwitch;
                break;
            case 1:
                NSLog(@"Toggle Forwarding");
                _restrictByIPSwitch = !_restrictByIPSwitch;
                break;
            default:
                break;
        }
    }
}



- (void)expireSwitchValueChanged{
    if(_expireSwitch){
        [self performSegueWithIdentifier:@"goToDatePicker" sender:self];
    }
}


- (IBAction)shareSecurelyPressed:(id)sender {
    
    if(![Common isConnectedToInternet]){
        UIAlertView* err = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Looks like there is no internet connection, please check the settings" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        UIImageView* temp = [[UIImageView alloc] initWithFrame:CGRectMake(2, 0, 280, 174)];
        temp.image = [UIImage imageNamed:@"noInternetConnection.png"];
        [err addSubview:temp];
        [err setBackgroundColor:[UIColor clearColor]];
        [err show];
    } else {
        if ([MFMailComposeViewController canSendMail])
        {
            MFMailComposeViewController *mailer = [MFMailComposeViewController new];
            mailer.mailComposeDelegate = self;
            [[mailer navigationBar] setTintColor:[UIColor colorWithRed:0.10980392156863f green:0.37254901960784f blue:0.6078431372549f alpha:1]];
            NSURLResponse* urlResponseList;
            NSError* requestErrorList;
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:[NSURL URLWithString:@"https://api.point.io/v2/links/create.json"]];
            [request setHTTPMethod:@"POST"];
            [request addValue:_sessionKey forHTTPHeaderField:@"Authorization"];
            NSString* requestParams = [NSString stringWithFormat:@"shareId=%@&fileid=%@&filename=%@&remotepath=%@&containerid=%@",
                                       _shareID,
                                       _fileID,
                                       _fileName,
                                       _remotePath,
                                       _containerID];
            if(_printSwitch){
                requestParams = [requestParams stringByAppendingFormat:@"&allowPrint=1"];
            } else {
                requestParams = [requestParams stringByAppendingFormat:@"&allowPrint=0"];
            }
            
            if(_downloadSwitch){
                requestParams = [requestParams stringByAppendingFormat:@"&allowDownload=1"];
            } else {
                requestParams = [requestParams stringByAppendingFormat:@"&allowDownload=0"];
            }
            
            if(_screenCaptureSwitch){
                requestParams = [requestParams stringByAppendingFormat:@"&maskDisplay=SMALL"];
            } else {
                requestParams = [requestParams stringByAppendingFormat:@"&maskDisplay=NONE"];
            }

            if(_downloadAsPDFSwitch){
                requestParams = [requestParams stringByAppendingFormat:@"&allowDownloadAsPDF=1"];
            } else {
                requestParams = [requestParams stringByAppendingFormat:@"&allowDownloadAsPDF=0"];
            }

            if(_restrictByIPSwitch){
                requestParams = [requestParams stringByAppendingFormat:@"&restrictByIP=1"];
            } else {
                requestParams = [requestParams stringByAppendingFormat:@"&restrictByIP=0"];
            }

            if(_expireSwitch){
                requestParams = [requestParams stringByAppendingFormat:@"&expirationDate=%@",_expirationDateString];
            }
            
            if(_passwordSwitch){
                requestParams = [requestParams stringByAppendingFormat:@"&password=%@",_password];
            }
            
            NSLog(@"REQUEST PARAMS = %@",requestParams);
            NSData* payload = [requestParams dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:payload];
            NSData* response = [NSURLConnection sendSynchronousRequest:request
                                                     returningResponse:&urlResponseList
                                                                 error:&requestErrorList];
            if(!response){
                UIAlertView* alert = [[UIAlertView alloc]
                                      initWithTitle:@"Error"
                                      message:@"Request response is nil"
                                      delegate:nil
                                      cancelButtonTitle:@"Dismiss"
                                      otherButtonTitles: nil];
                [alert show];
            } else {
                NSArray* temp = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
                if([[temp valueForKey:@"ERROR"] integerValue] == 0) {
                    NSString* downloadLink = [temp valueForKey:@"LINKURL"];
                    NSString *emailBody = [NSString stringWithFormat:@"Hello,\n I wanted to share %@ with you.\n Secure download link: %@",_fileName,downloadLink];
                    [mailer setMessageBody:emailBody isHTML:NO];
                    [mailer setSubject:_fileName];
                    [self presentViewController:mailer animated:YES completion:^(void){
                        // shareSecurelyPressed = YES;
                    }];
                }
                else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:@"Link Request Failed"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Dismiss"
                                                          otherButtonTitles: nil];
                    [alert show];
                }
            }
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Your device doesn't support email composer"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles: nil];
            [alert show];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}


- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    if(result == MFMailComposeResultSent){
        [TestFlight passCheckpoint:@"User sent a mail"];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if(result == MFMailComposeResultCancelled){
        [TestFlight passCheckpoint:@"User cancelled sending a mail"];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if(result == MFMailComposeResultSaved){
        [TestFlight passCheckpoint:@"User saved a mail"];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if(result == MFMailComposeResultFailed){
        [TestFlight passCheckpoint:@"User failed to send a mail"];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
}


#pragma mark
#pragma Implement Delegate Methods
- (void)passwordPickerViewControllerDidCancel:(passwordPickerViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
    _password = nil;
}


- (void)passwordPickerViewController:(passwordPickerViewController *)controller didSelectValue:(NSString *)theSelectedValue {
    [self dismissViewControllerAnimated:YES completion:nil];
    _password = theSelectedValue;
}

- (void)datePickerViewControllerDidCancel:(datePickerViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)datePickerViewController:(datePickerViewController *)controller didSelectValue:(NSString *)theSelectedValue {
    [self dismissViewControllerAnimated:YES completion:nil];
    _expirationDateString = theSelectedValue;
    _expireDateLabel.text = theSelectedValue;
}



#pragma mark
#pragma Segue Logic

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goToPasswordPicker"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        passwordPickerViewController *pickerVC  = [[navigationController viewControllers] objectAtIndex:0];
        pickerVC.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"goToDatePicker"])
    {
        datePickerViewController *pickerVC = segue.destinationViewController;
        pickerVC.delegate = self;
    }
}

@end
