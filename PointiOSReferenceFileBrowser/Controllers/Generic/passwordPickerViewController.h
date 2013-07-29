//
//  passwordPickerViewController.h
//  PointiOSReferenceFileBrowser
//
//  Created by jimboyle on 7/24/13.
//  Copyright (c) 2013 PointIO. All rights reserved.
//

#import <UIKit/UIKit.h>

@class passwordPickerViewController;

@protocol passwordPickerViewControllerDelegate <NSObject>
- (void)passwordPickerViewControllerDidCancel:(passwordPickerViewController *)controller;
- (void)passwordPickerViewController:(passwordPickerViewController *)controller didSelectValue:(NSString *)theSelectedValue;
@end


@interface passwordPickerViewController : UITableViewController
<
    UITextFieldDelegate
>


@property (nonatomic, weak) id <passwordPickerViewControllerDelegate> delegate;

@property (nonatomic, strong) IBOutlet UITextField * passwordTextField1;
@property (nonatomic, strong) IBOutlet UITextField * passwordTextField2;

- (IBAction)cancelButtonPressed:(id)sender;


@end