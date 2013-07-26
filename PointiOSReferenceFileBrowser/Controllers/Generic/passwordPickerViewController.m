//
//  passwordPickerViewController.m
//  PointiOSReferenceFileBrowser
//
//  Created by jimboyle on 7/24/13.
//  Copyright (c) 2013 PointIO. All rights reserved.
//

#import "passwordPickerViewController.h"

@interface passwordPickerViewController ()

@end

@implementation passwordPickerViewController

@synthesize delegate;


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
    _passwordErrorLabel.hidden = TRUE;
    _passwordTextField1.secureTextEntry=YES;
    _passwordTextField2.secureTextEntry=YES;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}




- (IBAction)okButtonPressed {
    
    // !([[passwordTextField text] length] == 0 && [[reenterPasswordTextField text] length] == 0)){
    if ([[_passwordTextField1 text] length] == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Passwords is Zero Length, Try Again"
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
        [alert show];

    }
    else if (![_passwordTextField1.text isEqualToString:_passwordTextField2.text]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Passwords Do Not Match, Try Again"
                                                       delegate:nil
                   	                           cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else {
        
        [self.delegate passwordPickerViewController:self didSelectValue:_passwordTextField1.text];
        
    }
}


- (IBAction)cancelButtonPressed:(id)sender
{
    [self.delegate passwordPickerViewController:self didSelectValue:nil];
    // [self.delegate passwordPickerViewControllerDidCancel:self];
}




@end
