//
//  Event.m
//  cocoaconfdc
//
//  Created by Kevin Y. Kim on 3/23/13.
//  Copyright (c) 2013 Kevin Y. Kim. All rights reserved.
//

#import "Event.h"


@implementation Event

@dynamic timeStamp;
@dynamic firstName;
@dynamic lastName;
@dynamic email;
@dynamic image;

- (NSString *)fullName
{
    if (self.firstName == nil && self.lastName == nil)
        return nil;
    else if (self.firstName == nil)
        return self.lastName;
    else if (self.lastName == nil)
        return self.firstName;
    
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

@end
