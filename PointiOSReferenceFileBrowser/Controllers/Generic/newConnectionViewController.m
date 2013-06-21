#import "newConnectionViewController.h"
@interface newConnectionViewController ()

@end

@implementation newConnectionViewController

@synthesize nameTextField = _nameTextField;
@synthesize enabledSwitch = _enabledSwitch;
@synthesize loggingEnabled = _loggingEnabled;
@synthesize revisionControl = _revisionControl;
@synthesize maxRevisions = _maxRevisions;
@synthesize checkinCheckout = _checkinCheckout;

@synthesize userStorageInput = _userStorageInput;
@synthesize sessionKey = _sessionKey;
@synthesize siteTypeID = _siteTypeID;
@synthesize userInputString = _userInputString;
@synthesize userKeys = _userKeys;
@synthesize userValues = _userValues;
@synthesize connectionSiteTypeID = _connectionSiteTypeID;
@synthesize allPossibleConnections = _allPossibleConnections;
@synthesize requestedConnectionName = _requestedConnectionName;
@synthesize allUIInputs = _allUIInputs;

@synthesize appDel = _appDel;

UIImageView* imgView;
UIImageView* imgView2;

BOOL enteredAllData, didNotShowError;

int totalYOffset;
CGPoint svos;

NSMutableArray* keys2;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidAppear:(BOOL)animated{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setToolbarHidden:YES animated:NO];
    
    enteredAllData = TRUE;
    didNotShowError = TRUE;
    UIImageView* background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 640, 920)];
    background.image = [UIImage imageNamed:@"background.png"];
    [self.view addSubview:background];
    
    svos = _scrollView.contentOffset;
    _nameTextField.delegate = self;
    _maxRevisions.delegate = self;
    _appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    totalYOffset = 0;
    
    NSArray* storageInputParams;
    NSURLResponse* urlResponseList;
    NSError* requestErrorList;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://api.point.io/api/v2/storagetypes/list.json"]];
    [request setHTTPMethod:@"GET"];
    [request addValue:_sessionKey forHTTPHeaderField:@"Authorization"];
    NSData* response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponseList error:&requestErrorList];
    if(!response){
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Request response is nil" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
    } else {
    NSArray* availableConnectionsArray = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
    if([[availableConnectionsArray valueForKey:@"ERROR"] integerValue] == 0){
        NSArray* result = [availableConnectionsArray valueForKey:@"RESULT"];
        NSArray* columns = [result valueForKey:@"COLUMNS"];
        NSArray* data = [result valueForKey:@"DATA"];
        for(int i = 0;i<[data count];i++){
            NSDictionary* temp = [NSDictionary dictionaryWithObjects:[data objectAtIndex:i] forKeys:columns];
            if([_requestedConnectionName isEqualToString:[temp valueForKey:@"SITETYPENAME"]]){
                _connectionSiteTypeID = [temp valueForKey:@"SITETYPEID"];
                NSURLResponse* urlResponseList;
                NSError* requestErrorList;
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.point.io/api/v2/storagetypes/%@/params.json",_connectionSiteTypeID]]];
                [request setHTTPMethod:@"GET"];
                [request addValue:_sessionKey forHTTPHeaderField:@"Authorization"];
                NSData* response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponseList error:&requestErrorList];
                storageInputParams = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
                break;
            }
        }
        
        NSArray* result2 = [storageInputParams valueForKey:@"RESULT"];
        NSArray* columns2 = [result2 valueForKey:@"COLUMNS"];
        NSArray* data2 = [result2 valueForKey:@"DATA"];
        for(int i = 0;i < [data2 count];i++){
            NSDictionary* temp2 = [NSDictionary dictionaryWithObjects:[data2 objectAtIndex:i] forKeys:columns2];
            if([[temp2 valueForKey:@"ENABLED"] integerValue] == 1){
                if([[temp2 valueForKey:@"INPUTTYPE"] isEqualToString:@"TextInput"] || [[temp2 valueForKey:@"INPUTTYPE"] isEqualToString:@"BoxAuthInput"] || [[temp2 valueForKey:@"INPUTTYPE"] isEqualToString:@"DropboxAuthInput"]){
                    if(!keys2){
                        keys2 = [NSMutableArray array];
                    }
                    [keys2 addObject:[temp2 valueForKey:@"FIELDNAME"]];
                    UITextField* field = [[UITextField alloc] initWithFrame:CGRectMake(20, 40+totalYOffset, 280, 30)];
                    [field setFont:[UIFont fontWithName:@"System" size:17.0]];
                    field.borderStyle = UITextBorderStyleRoundedRect;
                    field.placeholder = [temp2 valueForKey:@"LABEL"];
                    field.autocorrectionType = UITextAutocorrectionTypeNo;
                    field.keyboardType = UIKeyboardTypeDefault;
                    field.returnKeyType = UIReturnKeyDone;
                    field.clearButtonMode = UITextFieldViewModeWhileEditing;
                    field.delegate = self;
                        if([[temp2 valueForKey:@"PASSWORDFIELD"] integerValue] == 1){
                            field.secureTextEntry = YES;
                        }
                    if(!_allUIInputs){
                        _allUIInputs = [NSMutableArray array];
                    }
                        [_allUIInputs addObject:field];
                        [_scrollView addSubview:field];
                        totalYOffset += 40;
                }
                if([[temp2 valueForKey:@"INPUTTYPE"] isEqualToString:@"CheckBox"]){
                    if(!keys2){
                        keys2 = [NSMutableArray array];
                    }
                    [keys2 addObject:[temp2 valueForKey:@"FIELDNAME"]];
                    UILabel* switchLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 40+totalYOffset, 209, 21)];
                    [switchLabel setText:[temp2 valueForKey:@"LABEL"]];
                    [switchLabel setFont:[UIFont systemFontOfSize:19.0]];
                    [switchLabel setBackgroundColor:[UIColor clearColor]];
                    [switchLabel setTextColor:[UIColor whiteColor]];
                    UISwitch* switch2 = [[UISwitch alloc] initWithFrame:CGRectMake(223, 40+totalYOffset, 79, 27)];
                    [switch2 setOn:YES];
                    [switch2 setOn:NO];
                    [switch2 setOn:YES];
                    if(!_allUIInputs){
                        _allUIInputs = [NSMutableArray array];
                    }
                    [_allUIInputs addObject:switch2];
                    [_scrollView addSubview:switch2];
                    [_scrollView addSubview:switchLabel];
                    totalYOffset += 40;
                }
            }
        }
        
        // JB 6/9/2013 IOS-6 fix  https://pointio.atlassian.net/browse/IOS-6
        // Move labels slightly; Right align all labels; Changed default behavior of switches in IB; 
        
        totalYOffset += 5;
        [_nameLabel setFrame:CGRectMake(_nameLabel.frame.origin.x, 40+totalYOffset, _nameLabel.frame.size.width ,_nameLabel.frame.size.height )];
        [_nameTextField setFrame:CGRectMake(_nameTextField.frame.origin.x, 40+totalYOffset, _nameTextField.frame.size.width, _nameTextField.frame.size.height)];
        [_enabledLabel setFrame:CGRectMake(_enabledLabel.frame.origin.x, 85+totalYOffset , _enabledLabel.frame.size.width, _enabledLabel.frame.size.height)];
        [_enabledSwitch setFrame:CGRectMake(_enabledSwitch.frame.origin.x, 80+totalYOffset, _enabledSwitch.frame.size.width, _enabledSwitch.frame.size.height)];
        [_loggingLabel setFrame:CGRectMake(_loggingLabel.frame.origin.x, 125+totalYOffset, _loggingLabel.frame.size.width, _loggingLabel.frame.size.height)];
        [_loggingEnabled setFrame:CGRectMake(_loggingEnabled.frame.origin.x, 120+totalYOffset, _loggingEnabled.frame.size.width, _loggingEnabled.frame.size.height)];
        [_revisionLabel setFrame:CGRectMake(_revisionLabel.frame.origin.x, 165+totalYOffset, _revisionLabel.frame.size.width, _revisionLabel.frame.size.height)];
        [_revisionControl setFrame:CGRectMake(_revisionControl.frame.origin.x, 160+totalYOffset, _revisionControl.frame.size.width, _revisionControl.frame.size.height)];
        [_maxRevisionsLabel setFrame:CGRectMake(_maxRevisionsLabel.frame.origin.x, 205+totalYOffset, _maxRevisionsLabel.frame.size.width, _maxRevisionsLabel.frame.size.height)];
        [_maxRevisions setFrame:CGRectMake(_maxRevisions.frame.origin.x, 200+totalYOffset, _maxRevisions.frame.size.width, _maxRevisions.frame.size.height)];
        
        [_checkinCheckoutLabel setFrame:CGRectMake(_checkinCheckoutLabel.frame.origin.x, 245+totalYOffset, _checkinCheckoutLabel.frame.size.width, _checkinCheckoutLabel.frame.size.height)];
        [_checkinCheckout setFrame:CGRectMake(_checkinCheckout.frame.origin.x, 240+totalYOffset, _checkinCheckout.frame.size.width, _checkinCheckout.frame.size.height)];
        [_createButton setFrame:CGRectMake(_createButton.frame.origin.x, 280+totalYOffset, _createButton.frame.size.width, _createButton.frame.size.height)];
        
        [_scrollView addSubview:_nameLabel]; 
        [_scrollView addSubview:_nameTextField]; 
        [_scrollView addSubview:_enabledLabel]; 
        [_scrollView addSubview:_enabledSwitch]; 
        [_scrollView addSubview:_loggingLabel]; 
        [_scrollView addSubview:_loggingEnabled]; 
        [_scrollView addSubview:_revisionLabel]; 
        [_scrollView addSubview:_revisionControl]; 
        [_scrollView addSubview:_maxRevisionsLabel];
        [_scrollView addSubview:_maxRevisions];
        [_scrollView addSubview:_checkinCheckoutLabel];
        [_scrollView addSubview:_checkinCheckout];
        [_scrollView addSubview:_createButton];
        [_scrollView setScrollEnabled:YES];
        _scrollView.frame = CGRectMake(0, -20, 320, 960);
        if(totalYOffset < 100){
        _scrollView.contentSize = CGSizeMake(320, 850);
        } else if (totalYOffset < 150 && totalYOffset > 100){
            _scrollView.contentSize = CGSizeMake(320, 950);
        } else {
            _scrollView.contentSize = CGSizeMake(320, 1050);
        }
        UISwipeGestureRecognizer * swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(screenPressed)];
        swipe.direction = UISwipeGestureRecognizerDirectionUp;
        [self.scrollView addGestureRecognizer:swipe];
        [self.view addSubview:_scrollView];
    }
    }
}

