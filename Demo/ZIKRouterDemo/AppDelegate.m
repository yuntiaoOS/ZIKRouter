//
//  AppDelegate.m
//  ZIKRouterDemo
//
//  Created by zuik on 2017/7/5.
//  Copyright © 2017 zuik. All rights reserved.
//

#import "AppDelegate.h"
#import "DetailViewController.h"
#import "AppRouteRegistry.h"
@import ZIKRouter;
@import ZIKRouter.Internal;

@interface AppDelegate () <UISplitViewControllerDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
#if !AUTO_REGISTER_ROUTERS
    // Two ways to manually register:
    
    /*
     1. Register each router by calling +registerRoutableDestination
     
     Problems you may meet:
     You have to register routers before any module reqiures them.
     
     If there're modules running before registration is finished, and modules require some routers before you register them, then there will be assert failure, you should register those required routers earlier.
     Such as routable initial view controller from storyboard, or any routers used in this initial view controller.
    */
    [AppRouteRegistry manuallyRegisterEachRouter];
    
    // 2. Search all routers and register
//    [ZIKRouteRegistry registerAll];

#endif
    ZIKViewRouter.globalErrorHandler = ^(__kindof ZIKViewRouter * _Nullable router,
                                         ZIKRouteAction  _Nonnull action,
                                         NSError * _Nonnull error) {
        NSLog(@"❌ZIKRouter Error: router's action (%@) catch error! code:%@, description: %@,\nrouter:(%@)", action, @(error.code), error.localizedDescription,router);
    };
    
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
    navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;
    splitViewController.delegate = self;
    
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    
    //You can use other url router framework, here is only for demonstrating.
    NSString *identifier = url.host;
    if (identifier == nil) {
        return NO;
    }
    ZIKViewRouterType *routerType = ZIKViewRouter.toIdentifier(identifier);
    if (routerType == nil) {
        return NO;
    }
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
    
    NSDictionary *params = @{ @"url": url,
                              @"options" : options
                              };
    [routerType performPath:ZIKViewRoutePath.showFrom(navigationController)
                configuring:^(ZIKViewRouteConfiguration * _Nonnull config) {
                    [config addUserInfo:params];
                }];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - Split view

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
    if ([secondaryViewController isKindOfClass:[UINavigationController class]] && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[DetailViewController class]] && ([(DetailViewController *)[(UINavigationController *)secondaryViewController topViewController] detailItem] == nil)) {
        // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        return YES;
    } else {
        return NO;
    }
}

@end
