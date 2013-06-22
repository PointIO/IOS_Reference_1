//
//  FileViewerControllerIpad.m
//  point.io
//
//  Created by Constantin Lungu on 5/29/13.
//  Copyright (c) 2013 FusionWorks. All rights reserved.
//

#import "FileViewerControllerIpad.h"
#import "Common.h"


@implementation FileViewerControllerIpad

@synthesize shareID,folderName,sessionKey,fileName,i,list = _list,filesTableView=_filesTableView,docWebView=_docWebView,nestedFoldersCounter;

NSString* chosenFolderTitle;
NSString* rootFolderTitle;
NSMutableArray* tempContainer;

UIImageView* imgView;
UIImageView* imgView2;
UIImageView* imgView3;
UIImageView* imgView4;
UILabel* fileNameLabel;

NSArray* tempArray;

UILabel* sharedFolderLabel;

UITextField* passwordTextField, *reenterPasswordTextField;
UIAlertView* passwordAlertView;

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    if(UIInterfaceOrientationIsLandscape(fromInterfaceOrientation)){
        if(!UIInterfaceOrientationIsLandscape(self.interfaceOrientation)){
        [UIView animateWithDuration:0.20f animations:^(void) {
        [_fullScreenButton setTitle:@"Split view"];
        _filesTableView.frame = CGRectMake(_filesTableView.frame.origin.x, _filesTableView.frame.origin.y, 0, 0);
        _docWebView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        }];
        _borderImage.alpha = 0;
        }
    } else {
        [UIView animateWithDuration:0.20f animations:^(void) {
        [_fullScreenButton setTitle:@"Full screen"];
        _filesTableView.frame = CGRectMake(_filesTableView.frame.origin.x, _filesTableView.frame.origin.y, 320, 660);
        _docWebView.frame = CGRectMake(_filesTableView.frame.size.width+_borderImage.frame.size.width-2, 0, 702, 754);
        }];
        _borderImage.alpha = 1;
        _datePicker.alpha = 1;
    }
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if(UIInterfaceOrientationIsPortrait(toInterfaceOrientation)){
        _datePicker.alpha = 0;
    }
}

- (void) viewDidLoad{
    [super viewDidLoad];
    _appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    _passwordsDontMatchLabel.alpha = 0;
    [_shareButton addTarget:self action:@selector(shareButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(sharingViewSwiped)];
    swipeGesture.direction = (UISwipeGestureRecognizerDirectionUp|UISwipeGestureRecognizerDirectionDown);
    [_sharingView addGestureRecognizer:swipeGesture];
    [_expireSwitch addTarget:self action:@selector(expireSwitchValueChanged) forControlEvents:UIControlEventValueChanged];
    [_passwordSwitch addTarget:self action:@selector(passwordSwitchValueChanged) forControlEvents:UIControlEventValueChanged];
    _shareBarButton.enabled = NO;
    _docWebView.delegate = self;
    _docWebView.scalesPageToFit = YES;
    _filesTableView.delegate = self;
    _filesTableView.dataSource = self;
    _filesTableView.frame = CGRectMake(0, 0, _filesTableView.frame.size.width, _filesTableView.frame.size.height);
    _sharingView.frame = CGRectMake(_filesTableView.frame.size.width+_borderImage.frame.size.width, 0, _sharingView.frame.size.width, _sharingView.frame.size.height);
    _sharingView.alpha = 0;
    _datePicker.frame = CGRectMake(0, _sharingView.frame.size.height, _datePicker.frame.size.width, _datePicker.frame.size.height);
    i = 0;
    nestedFoldersCounter = 0;
    self.navigationItem.backBarButtonItem.enabled = YES;
    self.navigationItem.backBarButtonItem.title = @"Back";
    self.navigationItem.title = folderName;
    _remotePath = @"/";
    rootFolderTitle = self.navigationItem.title;
    if(![Common isConnectedToInternet]){
        UIAlertView* err = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Looks like there is no internet connection, please check the settings" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        UIImageView* temp = [[UIImageView alloc] initWithFrame:CGRectMake(2, 0, 280, 174)];
        temp.image = [UIImage imageNamed:@"noInternetConnection.png"];
        [err addSubview:temp];
        [err setBackgroundColor:[UIColor clearColor]];
        [err show];
    } else {
        [MBProgressHUD showHUDAddedTo:self.filesTableView animated:YES];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [self getFileNamesAndFileIDs];
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.filesTableView animated:YES];
                [_filesTableView reloadData];
                [TestFlight passCheckpoint:@"User loaded his workspace successfully"];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            });
        });
    }
    
}