- (void) viewWillDisappear:(BOOL)animated{
    [UIView animateWithDuration:0.25 animations:^(void) {
        imgView.alpha = 0;
        imgView2.alpha = 0;
    }];
    imgView = nil;
    imgView2 = nil;
    
    //TIP 5/26/2013 POI-45 fix
    if(keys2){
        [keys2 removeAllObjects]; 
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    svos = _scrollView.contentOffset;
    CGPoint pt;
    CGRect rc = [textField bounds];
    rc = [textField convertRect:rc toView:_scrollView];
    pt = rc.origin;
    pt.x = 0;
    pt.y -= 60;
    [_scrollView setContentOffset:pt animated:YES];
}

- (void) viewWillAppear:(BOOL)animated{
    if(!imgView){
    imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 320, 44)];
    imgView.image = [UIImage imageNamed:@"newConnectionBar.png"];
    [self.navigationController.view addSubview:imgView];
    imgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(5, 27, 50, 29)];
    imgView2.image = [UIImage imageNamed:@"backButton.png"];
    [self.navigationController.view addSubview:imgView2];
    }
    imgView.alpha = 0;
    imgView2.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^(void) {
        imgView.alpha = 1;
        imgView2.alpha = 1;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}
- (IBAction)revisionControlEnabledValueChanged {
    if(_revisionControl.isOn){
        [_maxRevisions setEnabled:YES];
        [_maxRevisions setAlpha:1];
        // JB 6/9/13; IOS-6 - https://pointio.atlassian.net/browse/IOS-6 Set Default Max # Revisions to 3
        _maxRevisions.text=@"3";
        [_revisionControl setAlpha:1];
    }
    if(!_revisionControl.isOn){
        [_maxRevisions setEnabled:NO];
        [_maxRevisions setAlpha:0.25];
        // JB 6/9/13; IOS-6 - https://pointio.atlassian.net/browse/IOS-6 Set Default Max # Revisions to null if Revs off
        _maxRevisions.text=@"";
    }
}

