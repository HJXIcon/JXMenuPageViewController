//
//  TabBarController.m
//  CustomScrollView
//
//  Created by admin on 2018/10/16.
//  Copyright © 2018年 Ole Begemann. All rights reserved.
//

#import "TabBarController.h"
#import "ViewController.h"
#import "ScrollViewController.h"
@interface TabBarController ()

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    ViewController *vc = [[ViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    vc.title = @"view";
    [self addChildViewController:nav];
    
    ScrollViewController *vc1 = [[ScrollViewController alloc]init];
    UINavigationController *nav1 = [[UINavigationController alloc]initWithRootViewController:vc1];
    vc1.title = @"ScrollView";
    [self addChildViewController:nav1];
}


@end
