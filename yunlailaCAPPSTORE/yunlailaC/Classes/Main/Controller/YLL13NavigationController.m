//
//  YLL13NavigationController.m
//  yunlailaC
//
//  Created by admin on 16/12/26.
//  Copyright © 2016年 com.yunlaila. All rights reserved.
//

#import "YLL13NavigationController.h"

@interface YLL13NavigationController ()

@end

@implementation YLL13NavigationController
+ (void)load
{
    UIBarButtonItem *item=[UIBarButtonItem appearanceWhenContainedIn:self, nil ];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[NSFontAttributeName]=titleFont1;
    dic[NSForegroundColorAttributeName]=font1_13Color;
    //    [item setTitleTextAttributes:dic forState:UIControlStateNormal];
    
    //    UINavigationBar *bar = [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[self]];
    UINavigationBar *bar = [UINavigationBar appearanceWhenContainedIn:self, nil];
    [bar setBackgroundImage:[UIImage imageWithColor:titleView13Color] forBarMetrics:UIBarMetricsDefault];
    NSMutableDictionary *dicBar=[NSMutableDictionary dictionary];
    
    dicBar[NSFontAttributeName]=titleFont1;
    [bar setTitleTextAttributes:dic];
    
    [bar.layer setBorderWidth:2.0];// Just to make sure its working
    [bar.layer setBorderColor:[titleView13Color CGColor]];
    
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
    if (self.viewControllers.count > 0)
    {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    return [super pushViewController:viewController animated:animated];
}

@end
