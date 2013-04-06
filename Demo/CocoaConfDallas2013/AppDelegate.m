//
//  AppDelegate.m
//  cocoaconfdc
//
//  Created by Kevin Y. Kim on 3/23/13.
//  Copyright (c) 2013 Kevin Y. Kim. All rights reserved.
//

#import "AppDelegate.h"

#import "MasterViewController.h"
#import "CoreDataController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self loadSampleData];
    
    _coreDataController = [[CoreDataController alloc] init];
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    MasterViewController *controller = (MasterViewController *)navigationController.topViewController;
    controller.managedObjectContext = _coreDataController.managedObjectContext;
    controller.fetchedResultsController = _coreDataController.fetchedResultsController;
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [_coreDataController saveContext];
}

- (void)loadSampleData
{
    NSString *sampleDataPlist = [[NSBundle mainBundle] pathForResource:@"sample_data" ofType:@"plist"];
    NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:sampleDataPlist];
    _sampleData = [NSMutableArray array];
    for (NSDictionary *datum in [plistDictionary valueForKey:@"Data"]) {
        NSMutableDictionary *mutableDatum = [NSMutableDictionary dictionaryWithDictionary:datum];
        
        NSString *imageFilename = [NSString stringWithFormat:@"%@_%@", [datum valueForKey:@"firstName"], [datum valueForKey:@"lastName"]];
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageFilename ofType:@"png"];
        UIImage *image  = [UIImage imageWithContentsOfFile:imagePath];

        [mutableDatum setValue:image forKey:@"image"];
        [_sampleData addObject:mutableDatum];
    }
    _nextIndex = 0;
}

- (NSDictionary *)nextSampleDatum
{
    if (_nextIndex > [_sampleData count]-1) {
        _nextIndex = 0;
    }
    NSDictionary *result = [_sampleData objectAtIndex:_nextIndex];
    _nextIndex++;
    return result;
}

@end
