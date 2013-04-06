//
//  Event.h
//  cocoaconfdc
//
//  Created by Kevin Y. Kim on 3/23/13.
//  Copyright (c) 2013 Kevin Y. Kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject

@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) UIImage  * image;

@property (nonatomic, retain, readonly) NSString * fullName;

@end
