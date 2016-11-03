//
//  NSData+Helpers.h
//  CryptoPalsChallenges
//
//  Created by John Kartupelis on 11/08/2016.
//  Copyright © 2016 John Kartupelis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Helpers)

//Hamming
-(NSInteger)hammingDistanceFromData:(NSData*)data;

//Random key generation
+(NSData*)generateRandomBytesOfLength:(NSInteger)length;

@end
