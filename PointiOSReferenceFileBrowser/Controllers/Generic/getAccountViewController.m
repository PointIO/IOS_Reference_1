//
//  getAccountViewController.m
//  PointiOSReferenceFileBrowser
//
//  Created by jimboyle on 7/27/13.
//  Copyright (c) 2013 PointIO. All rights reserved.
//

#import "getAccountViewController.h"

@interface getAccountViewController ()

@end

@implementation getAccountViewController

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

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}


- (IBAction)okButtonPressed:(id)sender  {
    [self.delegate getAccountViewController:self didSelectValue:nil];
}


- (IBAction)cancelButtonPressed:(id)sender {
    [self.delegate getAccountViewController:self didSelectValue:nil];
}


#pragma mark
#pragma Implement Delegate Methods
- (void)passwordPickerViewControllerDidCancel:(passwordPickerViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)passwordPickerViewController:(passwordPickerViewController *)controller didSelectValue:(NSString *)theSelectedValue {
    [self dismissViewControllerAnimated:YES completion:nil];
    _password = theSelectedValue;
}




@end