/*---------------------------TABLE VIEW------------------------------*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_fileNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
        static NSString *CellIdentifier = @"fileNameCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.textLabel.text = [_fileNames objectAtIndex:indexPath.row];
        return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    i = indexPath.row;
    NSLog(@"%@",_fileIDs);
    if([[_fileIDs objectAtIndex:i] isKindOfClass:[NSString class]] && [[_fileIDs objectAtIndex:i] rangeOfString:@"folder:"].location == NSNotFound){
        NSLog(@"IS NOT A FOLDER");
        
        shareID = [_fileShareIDs objectAtIndex:indexPath.row];
        fileName = [_fileNames objectAtIndex:indexPath.row];
        _fileID = [_fileIDs objectAtIndex:indexPath.row];
        [MBProgressHUD showHUDAddedTo:self.docWebView animated:YES];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
             [self load];
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.docWebView animated:YES];
                [TestFlight passCheckpoint:@"User loaded viewed a file"];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            });
        });
       
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
                [self.filesTableView reloadData];
                [UIView animateWithDuration:0.15 animations:^(void) {
                    [sharedFolderLabel setAlpha:0];
                }];
                [sharedFolderLabel setText:chosenFolderTitle];
                [UIView animateWithDuration:0.15 animations:^(void) {
                    [sharedFolderLabel setAlpha:1];
                }];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(showPastFolder)];
                self.navigationItem.hidesBackButton = YES;
                self.navigationItem.leftBarButtonItem = item;
            });
        });
    }
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
        self.navigationItem.hidesBackButton = NO;
        self.navigationItem.leftBarButtonItem = nil;
    }
    [MBProgressHUD showHUDAddedTo:self.filesTableView animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self getFileNamesAndFileIDs];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.filesTableView animated:YES];
            [self.filesTableView reloadData];
            if([tempContainer count] != 0){
                self.navigationItem.title = [tempContainer lastObject];
                [sharedFolderLabel setText:[tempContainer lastObject]];
            } else {
                self.navigationItem.title = rootFolderTitle;
                [UIView animateWithDuration:0.15 animations:^(void) {
                    [sharedFolderLabel setAlpha:0];
                }];
                [sharedFolderLabel setText:rootFolderTitle];
                [UIView animateWithDuration:0.15 animations:^(void) {
                    [sharedFolderLabel setAlpha:1];
                }];
            }
            [_containerIDHistory removeLastObject];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    });
    
}

- (void) viewWillAppear:(BOOL)animated{
    if(!imgView){
        sharedFolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(435, 16, 150, 50)];
        sharedFolderLabel.backgroundColor = [UIColor clearColor];
        sharedFolderLabel.text = folderName;
        sharedFolderLabel.textColor = [UIColor whiteColor];
        [sharedFolderLabel setTextAlignment:UITextAlignmentCenter];
        sharedFolderLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:18.0];
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 320, 44)];
        imgView.image = [UIImage imageNamed:@"blueBarImageClean.png"];
//        [self.navigationController.view addSubview:imgView];
        imgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(5, 27, 50, 29)];
        imgView2.image = [UIImage imageNamed:@"backButton.png"];
        [self.navigationController.view addSubview:imgView2];
//        [self.navigationController.view addSubview:sharedFolderLabel];
        if([_lastFolderTitle length]!=0){
            self.navigationItem.title = _lastFolderTitle;
            [sharedFolderLabel setText:_lastFolderTitle];
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

- (void) getFileNamesAndFileIDs{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURLResponse* urlResponseList;
    NSError* requestErrorList;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString* URLString = [NSString stringWithFormat:@"https://api.point.io/api/v2/folders/list.json"];
    
    NSMutableArray* objects;
    NSMutableArray* keys;
    if(_containerID){
        objects = [NSArray arrayWithObjects:shareID,_remotePath,_containerID,nil];
        keys = [NSArray arrayWithObjects:@"folderid",@"path",@"containerid",nil];
    } else {
        objects = [NSArray arrayWithObjects:shareID,_remotePath,nil];
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
    [request addValue:sessionKey forHTTPHeaderField:@"Authorization"];
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
        _fileNames = [NSMutableArray array];
        _filePaths = [NSMutableArray array];
        _fileIDs = [NSMutableArray array];
        _fileShareIDs = [NSMutableArray array];
        _containerIDs = [NSMutableArray array];
        NSDictionary* result = [listFilesResponse valueForKey:@"RESULT"];
        NSArray* columns = [result valueForKey:@"COLUMNS"];
        NSArray* data = [result valueForKey:@"DATA"];
        for(int j=0; j<[data count];j++){
            NSArray* data2 = [data objectAtIndex:j];
            NSDictionary* temp = [NSDictionary dictionaryWithObjects:data2 forKeys:columns];
            [_fileNames addObject:[temp valueForKey:@"NAME"]];
            [_fileIDs addObject:[temp valueForKey:@"FILEID"]];
            [_fileShareIDs addObject:[temp valueForKey:@"SHAREID"]];
            [_containerIDs addObject:[temp valueForKey:@"CONTAINERID"]];
            [_filePaths addObject:[temp valueForKey:@"PATH"]];
        }
    }
}

- (IBAction)fullScreenButtonPressed:(id)sender {
    if([[sender title] isEqualToString:@"Split view"]){
        if (self.interfaceOrientation != UIInterfaceOrientationLandscapeLeft && self.interfaceOrientation != UIInterfaceOrientationLandscapeRight) {
            [[UIDevice currentDevice] performSelector:NSSelectorFromString(@"setOrientation:") withObject:(__bridge id)((void*)UIInterfaceOrientationLandscapeLeft)];
        }
        _datePicker.alpha = 1;
        [sender setTitle:@"Full screen"];
    }
    else if ([[sender title] isEqualToString:@"Full screen"]){
    if (self.interfaceOrientation != UIInterfaceOrientationPortrait) {
        [[UIDevice currentDevice] performSelector:NSSelectorFromString(@"setOrientation:") withObject:(__bridge id)((void*)UIInterfaceOrientationPortrait)];
    }
        [sender setTitle:@"Split view"];
        _datePicker.alpha = 0;
    }
}

- (IBAction)printPressed:(id)sender {
    
}



- (void) load{
    NSURLResponse* urlResponseList;
    NSError* requestErrorList;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString* URLString = [NSString stringWithFormat:@"https://api.point.io/api/v2/folders/files/download.json"];
    [request setURL:[NSURL URLWithString:URLString]];
    [request addValue:sessionKey forHTTPHeaderField:@"Authorization"];
    NSArray* objects,* keys;
    NSLog(@"EXTENSION IS %@",[fileName pathExtension]);
    if (([[fileName pathExtension] isEqualToString:@"doc"]) || ([[fileName pathExtension] isEqualToString:@"xls"]) || ([[fileName pathExtension] isEqualToString:@"ppt"])) {
        objects = [NSArray arrayWithObjects:shareID,_containerID,_remotePath,fileName,_fileID,@"true",nil];
        keys = [NSArray arrayWithObjects:@"folderid",@"containerid",@"remotepath",@"filename",@"fileid",@"convertToPdf",nil];
        NSLog(@"WILL CONVERT TO PDF");
    } else {
        objects = [NSArray arrayWithObjects:shareID,_containerID,_remotePath,fileName,_fileID,@"false",nil];
        keys = [NSArray arrayWithObjects:@"folderid",@"containerid",@"remotepath",@"filename",@"fileid",@"convertToPdf",nil];
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
    [request setHTTPMethod:@"GET"];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSData* response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponseList error:&requestErrorList];
    if (response) {
        NSArray* temp = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"TEMP = %@",temp);
        NSString* extension = [fileName pathExtension];
        NSLog(@"FILE NAME = %@",fileName);
        extension = [extension lowercaseString];
        NSString* downloadString = [temp valueForKey:@"RESULT"];
        _fileDownloadURL = [NSURL URLWithString:downloadString];
        NSURLRequest* fileRequest = [NSURLRequest requestWithURL:_fileDownloadURL];
        [_docWebView loadRequest:fileRequest];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        tempArray = [temp copy];
    } else {
        NSLog(@"Something is wrong...");
        [UIView animateWithDuration:2.0 animations:^(void) {
            [_errorOccuredLabel setAlpha:1];
        }];
        [imgView4 setAlpha:0.5];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
    }
}

- (void) webViewDidStartLoad:(UIWebView *)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    _shareBarButton.enabled = YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [TestFlight passCheckpoint:@"User viewed a document"];
    
}




/*----------------------SHARING FILES--------------------------*/

