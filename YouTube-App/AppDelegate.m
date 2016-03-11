//
//  AppDelegate.m
//  YouTube-App
//
//  Created by Admin on 18.05.15.
//  Copyright (c) 2015 AShi. All rights reserved.
//

#import "AppDelegate.h"
#import "PopularVideoViewController.h"
#import <CJPAdController/CJPAdController.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize navController = _navController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    PopularVideoViewController *popularVideoViewController = [[PopularVideoViewController alloc] init];
    UINavigationController *popularVideoNavigationController = [[UINavigationController alloc] initWithRootViewController:popularVideoViewController];
    popularVideoNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle: @"Популярное" image:nil selectedImage:nil];
    
    
    // Set up : CJPAdController--------------------------------------------------------------------------------------------------------------
    
    //self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; // Fixed in iOS8
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    //[[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    /*
     
     By default this demo app is set up to use a UINavigationController.
     Change the boolean below to YES if you wish to see it using a UITabBarController instead.
     
     */
    BOOL useTabBar = NO;
    
    
    /*
     
     STEP 1: Configure CJPAdController
     
     In this example, CJPAdController will use both iAd and AdMob - iAd will be preferred as it is first in the array
     Ads will be positioned at the bottom of the view - this is the default behaviour so is redundant in this example
     Ads will be requested after a 2 second delay after launch
     
     Obviously you will need to provide an actual ad unit ID for AdMob
     "Smart Size" banners will be used (this is YES by default so it's redundant in this example, but included for the sake of completeness
     testDeviceIDs should be replaced with the actual UDID's of any devices you are wanting to receive test ads on. The Simulator will automatically be added to this array.
     */
    [CJPAdController sharedInstance].adNetworks = @[@(CJPAdNetworkAdMob), @(CJPAdNetworkiAd)/*,@(CJPAdNetworkAdMob)*/];
    [CJPAdController sharedInstance].adPosition = CJPAdPositionBottom;
    [CJPAdController sharedInstance].initialDelay = 5.0;
    // AdMob specific
    [CJPAdController sharedInstance].adMobUnitID = self.interstitialAdUnitID;
    [CJPAdController sharedInstance].useAdMobSmartSize = YES;
    [CJPAdController sharedInstance].testDeviceIDs = @[@"this0is3a2fake8UUID",@"and501sth1s0ne"];
    
    // AdMob targeting (don't set these unless your app already has this information from your users and you want to use it to target ads to them)
    // [CJPAdController sharedInstance].adMobGender = kGADGenderMale;
    // [[CJPAdController sharedInstance] setBirthdayWithMonth:4 day:1 year:1985];
    // [[CJPAdController sharedInstance] setLocationWithLatitude:51.507351 longitude:-0.127758 accuracy:10.0];      // You should get real values from CoreLocation. Use the string property below if you want to target geographically but don't use CoreLocation. Don't use both this method and the string below.
    // [CJPAdController sharedInstance].adMobLocationDescription = @"London, UK";   // Only use this if you aren't using the CoreLocation method above for a more accurate location.
    
    // AdMob COPPA compliance
    // As with the targeting above, it is not necessary to set this unless you specifically want to declare your app as being directed to children (@"1") or not to children (@"0")
    // [CJPAdController sharedInstance].tagForChildDirectedTreatment = @"0";
    
    /*
     
     STEP 2: Tell CJPAdController to start serving ads
     
     */
    if (!useTabBar) {
        // 1. UINavigationController Example
        
        //        // init the nav controller and the root view controller
        //        ViewController *rootVC = [[ViewController alloc] init];
        //        _navController = [[UINavigationController alloc] initWithRootViewController:rootVC];
        //
        //        // Start CJPAdController serving ads in the nav controller
        //        [[CJPAdController sharedInstance] startWithViewController:_navController];
        
//        UIStoryboard *storyboard;
//        
//        if ([[UIDevice currentDevice].model hasPrefix:@"iPad"]){
//            storyboard = [UIStoryboard storyboardWithName:@"Main-iPad" bundle:nil];
//        }else{
//            storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        }
        //        if (IS_IPAD) {
        //            storyboard = [UIStoryboard storyboardWithName:@"Main-iPad" bundle:nil];
        //        }else{
        //            storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        //        }
        //        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        //        {
        //            storyboard = [UIStoryboard storyboardWithName:@"Main-iPad" bundle:nil];
        //        }else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        //            storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        //        }
        
        //ViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"Ini"];
        
        // init the nav controller and the root view controller
        //ViewController *rootVC = [[ViewController alloc] init];
        _navController = [[UINavigationController alloc] initWithRootViewController:popularVideoViewController];
        
        [_navController setNavigationBarHidden:YES animated:NO];
        
        // Start CJPAdController serving ads in the nav controller
        [[CJPAdController sharedInstance] startWithViewController:_navController];
        
    }
    else {
//        // 2. UITabBarController Example
//        
//        // init the view controllers
//        //UIViewController *viewController1 = [[ViewController alloc] init];
//        //UIViewController *viewController2 = [[DownloadListViewController alloc] init];
//        
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        ViewController *viewController1 = [storyboard instantiateViewControllerWithIdentifier:@"Ini"];
//        //DownloadListViewController *viewController2 = [storyboard instantiateViewControllerWithIdentifier:@"Ini"];
//        
//        // init the navigation
//        UINavigationController *navController1 = [[UINavigationController alloc] initWithRootViewController:viewController1];
//        navController1.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"CJPAdController Demo" image:nil tag:666];
//        //UINavigationController *navController2 = [[UINavigationController alloc] initWithRootViewController:viewController2];
//        //navController2.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Another Tab" image:nil tag:667];
//        
//        // init the tab bar controller
//        _tabController = [[UITabBarController alloc] init];
//        _tabController.viewControllers = @[navController1/*, navController2*/];
//        
//        // Start CJPAdController serving ads in the nav controller
//        [[CJPAdController sharedInstance] startWithViewController:_tabController];
    }
    
    /*
     
     STEP 3: Set CJPAdController as the root view controller
     
     */
    
    self.window.rootViewController = [CJPAdController sharedInstance];
    
    // Set up : CJPAdController--------------------------------------------------------------------------------------------------------------
    

    
    //self.window.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Default-568h_2x.png"]];
    [self.window makeKeyAndVisible];
    //[self.window setRootViewController:popularVideoNavigationController];
    
    return YES;

}

// Returns the interstitial ad unit ID. In a real-world app each intersitial
// placement would have a distinct unit ID.
- (NSString *)interstitialAdUnitID {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return @"ca-app-pub-5607723734143560/5284984930";
    }else{
        return @"ca-app-pub-5607723734143560/7977549734";
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
