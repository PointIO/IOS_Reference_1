#import "docViewerViewController.h"
#import "Common.h"
#import "DocumentShareSettingsViewController.h"


@interface docViewerViewController ()

@end

@implementation docViewerViewController

@synthesize docWebView = _docWebView;
@synthesize shareID = _shareID;
@synthesize fileName = _fileName;
@synthesize fileID = _fileID;
@synthesize containerID = _containerID;
@synthesize remotePath = _remotePath;
@synthesize fileDownloadURL = _fileDownloadURL;
@synthesize downloadData = _downloadData;
@synthesize shareFileButton = _shareFileButton;
@synthesize errorOccuredLabel = _errorOccuredLabel;

UIImageView* imgView;
UIImageView* imgView2;
UIImageView* imgView3;
UIImageView* imgView4;
UILabel* fileNameLabel;

UIAlertView* maxDownloadsReachedError;

NSArray* tempArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL) splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_errorOccuredLabel setAlpha:0];
    [_shareFileButton setEnabled:NO];
	self.navigationItem.title = _fileName;
    _docWebView.delegate = self;
    _docWebView.scalesPageToFit = YES;
    
    
    if(![Common isConnectedToInternet]){
        UIAlertView* err = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Looks like there is no internet connection, please check the settings" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        UIImageView* temp = [[UIImageView alloc] initWithFrame:CGRectMake(2, 0, 280, 174)];
        temp.image = [UIImage imageNamed:@"noInternetConnection.png"];
        [err addSubview:temp];
        [err setBackgroundColor:[UIColor clearColor]];
        [err show];
    } else {
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [self load];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_shareFileButton setEnabled:YES];
                if(!tempArray){
                    [UIView animateWithDuration:2.0 animations:^(void) {
                        [_errorOccuredLabel setAlpha:1];
                    }];
                    [_shareFileButton setEnabled:NO];
                    imgView4.alpha = 0.5;
                }
                if(tempArray && [[tempArray valueForKey:@"ERROR"]integerValue] == 1){
                    NSString* message = [tempArray valueForKey:@"MESSAGE"];
                    if([message isEqualToString:@"ERROR - Could not download file: You have exceeded the max number of monthly Downloads allowed for a member of your group"]){
                        
                        NSLog(@"SHOULD SHOW ALERT");
                        UIAlertView* maxDownloadsReachedError = [[UIAlertView alloc]
                                                                 initWithTitle:@"Error"
                                                                 message:@"You have exceeded the maximum number of monthly downloads allowed for a member of your group"
                                                                 delegate:nil 
                                                                 cancelButtonTitle:@"Dismiss"
                                                                 otherButtonTitles:nil];
                        
                        UIImageView* errorImgView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 0, 280, 174)];
                        errorImgView.image = [UIImage imageNamed:@"maxDownloadsError.png"];
                        [maxDownloadsReachedError addSubview:errorImgView];
                        [maxDownloadsReachedError setTag:99];
                        maxDownloadsReachedError.delegate = self;
                        [maxDownloadsReachedError show];
                        [_shareFileButton setEnabled:NO];
                        imgView4.alpha = 0.5;
                    }
                } else {
                    imgView4.alpha = 1;
                }
                // [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        });
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 99){
        [[self navigationController] popViewControllerAnimated:YES];
    }
}

- (void) viewWillDisappear:(BOOL)animated{
}

- (void) viewWillAppear:(BOOL)animated{
    if(!imgView){
        fileNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 16, 150, 50)];
        fileNameLabel.backgroundColor = [UIColor clearColor];
        fileNameLabel.text = _fileName;
        fileNameLabel.textColor = [UIColor whiteColor];
        [fileNameLabel setTextAlignment:UITextAlignmentCenter];
        fileNameLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:18.0];
        
        [self.navigationController.toolbar addSubview:imgView4];
    }
    
    imgView.alpha = 0;
    imgView2.alpha = 0;
    imgView3.alpha = 0;
    imgView4.alpha = 0;
    fileNameLabel.alpha = 0;
    _shareFileButton.width = 0.01;

}



- (void) webViewDidStartLoad:(UIWebView *)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [TestFlight passCheckpoint:@"User viewed a document"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)shareFilePressed:(id)sender {
    [self performSegueWithIdentifier:@"goToShare" sender:nil];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"goToDocumentShareSettings"]){
        DocumentShareSettingsViewController *svc = [segue destinationViewController];
        [svc setFileDownloadURL:_fileDownloadURL];
        [svc setFileName:_fileName];
        [svc setDownloadData:_downloadData];
        [svc setFileID:_fileID];
        [svc setShareID:_shareID];
        [svc setRemotePath:_remotePath];
        [svc setContainerID:_containerID];
        [svc setSessionKey:_sessionKey];
    }
}

