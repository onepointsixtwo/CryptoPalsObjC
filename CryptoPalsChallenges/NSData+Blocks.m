//
//  NSData+Blocks.m
//  CryptoPalsChallenges
//
//  Created by John Kartupelis on 11/08/2016.
//  Copyright © 2016 John Kartupelis. All rights reserved.
//

#import "NSData+Blocks.h"
#import "NSData+Padding.h"

@implementation NSData (Blocks)

#pragma mark - Block Splitting
-(NSArray<NSData *> *)splitDataIntoBlocks:(NSInteger)blockSize
{
    NSMutableArray<NSData*> *output = [[NSMutableArray alloc] init];
    NSInteger iterations = ceil((float)self.length / (float)blockSize);
    NSInteger dataLength = self.length;
    for(int x = 0; x < iterations; x++)
    {
        NSInteger rangeStart = x * blockSize;
        NSInteger length = blockSize;
        if(rangeStart + length > dataLength)
        {
            length = dataLength - rangeStart;
        }
        NSData* subData = [self subdataWithRange:NSMakeRange(rangeStart, length)];
        subData = [subData addPKCS12PaddingToBlockSize:blockSize];
        [output addObject:subData];
    }
    return output;
}

@end
