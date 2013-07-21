#import "ViewController.h"
#import "Common.h"
#import "storageSitesListViewController.h"


#define IS_IPAD (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone)

// static NSString *const kPointAPIKey = @"apikey=b022de6e-9bf6-11e2-b014-12313b093415";


@interface ViewController ()

@end

@implementation ViewController


UIImageView* imgView;

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    if (IS_IPAD) {
    // if ( [(NSString*)[UIDevice currentDevice].model isEqualToString:@"iPad"] ) {
        //        return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
        return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
    } else {
        if(toInterfaceOrientation == UIInterfaceOrientationPortrait){
            return YES;
        } else {
            return NO;
        }
    }
}

- (BOOL) splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _successfulLogin = NO;
    self.splitViewController.delegate = nil;
    self.splitViewController.delegate = self;
    
    [_usernameTextField setDelegate:self];
    _usernameTextField.borderStyle = UITextBorderStyleRoundedRect;

    [_passwordTextField setSecureTextEntry:YES];
    [_passwordTextField setDelegate:self];
    _passwordTextField.borderStyle = UITextBorderStyleRoundedRect;

    [_signOutButton setHidden:YES];

    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([[defaults valueForKey:@"USERNAME"] length] != 0 && [[defaults valueForKey:@"PASSWORD"] length] !=0){
        [_usernameTextField setText:[defaults valueForKey:@"USERNAME"]];
        [_passwordTextField setText:[defaults valueForKey:@"PASSWORD"]];
        _username = [defaults valueForKey:@"USERNAME"];
        _password = [defaults valueForKey:@"PASSWORD"];
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
            [self signIn];
        }
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField{
     if(textField == _usernameTextField){
        [_usernameTextField resignFirstResponder];
        [_passwordTextField becomeFirstResponder];
    }
    if(textField == _passwordTextField){
        [_passwordTextField resignFirstResponder];
        [self signInPressed];
    }
    return YES;
}


- (IBAction)signInPressed {
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
    }
    else{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    if(![[_usernameTextField text] isEqualToString:@""] || ![[_passwordTextField text] isEqualToString:@""]){
        [UIView animateWithDuration:0.3 animations:^(void) {
            [_usernameTextField setAlpha:0];
            [_passwordTextField setAlpha:0];
            [_signInButton setAlpha:0];
            [_signUpButton setAlpha:0];
        }];
    }
    [self signIn];
   }
}

