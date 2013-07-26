//
//  datePickerViewController.h
//  point.io
//
//  Created by Constantin Lungu on 4/19/13.
//  Copyright (c) 2013 FusionWorks. All rights reserved.
//

#import <UIKit/UIKit.h>
// #import "AppDelegate.h"

// @class AppDelegate;
@class datePickerViewController;

@protocol datePickerViewControllerDelegate <NSObject>
- (void)datePickerViewControllerDidCancel:(datePickerViewController *)controller;
- (void)datePickerViewController:(datePickerViewController *)controller didSelectValue:(NSString *)theSelectedValue;
@end


@interface datePickerViewController : UIViewController

// @property (nonatomic) AppDelegate* appDel;
@property (nonatomic, weak) id <datePickerViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;


- (IBAction)dateSelectedButtonPressed:(id)sender;


@end


/*
#import <UIKit/UIKit.h>

@class PracticeTimePickerViewController;

@protocol PracticeTimePickerViewControllerDelegate <NSObject>
- (void)practiceTimePickerViewControllerDidCancel:(PracticeTimePickerViewController *)controller;
- (void)practiceTimePickerViewController:(PracticeTimePickerViewController *)controller didSelectPracticeTime:(NSString *)thePraticeTime:(NSString *)thePracticeTimeType;
@end



@interface PracticeTimePickerViewController : UIViewController

{
    IBOutlet UIDatePicker *datePicker;
}

@property (nonatomic, weak) id <PracticeTimePickerViewControllerDelegate> delegate;

@property (nonatomic, strong) NSString      *practiceTime;
@property (nonatomic, strong) UIDatePicker  *datePicker;
@property (nonatomic, strong) NSString      *dateType;

- (IBAction)dateSelectedButtonPressed:(id)sender;

@end
*/
