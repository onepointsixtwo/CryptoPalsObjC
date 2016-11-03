//
//  NSData+XOR.m
//  CryptoPalsChallenges
//
//  Created by John Kartupelis on 11/08/2016.
//  Copyright © 2016 John Kartupelis. All rights reserved.
//

#import "NSData+XOR.h"

@implementation NSData (XOR)

-(NSData *)symmetricLengthXorWithData:(NSData *)data
{
    const unsigned char *data1Bytes = [self bytes];
    const unsigned char *data2Bytes = [data bytes];
    
    // Mutable data that individual xor'd bytes will be added to
    NSMutableData *xorData = [[NSMutableData alloc] init];
    
    for (int i = 0; i < self.length; i++)
    {
        const char xorByte = data1Bytes[i] ^ data2Bytes[i];
        [xorData appendBytes:&xorByte length:1];
    }
    return xorData;
}

-(NSData *)singleCharacterXorCharacter:(const unsigned char)byte
{
    const unsigned char *data1Bytes = [self bytes];
    
    // Mutable data that individual xor'd bytes will be added to
    NSMutableData *xorData = [[NSMutableData alloc] init];
    
    for (int i = 0; i < self.length; i++)
    {
        const unsigned char xorByte = data1Bytes[i] ^ byte;
        [xorData appendBytes:&xorByte length:1];
    }
    return xorData;
}

-(NSData *)repeatingKeyXorwithKey:(NSData *)key
{
    //Get the bytes
    const unsigned char *dataBytes = [self bytes];
    const unsigned char *keyBytes = [key bytes];
    NSInteger dataLength = [self length];
    NSInteger keyLength = [key length];
    
    //Mutable data for response
    NSMutableData* xorData = [[NSMutableData alloc] init];
    
    //Iterate over the data
    for(NSInteger i = 0; i < dataLength; i++)
    {
        //Get the data byte
        const unsigned char dataByte = dataBytes[i];
        
        //use the modulo to get the byte ordinal position of the key
        const unsigned char keyByte = keyBytes[(i % keyLength)];
        
        //xor the result
        const unsigned char xorByte = dataByte ^ keyByte;
        
        //Append the byte to the data
        [xorData appendBytes:&xorByte length:1];
    }
    
    return xorData;
}

@end
