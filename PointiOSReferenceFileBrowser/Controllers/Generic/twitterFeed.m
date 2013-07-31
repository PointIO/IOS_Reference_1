//
//  InfoTwitterFeed.m
//  CoachWhiteBoard
//
//  Created by Boyle Jim on 3/29/12.
//  Copyright (c) 2012 iPlayBook Apps. All rights reserved.
//

#import "twitterFeed.h"

@interface twitterFeed ()

@end

@implementation twitterFeed

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidAppear:(BOOL)animated {
    // load Twitter Content
    // UIWebView *webViewTwitter = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,768, 1001)];
    _webViewTwitter.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
    NSURL *urlAddressTwitter = [NSURL URLWithString:@"http://www.twitter.com/Point_io"];
    NSURLRequest *requestObjTwitter = [NSURLRequest requestWithURL:urlAddressTwitter];
    [_webViewTwitter loadRequest:requestObjTwitter];
    
    // [self.view addSubview:_webViewTwitter];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end

