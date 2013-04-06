//
//  AppDelegate.h
//  cocoaconfdc
//
//  Created by Kevin Y. Kim on 3/23/13.
//  Copyright (c) 2013 Kevin Y. Kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CoreDataController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CoreDataController *coreDataController;
@property (strong, nonatomic) NSMutableArray *sampleData;
@property (assign, nonatomic) NSInteger nextIndex;

- (void)loadSampleData;
- (NSDictionary *)nextSampleDatum;

@end
