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



@property (nonatomic, weak) id <passwordPickerViewControllerDelegate> delegate;

@property (nonatomic, strong) IBOutlet UITextField * passwordTextField1;
@property (nonatomic, strong) IBOutlet UITextField * passwordTextField2;
@property (nonatomic, strong) IBOutlet UILabel * passwordErrorLabel;


// actions
- (IBAction)cancelButtonPressed:(id)sender;


@end


/*
 @class EditTextFieldViewController;
 
 @protocol EditTextFieldViewControllerDelegate <NSObject>
 - (void)editTextFieldViewControllerDidCancel:(EditTextFieldViewController *)controller;
 - (void)editTextFieldViewController:(EditTextFieldViewController *)controller didEditTextField:(NSString *)textFieldNewValue:(NSString *)textFieldBeingEdited;
 @end
 
 
 
 @interface EditTextFieldViewController : UITableViewController
 
 @property (nonatomic, weak) id <EditTextFieldViewControllerDelegate> delegate;
 
 @property (nonatomic, strong) IBOutlet UITextField * textField;
 @property (nonatomic, strong) NSString * textFieldValueFromCaller;
 @property (nonatomic, strong) NSString * textFieldBeingEdited;
 
 
 
 @end
*/