- (IBAction)screenPressed {
    [_usernameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
}

- (IBAction)signOutPressed {
    [self signOut];
}

- (IBAction)signUpPressed {
    if(![Common isConnectedToInternet]){
        UIAlertView* err = [[UIAlertView alloc] initWithTitle:@"Error"
                                                      message:@"Looks like there is no internet connection, please check the settings"
                                                     delegate:nil
                                            cancelButtonTitle:@"Dismiss"
                                            otherButtonTitles:nil];
        UIImageView* temp = [[UIImageView alloc] initWithFrame:CGRectMake(2, 0, 280, 174)];
        temp.image = [UIImage imageNamed:@"noInternetConnection"];
        [err addSubview:temp];
        [err setBackgroundColor:[UIColor clearColor]];
        [err show];
    } else {
        [self performSegueWithIdentifier:@"goToSignup" sender:self];
    }
}

- (void) signIn{ 
    if([[_usernameTextField text] isEqualToString:@""] || [[_passwordTextField text] isEqualToString:@""]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"You haven't entered any username/password"
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles: nil];
        UIImageView* temp = [[UIImageView alloc] initWithFrame:CGRectMake(2, 0, 280, 154)];
        temp.image = [UIImage imageNamed:@"usernamePasswordError.png"];
        [alert addSubview:temp];
        [alert setBackgroundColor:[UIColor clearColor]];
        [alert show];
        if(![[_usernameTextField text] isEqualToString:@""] || ![[_passwordTextField text] isEqualToString:@""]){
        [UIView animateWithDuration:0.3 animations:^(void) {
            [_usernameTextField setText:@""];
            [_passwordTextField setText:@""];
            [_usernameTextField setAlpha:1];
            [_passwordTextField setAlpha:1];
            [_signInButton setAlpha:1];
            [_signUpButton setAlpha:1];
        }];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    } else {
        _postString = [Common getAppKey:@"AppKeyPostString"];
        _username = [_usernameTextField text];
        _password = [_passwordTextField text];
        NSLog(@"IN MAIN VIEW, EMAIL = %@, PASSWORD = %@",_username,_password);
        _postString = [_postString stringByAppendingFormat:@"&email=%@&password=%@",_username,_password];
        [self performSelectorOnMainThread:@selector(performAuthCall) withObject:nil waitUntilDone:YES];
    }
}

- (void) signOut{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [_signOutButton setHidden:YES];
    [_goBackButton setHidden:YES];
    [_usernameTextField setText:@""];
    [_passwordTextField setText:@""];
    [_usernameTextField setHidden:NO];
    [_passwordTextField setHidden:NO];
    [_signInButton setHidden:NO];
    [_signUpButton setHidden:NO];
    [UIView animateWithDuration:0.3 animations:^(void) {
        [_usernameTextField setAlpha:1];
        [_passwordTextField setAlpha:1];
        [_signInButton setAlpha:1];
        [_signUpButton setAlpha:1];
    }];
    _sessionKey = nil;
    _JSONArrayAuth = nil;
    _JSONArrayList = nil;
    _successfulLogin = NO;
    _postString = [Common getAppKey:@"AppKeyPostString"];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    _appDel.sessionKey = nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:@"USERNAME"];
    [defaults setObject:nil forKey:@"PASSWORD"];
    [defaults setObject:nil forKey:@"ENABLEDCONNECTIONS"];
    [defaults setObject:nil forKey:@"NAMETYPES"];
    [defaults setObject:nil forKey:@"ENABLEDTYPES"];
    [defaults synchronize];

}



- (void) performAuthCall{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://api.point.io/api/v2/auth.json"]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[_postString dataUsingEncoding:NSUTF8StringEncoding]];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
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
        }
        else {
            NSURLResponse* urlResponseList;
            NSError* requestErrorList;
            NSData* response = [NSURLConnection sendSynchronousRequest:request
                                                     returningResponse:&urlResponseList
                                                                 error:&requestErrorList];
            if(!response){
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Request response is nil"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Dismiss"
                                                      otherButtonTitles: nil];
                [alert show];
            } else {
                _JSONArrayAuth = [NSJSONSerialization JSONObjectWithData:response
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:nil];
                NSString* errorFlagString = [_JSONArrayAuth valueForKey:@"ERROR"];
                int errorFlag = [errorFlagString integerValue];
                if(errorFlag == 1){
                    [self performSelectorOnMainThread:@selector(displayError) withObject:nil waitUntilDone:YES];
                } else {
                    _successfulLogin = YES;
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:_username forKey:@"USERNAME"];
                    [defaults setObject:_password forKey:@"PASSWORD"];
                    [defaults synchronize];
                    NSDictionary* result = [_JSONArrayAuth valueForKey:@"RESULT"];
                    _sessionKey = [result valueForKey:@"SESSIONKEY"];
                    _appDel.sessionKey = _sessionKey;
                    NSLog(@"SESSION KEY = %@",_sessionKey);
                    // [self performSelectorOnMainThread:@selector(performListCall) withObject:nil waitUntilDone:YES];
                 }
            }
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                if(_JSONArrayAuth != NULL){
                    // [self goToConnectionsView];
                }
            });
        }
    });
}

