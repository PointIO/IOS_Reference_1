#import "sharingViewController.h"

@interface sharingViewController ()

@end

@implementation sharingViewController

@synthesize docName = _docName;
@synthesize downloadData = _downloadData;
@synthesize fileDownloadURL = _fileDownloadURL;
@synthesize fileName = _fileName;
@synthesize sessionKey = _sessionKey;
@synthesize shareID = _shareID;
@synthesize fileID = _fileID;
@synthesize remotePath = _remotePath;
@synthesize containerID = _containerID;
@synthesize expirationDate = _expirationDate;
@synthesize password = _password;

@synthesize appDel = _appDel;

@synthesize printSwitch = _printSwitch;
@synthesize downloadSwitch = _downloadSwitch;
@synthesize expireSwitch = _expireSwitch;
@synthesize forwardingSwitch = _forwardingSwitch;
@synthesize screenCaptureSwitch = _screenCaptureSwitch;
@synthesize passwordSwitch = _passwordSwitch;
@synthesize passwordsDontMatchLabel = _passwordsDontMatchLabel;
@synthesize shareSecurelyButton = _shareSecurelyButton;


UIImageView* imgView;
UIImageView* imgView2;
UIImageView* imgView3;
UIImageView* imgView4;
UIImageView* imgView5;
UILabel* fileNameLabel;

UITextField* passwordTextField, *reenterPasswordTextField;
UIAlertView* passwordAlertView;

BOOL shareSecurelyPressed, shouldCheck;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    shouldCheck = YES;
    shareSecurelyPressed = NO;
    _passwordsDontMatchLabel.alpha = 0;
    _passwordsDontMatchLabel.frame = CGRectMake(_passwordsDontMatchLabel.frame.origin.x, _passwordSwitch.frame.origin.y + 20, _passwordsDontMatchLabel.frame.size.width, _passwordsDontMatchLabel.frame.size.height);
    [_expireSwitch addTarget:self action:@selector(expireSwitchValueChanged) forControlEvents:UIControlEventValueChanged];
    [_passwordSwitch addTarget:self action:@selector(passwordSwitchValueChanged) forControlEvents:UIControlEventValueChanged];
    
    _appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    _shareSecurelyButton.width = 0.01;
    NSMutableArray* toolbarItems = [self.toolbarItems mutableCopy];
    [toolbarItems addObject:_shareSecurelyButton];
    [toolbarItems addObject:_shareSecurelyButton];
    [toolbarItems addObject:_shareSecurelyButton];
    [self setToolbarItems:toolbarItems];
    
    
    
}

- (void) viewWillDisappear:(BOOL)animated{
    [UIView animateWithDuration:0.25 animations:^(void) {
        imgView.alpha = 0;
        imgView2.alpha = 0;
        imgView4.alpha = 0;
        fileNameLabel.alpha = 0;
        imgView5.alpha = 0;
    }];
    imgView = nil;
    imgView2 = nil;
    imgView4 = nil;
    imgView5 = nil;
    fileNameLabel = nil;
}

- (void) viewWillAppear:(BOOL)animated{
    if(!imgView){
        fileNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 16, 150, 50)];
        fileNameLabel.backgroundColor = [UIColor clearColor];
        fileNameLabel.text = @"Share securely";
        fileNameLabel.textColor = [UIColor whiteColor];
        [fileNameLabel setTextAlignment:UITextAlignmentCenter];
        fileNameLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:18.0];
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 320, 44)];
        imgView.image = [UIImage imageNamed:@"blueBarImageClean.png"];
        [self.navigationController.view addSubview:imgView];
        imgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(5, 27, 50, 29)];
        imgView2.image = [UIImage imageNamed:@"backButton.png"];
        [self.navigationController.view addSubview:imgView2];
        imgView4 = [[UIImageView alloc] initWithFrame:CGRectMake(5, 7, 106, 30)];
        imgView4.image = [UIImage imageNamed:@"shareSecurelyButton.png"];
        [self.navigationController.toolbar addSubview:imgView4];
        [self.navigationController.view addSubview:fileNameLabel];
    }
    imgView.alpha = 0;
    imgView2.alpha = 0;
    imgView4.alpha = 0;
    fileNameLabel.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^(void) {
        imgView.alpha = 1;
        imgView2.alpha = 1;
        imgView4.alpha = 1;
        fileNameLabel.alpha = 1;
    }];
}

- (void) expireSwitchValueChanged{
    if(_expireSwitch.isOn){
    [self performSegueWithIdentifier:@"getTheDate" sender:self];
    }
}

