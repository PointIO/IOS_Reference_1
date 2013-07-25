//
//  DocumentShareSettingsViewController.h
//  PointiOSReferenceFileBrowser
//
//  Created by jimboyle on 7/18/13.
//  Copyright (c) 2013 PointIO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageUI/MessageUI.h"
#import "MBProgressHUD.h"
#import "datePickerViewController.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "SystemConfiguration/SystemConfiguration.h"
#import "passwordPickerViewController.h"

@interface DocumentShareSettingsViewController : UITableViewController
<
    MFMailComposeViewControllerDelegate,
    UIAlertViewDelegate,
    UITextFieldDelegate,
    passwordPickerViewControllerDelegate
>


@property (nonatomic) AppDelegate* appDel;

@property (nonatomic) NSURL* fileDownloadURL;
@property (nonatomic) NSData* downloadData;
@property (nonatomic) NSDate* expirationDate;
@property (nonatomic) NSString* docName;
@property (nonatomic) NSString* fileName;
@property (nonatomic) NSString* sessionKey;
@property (nonatomic) NSString* shareID;
@property (nonatomic) NSString* fileID;
@property (nonatomic) NSString* remotePath;
@property (nonatomic) NSString* containerID;
@property (nonatomic) NSString* password;

@property (weak, nonatomic) IBOutlet UILabel *passwordsDontMatchLabel;

@property (nonatomic) BOOL printSwitch;
@property (nonatomic) BOOL downloadSwitch;
@property (nonatomic) BOOL screenCaptureSwitch;
@property (nonatomic) BOOL downloadAsPDFSwitch;
@property (nonatomic) BOOL restrictByIPSwitch;

@property (nonatomic) BOOL expireSwitch;
@property (nonatomic) BOOL passwordSwitch;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareSecurelyButton;

- (IBAction)shareSecurelyPressed:(id)sender;
- (void) donePressed;

@end

