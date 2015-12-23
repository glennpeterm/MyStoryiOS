//
//  GoogleAuthentication.m
//  KnowMyStoryDemo
//
//  Created by Fingent on 27/01/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import "GoogleAuthentication.h"


@implementation GoogleAuthentication
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissViewController)];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissViewController)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    __weak id _self = self;
    self.popViewBlock = ^(void){
        [_self dismissViewController];
    };
}

- (void)dismissViewController
{
    [self dismissViewControllerAnimated:NO completion:NULL];
}

@end
