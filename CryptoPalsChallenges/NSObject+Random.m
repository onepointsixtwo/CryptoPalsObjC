//
//  NSObject+Random.m
//  CryptoPalsChallenges
//
//  Created by John Kartupelis on 05/08/2016.
//  Copyright © 2016 John Kartupelis. All rights reserved.
//

#import "NSObject+Random.h"
#import <stdlib.h>

@implementation NSObject (Random)

-(NSInteger)randomIntegerInRange:(NSRange)range
{
    return (NSInteger)(arc4random_uniform((uint32_t)range.length) + range.location);
}

@end
