//
//  NSData+Blocks.h
//  CryptoPalsChallenges
//
//  Created by John Kartupelis on 11/08/2016.
//  Copyright © 2016 John Kartupelis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Blocks)

//Block splitting
-(NSArray<NSData*>*)splitDataIntoBlocks:(NSInteger)blockSize;

@end