- (void) displayError{
    _successfulLogin = NO;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"The password or the username is incorrect. Please try again."
                                                   delegate:nil
                                          cancelButtonTitle:@"Dismiss"
                                          otherButtonTitles: nil];
    UIImageView* temp = [[UIImageView alloc] initWithFrame:CGRectMake(2, 0, 280, 154)];
    temp.image = [UIImage imageNamed:@"passwordUsernameIncorrect.png"];
    [alert addSubview:temp];
    [alert setBackgroundColor:[UIColor clearColor]];
    [alert show];
    [_usernameTextField setText:@""];
    [_passwordTextField setText:@""];
    [_usernameTextField setHidden:NO];
    [_passwordTextField setHidden:NO];
    [_signInButton setHidden:NO];
    [_signUpButton setHidden:NO];
    [UIView animateWithDuration:0.3 animations:^(void) {
        [_usernameTextField setAlpha:1];
        [_passwordTextField setAlpha:1];
        [_signInButton setAlpha:1];
        [_signUpButton setAlpha:1];
    }];
}

/*
- (void) goToConnectionsView{
    if([[_JSONArrayAuth valueForKey:@"ERROR"] integerValue] == 0){
        [TestFlight passCheckpoint:@"User logged in"];
        _successfulLogin = YES;
        if (IS_IPAD) {
        // if ([(NSString*)[UIDevice currentDevice].model isEqualToString:@"iPad"] ) {
            [self performSegueWithIdentifier:@"goToDocView" sender:self];
        } else {
            // [self performSegueWithIdentifier:@"goToConnections" sender:self];
            [self performSegueWithIdentifier:@"goToShares" sender:self];
        }
    } else {
        _successfulLogin = NO;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
*/

