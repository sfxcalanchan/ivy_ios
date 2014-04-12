//
//  MainViewController.m
//  Ivy
//
//  Created by Alan Chan on 12/4/14.
//  Copyright (c) 2014 Alan Chan. All rights reserved.
//

#import "MainViewController.h"
#import "BeaconMonitoringService.h"

@interface MainViewController ()

@end

@implementation MainViewController

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
    // Do any additional setup after loading the view from its nib.
    
    NSUUID *uuid = [[NSUUID alloc]initWithUUIDString:@"ABCDDCBA-B644-4520-8F0C-720EAF059935"];
    [[BeaconMonitoringService sharedInstance] startMonitoringBeaconWithUUID:uuid major:0 minor:0 identifier:@"me.collectivity.ivy_ios" onEntry:YES onExit:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
