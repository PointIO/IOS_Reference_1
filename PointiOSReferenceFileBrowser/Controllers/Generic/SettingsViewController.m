//
//  SettingsViewController.m
//  PointiOSReferenceFileBrowser
//
//  Created by jb on 6/22/13.
//  Copyright (c) 2013 PointIO. All rights reserved.
//

#import "SettingsViewController.h"
#import "ColorThemePickerViewController.h"
#import "Common.h"
#import "JMC.h"


@interface SettingsViewController ()

@end

@implementation SettingsViewController

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

    _currentColorThemeLabel.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"defaultColorTheme"];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.leftBarButtonItem.isEnabled;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark
#pragma Implement Delegate Methods

- (void)colorThemePickerViewController:(ColorThemePickerViewController *)controller didSelectValue:(NSString *)theSelectedValue
{
    NSLog(@"Inside Settings, ColorThemePickerDelegateMethod, colorThemePickerDidSelectType, and selectedType is %@", theSelectedValue);
    [self.navigationController popViewControllerAnimated:YES];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _currentColorThemeLabel.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"defaultColorTheme"];
}

// Jira Connect
// - (IBAction)addConnectionPressed:(id)sender {

-(IBAction)showFeedback {
    [self presentModalViewController:[[JMC sharedInstance] viewController] animated:YES];
}

#pragma mark
#pragma Segue Logic

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goToColors"])
    {
        ColorThemePickerViewController *colorThemePickerViewController = segue.destinationViewController;
        colorThemePickerViewController.delegate = self;
        colorThemePickerViewController.currentValue = colorThemePickerViewController.currentValue;
    }
    
}


@end
