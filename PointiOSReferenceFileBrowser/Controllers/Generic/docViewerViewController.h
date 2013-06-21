#import <UIKit/UIKit.h>
#import "sharingViewController.h"
#import "TestFlight.h"
#import "MBProgressHUD.h"
#import "QuickLook/QuickLook.h"

@interface docViewerViewController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate, UISplitViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *docWebView;

// REST API

@property (nonatomic) NSString* sessionKey;
@property (nonatomic) NSString* shareID;
@property (nonatomic) NSString* containerID;
@property (nonatomic) NSString* remotePath;
@property (nonatomic) NSString* fileName;
@property (nonatomic) NSString* fileID;
@property (nonatomic, strong) NSData* downloadData;

@property (nonatomic, strong) NSURL* fileDownloadURL;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareFileButton;
@property (weak, nonatomic) IBOutlet UILabel *errorOccuredLabel;

@property (nonatomic) IBOutlet UISplitViewController* splitViewController;

- (IBAction)shareFilePressed:(id)sender;

@end