- (void) load{
    NSURLResponse* urlResponseList;
    NSError* requestErrorList;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString* URLString = [NSString stringWithFormat:@"https://api.point.io/v2/folders/files/download.json"];
    [request setURL:[NSURL URLWithString:URLString]];
    [request addValue:_sessionKey forHTTPHeaderField:@"Authorization"];
    NSArray* objects,* keys;
    NSLog(@"EXTENSION IS %@",[_fileName pathExtension]);
    /*
    if (([[_fileName pathExtension] isEqualToString:@"doc"]) ||
        ([[_fileName pathExtension] isEqualToString:@"xls"]) ||
        ([[_fileName pathExtension] isEqualToString:@"ppt"])) {
        
        objects = [NSArray arrayWithObjects:
                   _shareID,
                   _containerID,
                   _remotePath,
                   _fileName,
                   _fileID,
                   @"true",
                   nil];
        
        keys = [NSArray arrayWithObjects:
                @"folderid",
                @"containerid",
                @"remotepath",
                @"filename",
                @"fileid",
                @"convertToPdf",
                nil];
        NSLog(@"WILL CONVERT TO PDF");
        
    }
    else {
        objects = [NSArray arrayWithObjects:
                   _shareID,
                   _containerID,
                   _remotePath,
                   _fileName,
                   _fileID,
                   @"false",
                   nil];
        
        keys = [NSArray arrayWithObjects:
                @"folderid",
                @"containerid",
                @"remotepath",
                @"filename",
                @"fileid",
                @"convertToPdf",
                nil];
    }
    */
    
    objects = [NSArray arrayWithObjects:
               _shareID,
               _containerID,
               _remotePath,
               _fileName,
               _fileID,
               @"false",
               nil];
    
    keys = [NSArray arrayWithObjects:
            @"folderid",
            @"containerid",
            @"remotepath",
            @"filename",
            @"fileid",
            @"convertToPdf",
            nil];

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
    [request setHTTPMethod:@"GET"];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSData* response = [NSURLConnection
                        sendSynchronousRequest:request
                        returningResponse:&urlResponseList
                        error:&requestErrorList];
    if (response) {
        NSArray* temp = [NSJSONSerialization JSONObjectWithData:response
                                                        options:NSJSONReadingMutableContainers
                                                          error:nil];
        NSLog(@"TEMP = %@",temp);
        NSString* extension = [_fileName pathExtension];
        NSLog(@"FILE NAME = %@",_fileName);
        NSLog(@" ");
        extension = [extension lowercaseString];
        NSString* downloadString = [temp valueForKey:@"RESULT"];
        _fileDownloadURL = [NSURL URLWithString:downloadString];
        NSURLRequest* fileRequest = [NSURLRequest requestWithURL:_fileDownloadURL];
        
        
        if ([[UIApplication sharedApplication]canOpenURL:_fileDownloadURL]) {
            // [[UIApplication sharedApplication]openURL:url];
            [_docWebView loadRequest:fileRequest];
        }
        
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        tempArray = [temp copy];
    }
    else {
        NSLog(@"Something is wrong...");
        [UIView animateWithDuration:2.0 animations:^(void) {
            [_errorOccuredLabel setAlpha:1];
        }];
        [imgView4 setAlpha:0.5];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}


/*
- (BOOL)webView:(UIWebView *)wv shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    // Determine if we want the system to handle it.
    NSURL *url = request.URL;
    if (![url.scheme isEqual:@"http"] && ![url.scheme isEqual:@"https"]) {
        if ([[UIApplication sharedApplication]canOpenURL:url]) {
            [[UIApplication sharedApplication]openURL:url];
            return NO;
        }
    }
    return YES;
}
*/

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
    /*
    UIWebView *myWebView = [[UIWebView alloc] initWithFrame:CGRectMake(10, 10, 320, 480)];
     
    NSURL *targetURL = [NSURL URLWithString:@"http://developer.apple.com/iphone/library/documentation/UIKit/Reference/UIWebView_Class/UIWebView_Class.pdf"];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    [webView loadRequest:request];
    [self.view addSubview:webView];
    */
    
    /*
    NSURL *targetURL = [NSURL URLWithString:@"http://cdn.point.io/shares/59DCF683_AD18_48FE_B1E60FFB084DB718/Accounts_Payable/Contracts/DavisAndGilbert.pdf?response-content-type=application/force-download&AWSAccessKeyId=AKIAJF3B7DECFIG6EQJQ&Signature=e%2B3d9%2BKQ%2F4KMjkSwHc4x%2FCD%2FLfU%3D&Expires=1383934333"];
    */
   
    /*
    // Give iOS a chance to open it.
    NSURL *url = [NSURL URLWithString:[error.userInfo objectForKey:@"NSErrorFailingURLStringKey"]];
    if ([error.domain isEqual:@"WebKitErrorDomain"]
        && error.code == 102
        && [[UIApplication sharedApplication]canOpenURL:url]) {
            [[UIApplication sharedApplication]openURL:url];
            return;
    }
    */
 
    NSLog(@"Error : %@", error);
    UIAlertView* err = [[UIAlertView alloc] initWithTitle:@"Error"
                                                  message:[error localizedDescription]
                                                 delegate:nil
                                        cancelButtonTitle:@"Dismiss"
                                        otherButtonTitles:nil];
    [err show];
    
    NSLog(@"Error : %@",error);
    return;
}




- (void)viewDidUnload {
    [self setErrorOccuredLabel:nil];
    [super viewDidUnload];
}



@end
