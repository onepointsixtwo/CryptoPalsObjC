//
//  NSData+Helpers.m
//  CryptoPalsChallenges
//
//  Created by John Kartupelis on 11/08/2016.
//  Copyright © 2016 John Kartupelis. All rights reserved.
//

#import "NSData+Helpers.h"
#import "NSObject+Random.h"

@implementation NSData (Helpers)

#pragma mark - Hamming
-(NSInteger)hammingDistanceFromData:(NSData *)data
{
    //Create the ret val
    NSInteger hammingDistance = 0;
    
    //Get the bytes
    const unsigned char *dataOneBytes = [self bytes];
    const unsigned char *dataTwoBytes = [data bytes];
    NSInteger dataOneLength = [self length];
    NSInteger dataTwoLength = [data length];
    
    //Get the longer bytes
    NSInteger maxValue = MAX(dataOneLength, dataTwoLength);
    
    //Iterate
    for(int x = 0; x < maxValue; x++)
    {
        if(x > dataOneLength || x > dataTwoLength)
        {
            hammingDistance += 1;
        }
        else
        {
            unsigned char dataOneChar = dataOneBytes[x];
            unsigned char dataTwoChar = dataTwoBytes[x];
            
            int testedBit = 0;
            
            while (testedBit < 8)
            {
                if ((dataOneChar & 0x01) != (dataTwoChar & 0x01))
                {
                    hammingDistance++;
                }
                
                testedBit++;
                dataOneChar = dataOneChar >> 1;
                dataTwoChar = dataTwoChar >> 1;
            }
        }
    }
    
    return hammingDistance;
}

#pragma mark - Random Key Generation
+(NSData *)generateRandomBytesOfLength:(NSInteger)length
{
    NSMutableData* keyData = [[NSMutableData alloc] init];
    
    for(int x = 0; x < length; x++)
    {
        char c = [self randomIntegerInRange:NSMakeRange(0, UCHAR_MAX)];
        [keyData appendBytes:&c length:1];
    }
    
    return keyData;
}

@end
