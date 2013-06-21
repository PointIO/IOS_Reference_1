//
//  FileViewerControllerIpad.h
//  point.io
//
//  Created by Constantin Lungu on 5/29/13.
//  Copyright (c) 2013 FusionWorks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "TestFlight.h"
#import "MessageUI/MessageUI.h"
#import "AppDelegate.h"

@interface FileViewerControllerIpad : UIViewController <MFMailComposeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *filesTableView;
@property (weak, nonatomic) IBOutlet UIWebView *docWebView;

@property (nonatomic) NSString* shareID;
@property (nonatomic) NSString* folderName;
@property (nonatomic) NSString* sessionKey;
@property (nonatomic,strong) NSArray* JSONSharedFoldersArray;
@property (nonatomic,strong) NSMutableArray* fileNames;
@property (nonatomic,strong) NSMutableArray* fileIDs;
@property (nonatomic) NSString* containerID;
@property (nonatomic) NSString* fileID;
@property (nonatomic) NSString* fileName;
@property (nonatomic) NSURL* fileDownloadURL;
@property (nonatomic) NSString* remotePath;
@property (nonatomic) NSMutableArray* fileShareIDs;
@property (nonatomic) NSMutableArray* containerIDs;
@property (nonatomic) NSMutableArray* filePaths;
@property (nonatomic) NSMutableArray* containerIDHistory;
@property (nonatomic) NSMutableArray* list;
@property (nonatomic) NSString* lastFolderTitle;

// Sharing Files

@property (nonatomic, strong) AppDelegate* appDel;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (nonatomic) NSData* downloadData;
@property (nonatomic) NSDate* expirationDate;
@property (nonatomic) NSString* password;

@property (nonatomic) UILabel* errorOccuredLabel;

@property (nonatomic) int i;
@property (nonatomic) int nestedFoldersCounter;

- (void) getFileNamesAndFileIDs;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *fullScreenButton;
@property (weak, nonatomic) IBOutlet UIImageView *borderImage;

// Sharing stuff

@property (weak, nonatomic) IBOutlet UIView *sharingView;
@property (weak, nonatomic) IBOutlet UILabel *passwordsDontMatchLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareBarButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UISwitch *printSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *downloadSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *expireSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *forwardingSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *screenCaptureSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *passwordSwitch;
- (IBAction)shareButtonPressed:(id)sender;

- (IBAction)fullScreenButtonPressed:(id)sender;
- (IBAction)printPressed:(id)sender;
- (IBAction)sharePressed:(id)sender;
@end
