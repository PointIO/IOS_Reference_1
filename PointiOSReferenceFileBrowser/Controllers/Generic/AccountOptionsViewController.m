//
//  AccountOptionsViewController.m
//  PointiOSReferenceFileBrowser
//
//  Created by jimboyle on 8/8/13.
//  Copyright (c) 2013 PointIO. All rights reserved.
//

#import "AccountOptionsViewController.h"

@interface AccountOptionsViewController ()

@end

@implementation AccountOptionsViewController

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
    // _webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
    NSURL *urlAddress = [NSURL URLWithString:@"http://www.point.io/account"];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:urlAddress];
    [_webView loadRequest:requestObj];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
