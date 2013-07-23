//
//  DocumentShareSettingsViewController.m
//  PointiOSReferenceFileBrowser
//
//  Created by jimboyle on 7/18/13.
//  Copyright (c) 2013 PointIO. All rights reserved.
//

#import "DocumentShareSettingsViewController.h"
#import "Common.h"

@interface DocumentShareSettingsViewController ()

@end

@implementation DocumentShareSettingsViewController


UITextField* passwordTextField, *reenterPasswordTextField;
UIAlertView* passwordAlertView;
// BOOL shareSecurelyPressed;
// BOOL shouldCheck;



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

    _appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    // shouldCheck = YES;
    // shareSecurelyPressed = NO;
    
    _printSwitch = FALSE;
    _downloadSwitch = FALSE;
    _expireSwitch = FALSE;
    _forwardingSwitch = FALSE;
    _screenCaptureSwitch = FALSE;
    _passwordSwitch = FALSE;
    
    // _passwordsDontMatchLabel.alpha = 0;
    // _passwordsDontMatchLabel.frame = CGRectMake(_passwordsDontMatchLabel.frame.origin.x, _passwordSwitch.frame.origin.y + 20, _passwordsDontMatchLabel.frame.size.width, _passwordsDontMatchLabel.frame.size.height);
    // [_expireSwitch addTarget:self action:@selector(expireSwitchValueChanged) forControlEvents:UIControlEventValueChanged];
    // [_passwordSwitch addTarget:self action:@selector(passwordSwitchValueChanged) forControlEvents:UIControlEventValueChanged];
    // _shareSecurelyButton.width = 0.01;
    
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
                NSLog(@"Toggle Capture");
                _screenCaptureSwitch = !_screenCaptureSwitch;
                break;
            /*
            case 3:
                NSLog(@"Toggle Forward");
                _forwardingSwitch = !_forwardingSwitch;
                break;
            */
            default:
                break;
        }
    }
    else if ((indexPath.section == 1)) {
        switch (indexPath.row) {
            case 0:
                NSLog(@"Toggle Expire");
                if (_expireSwitch){
                    [self performSegueWithIdentifier:@"getTheDate" sender:self];
                }
                _expireSwitch = !_expireSwitch;
                break;
            case 1:
                NSLog(@"Toggle Password");
                _passwordSwitch = !_passwordSwitch;
                [self passwordSwitchValueChanged];
                /*
                if (_passwordSwitch){
                    [self performSegueWithIdentifier:@"getThePassword" sender:self];
                }
                */
                break;
            default:
                break;
        }
    }
}

- (void)expireSwitchValueChanged{
    if(_expireSwitch){
        [self performSegueWithIdentifier:@"getTheDate" sender:self];
    }
}


- (void)passwordSwitchValueChanged{
    if(_passwordSwitch){
        passwordAlertView = [[UIAlertView alloc] initWithTitle:@"   "
                                                       message:@"   "
                                                      delegate:self
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:@"OK", nil];
        passwordAlertView.frame = CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2, passwordAlertView.bounds.size.width, 400);
        _passwordsDontMatchLabel.alpha = 0;
        [_passwordsDontMatchLabel setHidden:NO];
        UIImageView* customAlert = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 283, 133)];
        [customAlert setImage:[UIImage imageNamed:@"passwordsAlertView.png"]];
        [passwordAlertView addSubview:customAlert];
        passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 15.0, 245.0, 25.0)];
        passwordTextField.delegate=self;
        [passwordTextField setBackgroundColor:[UIColor whiteColor]];
        [passwordTextField setKeyboardType:UIKeyboardTypeDefault];
        passwordTextField.placeholder=@"Enter a password";
        passwordTextField.secureTextEntry=YES;
        [passwordTextField setBorderStyle:UITextBorderStyleRoundedRect];
        [passwordAlertView addSubview:passwordTextField];
        
        
        reenterPasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 45.0, 245.0, 25.0)];
        reenterPasswordTextField.delegate=self;
        [reenterPasswordTextField setBackgroundColor:[UIColor whiteColor]];
        [reenterPasswordTextField setKeyboardType:UIKeyboardTypeDefault];
        reenterPasswordTextField.placeholder=@"Re-enter the password";
        reenterPasswordTextField.secureTextEntry=YES;
        [reenterPasswordTextField setBorderStyle:UITextBorderStyleRoundedRect];
        [passwordAlertView addSubview:reenterPasswordTextField];
        
        passwordAlertView.tag=99;
        
        [passwordAlertView show];
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
        [_shareSecurelyButton setEnabled:NO];
        if ([MFMailComposeViewController canSendMail])
        {
            MFMailComposeViewController *mailer = [MFMailComposeViewController new];
            mailer.mailComposeDelegate = self;
            [[mailer navigationBar] setTintColor:[UIColor colorWithRed:0.10980392156863f green:0.37254901960784f blue:0.6078431372549f alpha:1]];
            NSURLResponse* urlResponseList;
            NSError* requestErrorList;
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:[NSURL URLWithString:@"https://api.point.io/api/v2/links/create.json"]];
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

            /*
            if(_forwardingSwitch){
                requestParams = [requestParams stringByAppendingFormat:@"&restrictByIP=SMALL"];
            } else {
                requestParams = [requestParams stringByAppendingFormat:@"&restrictByIP=NONE"];
            }
            */
            
            if(_expireSwitch){
                requestParams = [requestParams stringByAppendingFormat:@"&expirationDate=%@",_appDel.shareExpirationDate];
            }
            
            /*
            if(_passwordSwitch){
                requestParams = [requestParams stringByAppendingFormat:@"&password=%@",_password];
            }
            */
            
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(textField == reenterPasswordTextField || textField == passwordTextField){
        if(![[passwordTextField text] isEqualToString:[reenterPasswordTextField text]] && !([[passwordTextField text] length] == 0 && [[reenterPasswordTextField text] length] == 0)){
        } else {
            _passwordsDontMatchLabel.alpha = 0;
        }
    }
    return YES;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 99){
        if(buttonIndex == 0){
            // [_passwordSwitch setOn:NO animated:YES];
            _passwordsDontMatchLabel.alpha = 0;
            [_passwordsDontMatchLabel setHidden:YES];
        }
        if(buttonIndex == 1 && ([[passwordTextField text] length] == 0 || [[reenterPasswordTextField text] length] == 0)){
            // [_passwordSwitch setOn:NO animated:YES];
            _passwordsDontMatchLabel.alpha = 0;
        } else {
            if([[passwordTextField text] isEqualToString:[reenterPasswordTextField text]] && (![[passwordTextField text] length] == 0 || ![[reenterPasswordTextField text] length] == 0)){
                _password = [passwordTextField text];
                _passwordsDontMatchLabel.alpha = 0;
            } else {
                // [_passwordSwitch setOn:NO animated:YES];
                _passwordsDontMatchLabel.alpha = 1;
                [UIView animateWithDuration:4.0 animations:^(void){
                    _passwordsDontMatchLabel.alpha = 0;
                }];
            }
        }
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
    [_shareSecurelyButton setEnabled:YES];
}

- (void)viewDidUnload {
    [self setPasswordsDontMatchLabel:nil];
    [super viewDidUnload];
}


@end
