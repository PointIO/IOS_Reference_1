//
//  getAccountViewController.h
//  PointiOSReferenceFileBrowser
//
//  Created by jimboyle on 7/27/13.
//  Copyright (c) 2013 PointIO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "passwordPickerViewController.h"

@class getAccountViewController;

@protocol getAccountViewControllerDelegate <NSObject>
- (void)getAccountViewControllerDidCancel:(getAccountViewController *)controller;
- (void)getAccountViewController:(getAccountViewController *)controller didSelectValue:(NSString *)theSelectedValue;
@end


@interface getAccountViewController : UITableViewController
<
    passwordPickerViewControllerDelegate
>


@property (nonatomic, weak) id <getAccountViewControllerDelegate> delegate;
@property (weak, nonatomic) NSString* sessionKey;
// @property (weak, nonatomic) NSString* password;
@property (nonatomic) NSString* partnerSession;

@property (nonatomic, strong) IBOutlet UITextField *emailTextField;
@property (nonatomic, strong) IBOutlet UITextField *firstNameTextField;
@property (nonatomic, strong) IBOutlet UITextField *lastNameTextField;
@property (nonatomic, strong) IBOutlet UITextField *passwordTextField;

- (IBAction)okButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;

@end
