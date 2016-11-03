//
//  EntryPoint.m
//  CryptoPalsChallenges
//
//  Created by John Kartupelis on 04/08/2016.
//  Copyright © 2016 John Kartupelis. All rights reserved.
//

#import "EntryPoint.h"
#import "SetOne.h"
#import "SetTwo.h"
#import "SetThreeRunner.h"
#import "SetFourRunner.h"

@implementation EntryPoint

-(void)start
{
    //Record the date
    NSDate* date = [NSDate date];
    
    /*
    //Run set one
    SetOne* one = [[SetOne alloc] init];
    [one start];
    
    //Run set two
    SetTwo* two = [[SetTwo alloc] init];
    [two start];
    */
    //Run set three
    SetThreeRunner* three = [[SetThreeRunner alloc] init];
    [three start];
    
    //Run set four
    SetFourRunner* four = [[SetFourRunner alloc] init];
    [four start];
    
    //Print out the total running time
    NSTimeInterval runningTime = [[NSDate date] timeIntervalSinceDate:date];
    NSLog(@"TOTAL RUNNING TIME %fs", runningTime);
}

@end