- (IBAction)screenPressed {
    for(id obj in _allUIInputs){
        if ([obj isKindOfClass:[UITextField class]]) {
            [obj resignFirstResponder];
        }
    }
    [_maxRevisions resignFirstResponder];
    [_nameTextField resignFirstResponder];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [_scrollView setContentOffset:svos animated:YES];
    [textField resignFirstResponder];
    return YES;
}
- (void) displayError{
    if(didNotShowError){
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Entered data is not valid." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 282, 133)];
        [imgView setImage:[UIImage imageNamed:@"enteredDataIsNotValid.png"]];
        [alert addSubview:imgView];
        [alert show];
    didNotShowError = FALSE;
    }
    enteredAllData = FALSE;
}

- (IBAction)createPressed {
    __block NSArray* temp;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSMutableArray* vals = [NSMutableArray array];
        for(id val in _allUIInputs){
            if([val isKindOfClass:[UITextField class]]){
            if([val respondsToSelector:@selector(text)]){
                if([val text] == nil){
                    enteredAllData = FALSE;
                    break;
                } else {
                [vals addObject:[val text]];
                }
            }
            }
            if ([[_nameTextField text]length] == 0) {
                [self displayError];
            }
            if(_revisionControl.isOn && [[_maxRevisions text]length] == 0){
                [self displayError];
            }
            
            if([val isKindOfClass:[UISwitch class]]){
                if ([val isOn]) {
                    [vals addObject:@"1"];
                }
                if(![val isOn]){
                    [vals addObject:@"0"];
                }
            }
        }
        if(enteredAllData){
            if([vals count] != [keys2 count]){
                NSLog(@"Different count objects of keys and values.");
                NSLog(@"VALS = %@, KEYS = %@",vals,keys2);
                [self displayMessage:NO];
            } else {
        _userStorageInput = [NSDictionary dictionaryWithObjects:vals forKeys:keys2];
        
                    // MAKE USER STORAGE INPUT
                    
                    
                    NSArray* keys = [_userStorageInput allKeys];
                    NSArray* values = [_userStorageInput allValues];
                    for(int i = 0; i<[keys count];i++){
                        if(i==0){
                            _userInputString = [NSString stringWithFormat:@"{%@:\"%@\",",[keys objectAtIndex:0],[values objectAtIndex:0]];
                        } else if([keys count]-i == 1) {
                            _userInputString = [_userInputString stringByAppendingFormat:@"%@:\"%@\"}",[keys objectAtIndex:i],[values objectAtIndex:i]];
                        } else {
                            _userInputString = [_userInputString stringByAppendingFormat:@"%@:\"%@\",",[keys objectAtIndex:i],[values objectAtIndex:i]];
                        }
                    }
        
        
        NSString* enabledState;
        if(_enabledSwitch.isOn){
            enabledState = @"1";
        } else {
            enabledState = @"0";
        }
        //TIP 5/26/2013 POI-35 need to handle empty maxRevisions
        NSString* maxRevisions = [_maxRevisions text];        
        NSString* revisionControl;
        if(_revisionControl.isOn){
            revisionControl = @"1";
        } else {
            revisionControl = @"0";
        }
        if([maxRevisions isEqual: @""] || [revisionControl isEqual: @"0"]){
            maxRevisions = @"0";
        }

        NSString* checkinCheckout;
        if(_checkinCheckout.isOn){
            checkinCheckout = @"1";
        } else {
            checkinCheckout = @"0";
        }
        NSString* logginEnabled;
        if(_loggingEnabled.isOn){
            logginEnabled = @"1";
        } else {
            logginEnabled = @"0";
        }
        NSLog(@"SITE TYPE ID = %@",_siteTypeID);
        NSLog(@"NAME = %@",[_nameTextField text]);
        NSLog(@"ENABLED STATE = %@",enabledState);
        NSLog(@"LOGGING ENABLED = %@",logginEnabled);
        NSLog(@"REVISION CONTROL = %@",revisionControl);
        NSLog(@"MAX REVISIONS = %@",maxRevisions);
        NSLog(@"CHECKINCHECKOUT = %@",checkinCheckout);
        NSLog(@"USER INPUT STRING = %@",_userInputString);
        
        NSArray* objects3 = [NSArray arrayWithObjects:_siteTypeID,[_nameTextField text],enabledState,logginEnabled,revisionControl,maxRevisions,checkinCheckout,_userInputString,@"0",nil];
        NSArray* keys3 = [NSArray arrayWithObjects:@"siteTypeId",@"name",@"enabled",@"revisionControl",@"loggingEnabled",@"maxRevisions",@"checkinCheckout",@"siteArguments",@"indexingEnabled",nil];
        NSDictionary* params = [NSDictionary dictionaryWithObjects:objects3 forKeys:keys3];
        
        NSMutableArray* pairs = [[NSMutableArray alloc] initWithCapacity:0];
        for(NSString* key in params){
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, params[key]]];
        }
        
        NSString* requestParams = [pairs componentsJoinedByString:@"&"];
        NSLog(@"REQUEST PARAMS = %@",requestParams);
        NSMutableURLRequest *request2 = [[NSMutableURLRequest alloc] init];
        [request2 setHTTPMethod:@"POST"];
        [request2 addValue:_sessionKey forHTTPHeaderField:@"Authorization"];
        NSURLResponse* urlResponseList2;
        NSError* requestErrorList2;
                
                
            NSString* URLString = [@"https://api.point.io/api/v2/storagesites/create.json" stringByAppendingFormat:@"?%@",requestParams];
            URLString = [URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [request2 setURL:[NSURL URLWithString:URLString]];
                
        [request2 setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSData* response2 = [NSURLConnection sendSynchronousRequest:request2 returningResponse:&urlResponseList2 error:&requestErrorList2];
        temp = [NSJSONSerialization JSONObjectWithData:response2 options:NSJSONReadingMutableContainers error:nil];
        
        NSLog(@"CREATING RESULT = %@",temp);
        // TEMP HOLDS INFO ABOUT NEW STORAGE.
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if(!enteredAllData){
            [self displayError];
            }
            if(temp && [[temp valueForKey:@"ERROR"] integerValue] ==0) {
                [_appDel.enabledConnections addObject:@"1"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLists" object:nil];
                [self displayMessage:YES];
                NSString* temp = [[NSString alloc] init];
                for(int i = 0;i < [_appDel.enabledConnections count];i++){
                    if([[_appDel.enabledConnections objectAtIndex:i] isEqualToString:@"1"]){
                        if(i==0){
                            temp = [NSString stringWithFormat:@"1"];
                        } else {
                            temp = [temp stringByAppendingString:@"1"];
                        }
                    } else {
                        if(i==0){
                            temp = [NSString stringWithFormat:@"0"];
                        } else {
                            temp = [temp stringByAppendingString:@"0"];
                        }
                    }
                }
                [[NSUserDefaults standardUserDefaults] setObject:temp forKey:@"ENABLEDCONNECTIONS"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } else if ([[temp valueForKey:@"ERROR"] integerValue] == 0){
                [self displayMessage:NO];
                }
            });
        }
    });
}

- (void) displayMessage:(BOOL)success{
    if(success){
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"The connection has been added." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        UIImageView* customAlert = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 282, 135)];
        [customAlert setImage:[UIImage imageNamed:@"connectionAddedSuccessfully.png"]];
        [alert addSubview:customAlert];
        alert.delegate = self;
        [alert show];
    } else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An error occured while creating your connection, please try again." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        UIImageView* customAlert = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 282, 153)];
        [customAlert setImage:[UIImage imageNamed:@"errorCreatingConnection"]];
        [alert addSubview:customAlert];
        [alert show];
    }
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    // [TestFlight passCheckpoint:@"User added a connection"];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
