//
//  AppDelegate.m
//  TabataTimer
//
//  Created by Alexey Bidnyk on 27.09.16.
//  Copyright © 2016 Alexey Bidnyk. All rights reserved.
//

#import "AppDelegate.h"

#import "ABTimerViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    if ([navigationController isMemberOfClass:[UINavigationController class]]) {
        ABTimerViewController *timerViewController = (ABTimerViewController *)navigationController.topViewController;
        if ([timerViewController isMemberOfClass:[ABTimerViewController class]]) {
            [timerViewController stopTimer];
        }
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    if ([navigationController isMemberOfClass:[UINavigationController class]]) {
        ABTimerViewController *timerViewController = (ABTimerViewController *)navigationController.topViewController;
        if ([timerViewController isMemberOfClass:[ABTimerViewController class]]) {
            [timerViewController stopTimer];
        }
    }
}

@end
