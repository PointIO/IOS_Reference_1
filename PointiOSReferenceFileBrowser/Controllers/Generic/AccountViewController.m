//
//  AccountViewController.m
//  PointiOSReferenceFileBrowser
//
//  Created by jimboyle on 8/1/13.
//  Copyright (c) 2013 PointIO. All rights reserved.
//

#import "AccountViewController.h"
#import "SignInViewController.h"

@interface AccountViewController ()

@end

@implementation AccountViewController

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
    // Dispose of any resources that can be recreated.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"goToLogin"]){
        SignInViewController* svc = [segue destinationViewController];
        // [svc setSessionKey:_sessionKey];
        // svc.delegate = self;
    }
}

@end