- (IBAction)sharePressed:(id)sender {
    if(_sharingView.alpha == 1){
        [UIView animateWithDuration:0.25 animations:^(void) {
            _filesTableView.frame = CGRectMake(0, 0, _filesTableView.frame.size.width, _filesTableView.frame.size.height);
            _filesTableView.alpha = 1;
            _sharingView.frame = CGRectMake(_filesTableView.frame.size.width+_borderImage.frame.size.width, 0, _sharingView.frame.size.width, _sharingView.frame.size.height);
            _sharingView.alpha = 0;
            //            [sender setStyle:UIBarButtonItemStyleBordered];
        }];
    } else {
        [UIView animateWithDuration:0.25 animations:^(void) {
            _filesTableView.frame = CGRectMake(-_filesTableView.frame.size.width, 0, _filesTableView.frame.size.width, _filesTableView.frame.size.height);
            _filesTableView.alpha = 0;
            _sharingView.frame = CGRectMake(0, 0, _sharingView.frame.size.width, _sharingView.frame.size.height);
            _sharingView.alpha = 1;
            //        [sender setStyle:UIBarButtonItemStyleDone];
        }];
    }
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
    [customAlert setImage:[UIImage imageNamed:@"passwordsAlertViewiPad.png"]];
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
        else if(buttonIndex == 1 && ([[passwordTextField text] length] == 0 || [[reenterPasswordTextField text] length] == 0)){
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

- (void) expireSwitchValueChanged{
    if(_expireSwitch.isOn){
        NSDate *now = [NSDate date];
        int daysToAdd = 1;
        NSDate *tomorrow = [now dateByAddingTimeInterval:60*60*24*daysToAdd];
        [_datePicker setMinimumDate:tomorrow];
        [UIView animateWithDuration:0.40f animations:^(void) {
            _sharingView.frame = CGRectMake(0, -_datePicker.frame.size.height, _sharingView.frame.size.width, _sharingView.frame.size.height);
            _datePicker.frame = CGRectMake(0, _datePicker.frame.origin.y-_datePicker.frame.size.height, _datePicker.frame.size.width, _datePicker.frame.size.height);
            [_datePicker setEnabled:YES];
        }];
        [_datePicker becomeFirstResponder];
    } else {
        [_datePicker resignFirstResponder];
        [UIView animateWithDuration:0.40f animations:^(void) {
            _sharingView.frame = CGRectMake(0, 0, _sharingView.frame.size.width, _sharingView.frame.size.height);
            _datePicker.frame = CGRectMake(0, _sharingView.frame.size.height, _datePicker.frame.size.width, _datePicker.frame.size.height);
        }];
    }
}

- (void) sharingViewSwiped{
    NSDate* date = [_datePicker date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    NSString *dateString = [formatter stringFromDate:date];
    [_appDel setShareExpirationDate:dateString];
    [UIView animateWithDuration:0.40f animations:^(void) {
        _sharingView.frame = CGRectMake(0, 0, _sharingView.frame.size.width, _sharingView.frame.size.height);
        _datePicker.frame = CGRectMake(0, _sharingView.frame.size.height, _datePicker.frame.size.width, _datePicker.frame.size.height);
    }];
}

- (IBAction)shareButtonPressed:(id)sender{
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
            [request addValue:sessionKey forHTTPHeaderField:@"Authorization"];
            NSString* requestParams = [NSString stringWithFormat:@"shareId=%@&fileid=%@&filename=%@&remotepath=%@&containerid=%@",shareID,_fileID,fileName,_remotePath,_containerID];
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
                    NSString *emailBody = [NSString stringWithFormat:@"Hello,\n I wanted to share %@ with you.\n Secure download link: %@",fileName,downloadLink];
                    [mailer setMessageBody:emailBody isHTML:NO];
                    [mailer setSubject:fileName];
                    [self presentViewController:mailer animated:YES completion:^(void){
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

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    if(result == MFMailComposeResultSent){
        [self sharePressed:nil];
    }
    [controller dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}



@end
