//
//  main.m
//  CryptoPalsChallenges
//
//  Created by John Kartupelis on 04/08/2016.
//  Copyright © 2016 John Kartupelis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntryPoint.h"

static EntryPoint *entryPoint;

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        entryPoint = [[EntryPoint alloc] init];
        [entryPoint start];
        return entryPoint.exitCode;
    }
    return 0;
}