/*
- (void) performListCall{
     
    // get storageTypes
    NSURLResponse* urlResponseList1;
    NSError* requestErrorList1;
    NSMutableURLRequest *request1 = [[NSMutableURLRequest alloc] init];
    [request1 setURL:[NSURL URLWithString:@"https://api.point.io/api/v2/storagetypes/list.json"]];
    [request1 setHTTPMethod:@"GET"];
    [request1 addValue:_sessionKey forHTTPHeaderField:@"Authorization"];
    NSData* response1 = [NSURLConnection sendSynchronousRequest:request1 returningResponse:&urlResponseList1 error:&requestErrorList1];
    if(!response1){
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Request response is nil" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
    } else {
        _storageTypesArray = [NSJSONSerialization JSONObjectWithData:response1 options:NSJSONReadingMutableContainers error:nil];
    }
    NSLog(@"Inside ViewController, performListCall where storageTypes are %@", _storageTypesArray);
    
    
    
    //
    // get storageSites
    //
    NSURLResponse* urlResponseList2;
    NSError* requestErrorList2;
    NSMutableURLRequest *request2 = [[NSMutableURLRequest alloc] init];
    [request2 setURL:[NSURL URLWithString:@"https://api.point.io/api/v2/storagesites/list.json"]];
    [request2 setHTTPMethod:@"GET"];
    [request2 addValue:_sessionKey forHTTPHeaderField:@"Authorization"];
    NSData* response2 = [NSURLConnection sendSynchronousRequest:request2 returningResponse:&urlResponseList2 error:&requestErrorList2];
    if(!response2){
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Request response is nil" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
    } else {
        _storageSitesArray = [NSJSONSerialization JSONObjectWithData:response2 options:NSJSONReadingMutableContainers error:nil];
    }
    // NSLog(@"Inside ViewController, performListCall where storageTypes are %@", _storageSitesArray);

    
    //
    // create storageSites Arrays for Names, IDs, Enabled Status, SiteTypeID and SiteTypeName
    //
    NSDictionary *resultStorageSitesDictionary = [_storageSitesArray valueForKey:@"RESULT"];
    NSArray *resultColumns = [resultStorageSitesDictionary valueForKey:@"COLUMNS"];
    NSArray *resultData = [resultStorageSitesDictionary valueForKey:@"DATA"];
    
    _storageSitesNamesArray = [[NSMutableArray alloc] init];
    _storageSitesIDsArray = [[NSMutableArray alloc] init];
    _storageSitesEnabledStatusArray = [[NSMutableArray alloc] init];
    _storageSitesSiteTypeNameArray = [[NSMutableArray alloc] init];
    _storageSitesSiteTypeIDArray = [[NSMutableArray alloc] init];
    _storageSitesArrayOfDictionaries = [[NSMutableArray alloc] init];
    
     for(int i=0; i<[resultData count];i++){
        NSArray* data2 = [resultData objectAtIndex:i];
        NSDictionary* temp = [NSDictionary dictionaryWithObjects:data2 forKeys:resultColumns];
        [_storageSitesIDsArray addObject:[temp valueForKey:@"SITEID"]];
        [_storageSitesNamesArray addObject:[temp valueForKey:@"NAME"]];
        [_storageSitesEnabledStatusArray addObject:[temp valueForKey:@"ENABLED"]];
        [_storageSitesSiteTypeIDArray addObject:[temp valueForKey:@"SITETYPEID"]];
        [_storageSitesSiteTypeNameArray addObject:[temp valueForKey:@"SITETYPENAME"]];
        //
        // evaluate storage sites for status of enabled or disabled
        //
        NSArray *keysArray = [[NSArray alloc] initWithObjects:
                              @"StorageSiteID",
                              @"StorageSiteName",
                              @"StorageSiteEnabled",
                              @"StorageSiteSiteTypeID",
                              @"StorageSiteSiteTypeName",
                              nil];
        
        NSArray *valuesArray = [[NSArray alloc] initWithObjects:
                                [_storageSitesIDsArray objectAtIndex:i],
                                [_storageSitesNamesArray objectAtIndex:i],
                                [_storageSitesEnabledStatusArray objectAtIndex:i],
                                [_storageSitesSiteTypeIDArray objectAtIndex:i],
                                [_storageSitesSiteTypeNameArray objectAtIndex:i],
                                nil];
        
        NSDictionary *storageSiteDictionary = [[NSDictionary alloc] initWithObjects:valuesArray forKeys:keysArray];
        [_storageSitesArrayOfDictionaries addObject:storageSiteDictionary];
     }
    
    //
    // get accessRules
    // 
    NSURLResponse* urlResponseList3;
    NSError* requestErrorList3;
    NSMutableURLRequest *request3 = [[NSMutableURLRequest alloc] init];
    [request3 setURL:[NSURL URLWithString:@"https://api.point.io/api/v2/accessrules/list.json"]];
    [request3 setHTTPMethod:@"GET"];
    [request3 addValue:_sessionKey forHTTPHeaderField:@"Authorization"];
    NSData* response3 = [NSURLConnection sendSynchronousRequest:request3 returningResponse:&urlResponseList3 error:&requestErrorList3];
    if(!response3){
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Request response is nil" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
    } else {
        _accessRulesArray = [NSJSONSerialization JSONObjectWithData:response3 options:NSJSONReadingMutableContainers error:nil];
    }
    // NSLog(@"Inside ViewController, performListCall where storageTypes are %@", _accessRulesArray);

    
    //
    // create Dictionary of AccessRulesName, AccessRuleID, AccessRuleEnabled Status
    //
    NSDictionary *resultAccessRulesDictionary = [_accessRulesArray valueForKey:@"RESULT"];
    NSArray *resultColumns1 = [resultAccessRulesDictionary valueForKey:@"COLUMNS"];
    NSArray *resultData1 = [resultAccessRulesDictionary valueForKey:@"DATA"];
    
    _accessRulesNamesArray = [[NSMutableArray alloc] init];
    _accessRulesShareIDArray = [[NSMutableArray array] init];
    _accessRulesSiteIDArray = [[NSMutableArray array] init];
    _accessRulesSiteTypeNameArray = [[NSMutableArray array] init];
    _accessRulesEnabledArray = [[NSMutableArray array] init];
    
    for(int i=0; i<[resultData1 count];i++){
        NSArray* data2 = [resultData1 objectAtIndex:i];
        NSDictionary* temp = [NSDictionary dictionaryWithObjects:data2 forKeys:resultColumns1];
        [_accessRulesNamesArray addObject:[temp valueForKey:@"SHARENAME"]];
        [_accessRulesShareIDArray addObject:[temp valueForKey:@"SHAREID"]];
        [_accessRulesSiteIDArray addObject:[temp valueForKey:@"SITEID"]];
        [_accessRulesSiteTypeNameArray addObject:[temp valueForKey:@"SITETYPENAME"]];
        //
        // evaluate _storageSitesIDArray until finding a matching siteID, then determine if enabled or disabled
        //
        for(int j=0; j<[_storageSitesIDsArray count];j++){
            if ([[_accessRulesSiteIDArray objectAtIndex:i] isEqualToString:[_storageSitesIDsArray objectAtIndex:j]]) {
                NSString *storageSiteEnabledStatus = [[_storageSitesEnabledStatusArray objectAtIndex:j] stringValue];
                if ([storageSiteEnabledStatus isEqualToString:@"1"]) {
                    
                    NSArray *keysArray = [[NSArray alloc] initWithObjects:@"AccessRuleShareID",@"AccessRuleShareName", @"AccessRuleSiteTypeName", nil];
                    NSArray *valuesArray = [[NSArray alloc] initWithObjects:[_accessRulesShareIDArray objectAtIndex:i], [_accessRulesNamesArray objectAtIndex:i], [_accessRulesSiteTypeNameArray objectAtIndex:i], nil];
                    NSDictionary *accessRuleDictionary = [[NSDictionary alloc] initWithObjects:valuesArray forKeys:keysArray];
                    [_accessRulesEnabledArray addObject:accessRuleDictionary];
                    break;
                }
             }
        }
    }
    //
    // send NSArray of Dictionaries (accessRulesEnabledArray) to AppDelegate object
    //
    _appDel.accessRulesEnabledArray = _accessRulesEnabledArray;
    
}
*/

