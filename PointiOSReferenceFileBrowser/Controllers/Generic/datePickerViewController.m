//
//  datePickerViewController.m
//  point.io
//
//  Created by Constantin Lungu on 4/19/13.
//  Copyright (c) 2013 FusionWorks. All rights reserved.
//

#import "datePickerViewController.h"

@interface datePickerViewController ()

@end

@implementation datePickerViewController

@synthesize datePicker = _datePicker;
@synthesize appDel = _appDel;

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
    NSDate *now = [NSDate date];
    int daysToAdd = 1;
    NSDate *tomorrow = [now dateByAddingTimeInterval:60*60*24*daysToAdd];
    [_datePicker setMinimumDate:tomorrow];
    _appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	// Do any additional setup after loading the view.
}

- (void) viewWillDisappear:(BOOL)animated{
    [[self parentViewController] setValue:[_datePicker date] forKey:@"theDate"];
    NSDate* date = [_datePicker date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    NSString *dateString = [formatter stringFromDate:date];
    [_appDel setShareExpirationDate:dateString];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setDatePicker:nil];
    [super viewDidUnload];
}
@end
