//
//  AppDelegate.m
//  CustomScrollView
//
//  Created by Ole Begemann on 16.04.14.
//  Copyright (c) 2014 Ole Begemann. All rights reserved.
//

#import "AppDelegate.h"
#import "TabBarController.h"
#import "ViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc]init];
    self.window.frame = [UIScreen mainScreen].bounds;
    self.window.backgroundColor = [UIColor whiteColor];
    

    self.window.rootViewController = [[TabBarController alloc]init];

    [self.window makeKeyAndVisible];
    return YES;
}

@end
