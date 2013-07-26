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
}

- (void) viewWillDisappear:(BOOL)animated{
    // [[self parentViewController] setValue:[_datePicker date] forKey:@"theDate"];
    NSDate* date = [_datePicker date];
    ///*
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    NSString *dateString = [formatter stringFromDate:date];
    //*/
    [self.delegate datePickerViewController:self didSelectValue:dateString];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)viewDidUnload {
    [self setDatePicker:nil];
    [super viewDidUnload];
}
@end


