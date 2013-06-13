//
//  datePickerViewController.h
//  point.io
//
//  Created by Constantin Lungu on 4/19/13.
//  Copyright (c) 2013 FusionWorks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@class AppDelegate;

@interface datePickerViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (nonatomic) AppDelegate* appDel;
@end
