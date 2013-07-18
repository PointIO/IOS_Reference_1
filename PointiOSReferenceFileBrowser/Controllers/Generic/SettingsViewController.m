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
    
}


- (void) viewWillAppear:(BOOL)animated{
    BOOL timeStampStatus = [[NSUserDefaults standardUserDefaults] boolForKey:@"PointTimeStampStatus"];
    if (!(timeStampStatus)) {
        _timeStampSwitch.on = FALSE;
        NSLog(@"Contents of PointTimeStampStatus is %c", [[NSUserDefaults standardUserDefaults] boolForKey:@"PointTimeStampStatus"]);
    }
    else {
        _timeStampSwitch.on = TRUE;
        NSLog(@"Contents of PointTimeStampStatus is %c", [[NSUserDefaults standardUserDefaults] boolForKey:@"PointTimeStampStatus"]);
    }
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


- (IBAction)timeStampSwitchValueChanged {
    if(_timeStampSwitch.isOn){
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"PointTimeStampStatus"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"Contents of NSUserDefaults is %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);

    }
    else{
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"PointTimeStampStatus"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"Contents of NSUserDefaults is %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);

    }
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
