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
    NSLog(@"OK Button Pressed Changed");
    [self.delegate passwordPickerViewController:self didSelectValue:@"passwordOK"];
}


- (IBAction)cancelButtonPressed:(id)sender
{
    [self.delegate passwordPickerViewControllerDidCancel:self];
}




@end