- (void)viewDidUnload {
    [self setGoBackButton:nil];
    [super viewDidUnload];
}

- (void) viewDidAppear:(BOOL)animated{
    if(self.splitViewController){
        self.splitViewController.delegate = nil;
        self.splitViewController.delegate = self;
    }

    [self screenPressed];
    if(_shouldSignIn){
        [_usernameTextField setText:_username];
        [_passwordTextField setText:_password];
        [self signInPressed];
        _shouldSignIn = NO;
    }
    
}

- (void) viewWillAppear:(BOOL)animated{
    if(_successfulLogin){
        [_signOutButton setHidden:NO];
        [_signInButton setHidden:YES];
        [_signUpButton setHidden:YES];
        [_usernameTextField setHidden:YES];
        [_passwordTextField setHidden:YES];
    }
}

- (void) viewWillDisappear:(BOOL)animated{
 
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"goToShares"]){
        accessRulesListViewController * ctvc = [segue destinationViewController];
        // [ctvc setJSONSharedFoldersArray:_JSONArrayList];
        [ctvc setSessionKey:_sessionKey];
    }
    else if([[segue identifier] isEqualToString:@"goToConnections"]){
        storageSitesListViewController * ctvc = [segue destinationViewController];
        [ctvc setStorageSitesArrayOfDictionaries:_storageSitesArrayOfDictionaries];
        [ctvc setSessionKey:_sessionKey];
    }
    else if([[segue identifier] isEqualToString:@"goToDocView"]){
        docViewerViewControlleriPad* dvvc = [segue destinationViewController];
        [dvvc setSessionKey:_sessionKey];
        [dvvc setJSONArrayList:_JSONArrayList];
    }
    else if([[segue identifier] isEqualToString:@"goToSignup"]){
        signupViewController* svc = [segue destinationViewController];
        [svc setSessionKey:_sessionKey];
    }
    else if([[segue identifier] isEqualToString:@"goToSettings"]){
        SettingsViewController* svc2 = [segue destinationViewController];
        // [svc2 setSessionKey:_sessionKey];
    }
    /*
    else if([[segue identifier] isEqualToString:@"manageConnections"]){
        connectionsManagerViewController *cmvc = [segue destinationViewController];
        [cmvc setJSONArrayList:_JSONArrayList];
        // [cmvc setStorageIDs:_storageIDs];
        [cmvc setSessionKey:_sessionKey];
    }
    */

}


@end