- (void) viewDidAppear:(BOOL)animated{
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void) passwordSwitchValueChanged{
    if(_passwordSwitch.isOn){
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)shareSecurelyPressed:(id)sender {

    if(![self isConnectedToInternet]){
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
//                [mailer setSubject:@""];
                //            NSURLRequest* req = [NSURLRequest requestWithURL:_fileDownloadURL];
                //        NSString* extension = [_fileName pathExtension];
                //        if([extension isEqualToString:@"jpg"] || [extension isEqualToString:@"png"] || [extension isEqualToString:@"jpeg"] || [extension isEqualToString:@"gif"] || [extension isEqualToString:@"bmp"] || [extension isEqualToString:@"tiff"]){
                //        [mailer addAttachmentData:_downloadData mimeType:@"image/png" fileName:_fileName];
                //        } else if([extension isEqualToString:@"pdf"] || [extension isEqualToString:@"doc"] || [extension isEqualToString:@"xls"] || [extension isEqualToString:@"ppt"]){
                //            [mailer addAttachmentData:_downloadData mimeType:@"application/pdf" fileName:_fileName];
                //        }
                
//                if(!imgView5){
//                imgView5 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 320, 44)];
//                imgView5.image = [UIImage imageNamed:@"newMessageBarImage.png"];
//                [[UINavigationBar appearance] setBackgroundImage:imgView5.image forBarMetrics:UIBarMetricsDefault];
//                }
                [[mailer navigationBar] setTintColor:[UIColor colorWithRed:0.10980392156863f green:0.37254901960784f blue:0.6078431372549f alpha:1]];
                NSURLResponse* urlResponseList;
                NSError* requestErrorList;
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                [request setURL:[NSURL URLWithString:@"https://api.point.io/api/v2/links/create.json"]];
                [request setHTTPMethod:@"POST"];
                [request addValue:_sessionKey forHTTPHeaderField:@"Authorization"];
                NSString* requestParams = [NSString stringWithFormat:@"shareId=%@&fileid=%@&filename=%@&remotepath=%@&containerid=%@",_shareID,_fileID,_fileName,_remotePath,_containerID];
                if(_printSwitch.isOn){
                    requestParams = [requestParams stringByAppendingFormat:@"&allowPrint=1"];
                } else {
                    requestParams = [requestParams stringByAppendingFormat:@"&allowPrint=0"];
                }
                if(_downloadSwitch.isOn){
                    requestParams = [requestParams stringByAppendingFormat:@"&allowDownload=1"];
                } else {
                    requestParams = [requestParams stringByAppendingFormat:@"&allowDownload=0"];
                }
                if(_expireSwitch.isOn){
                    requestParams = [requestParams stringByAppendingFormat:@"&expirationDate=%@",_appDel.shareExpirationDate];
                }
                if(_passwordSwitch.isOn){
                    requestParams = [requestParams stringByAppendingFormat:@"&password=%@",_password];
                }
                NSLog(@"REQUEST PARAMS = %@",requestParams);
                NSData* payload = [requestParams dataUsingEncoding:NSUTF8StringEncoding];
                [request setHTTPBody:payload];
                NSData* response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponseList error:&requestErrorList];
                if(!response){
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Request response is nil" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                    [alert show];
                } else {
                NSArray* temp = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
                if([[temp valueForKey:@"ERROR"] integerValue] == 0) {
                    NSString* downloadLink = [temp valueForKey:@"LINKURL"];
                    NSString *emailBody = [NSString stringWithFormat:@"Hello,\n I wanted to share %@ with you.\n Secure download link: %@",_fileName,downloadLink];
                    [mailer setMessageBody:emailBody isHTML:NO];
                    [mailer setSubject:_fileName];
                    [self presentViewController:mailer animated:YES completion:^(void){
                        shareSecurelyPressed = YES;
                    }];
                    }
                }
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Your device doesn't support the composer sheet"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Dismiss"
                                                      otherButtonTitles: nil];
                [alert show];
            }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
    
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(textField == reenterPasswordTextField || textField == passwordTextField){
        if(![[passwordTextField text] isEqualToString:[reenterPasswordTextField text]] && !([[passwordTextField text] length] == 0 && [[reenterPasswordTextField text] length] == 0)){
        } else {
            _passwordsDontMatchLabel.alpha = 0;
        }
    }
    return YES;
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 99){
        if(buttonIndex == 0){
            [_passwordSwitch setOn:NO animated:YES];
            _passwordsDontMatchLabel.alpha = 0;
            [_passwordsDontMatchLabel setHidden:YES];
        }
        if(buttonIndex == 1 && ([[passwordTextField text] length] == 0 || [[reenterPasswordTextField text] length] == 0)){
            [_passwordSwitch setOn:NO animated:YES];
            _passwordsDontMatchLabel.alpha = 0;
        } else {
            if([[passwordTextField text] isEqualToString:[reenterPasswordTextField text]] && (![[passwordTextField text] length] == 0 || ![[reenterPasswordTextField text] length] == 0)){
                _password = [passwordTextField text];
                _passwordsDontMatchLabel.alpha = 0;
            } else {
                [_passwordSwitch setOn:NO animated:YES];
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

- (BOOL) isConnectedToInternet{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}


@end
