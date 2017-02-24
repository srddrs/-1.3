//
//  YLLBaseViewController.m
//  yunlailaC
//
//  Created by admin on 16/7/11.
//  Copyright © 2016年 com.yunlaila. All rights reserved.
//

#import "YLLBaseViewController.h"

@interface YLLBaseViewController ()

@end

@implementation YLLBaseViewController
@synthesize httpRequestDelegate;
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)])
//    {
//        self.automaticallyAdjustsScrollViewInsets = NO;
//    }
//    NSLog(@"AAA:%d",[[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue]);
//    if (IsIOS7)
//    {
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
//    }
    [MobClick beginLogPageView:NSStringFromClass([self class])];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
     [MobClick endLogPageView:NSStringFromClass([self class])];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
     [self startTrackingLocation];
    
}

- (void)startTrackingLocation {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined) {
        [[LocationManager sharedInstance] startUpdatingLocation];
    }
    else if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        [[LocationManager sharedInstance] startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            NSLog(@"Got authorization, start tracking location");
            [self startTrackingLocation];
            break;
        case kCLAuthorizationStatusNotDetermined:
            [[LocationManager sharedInstance] startUpdatingLocation];
        default:
            break;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
    self.view.backgroundColor = bgViewColor;
    self.httpRequestDelegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
@end
