//
//  NSData+Padding.m
//  CryptoPalsChallenges
//
//  Created by John Kartupelis on 11/08/2016.
//  Copyright © 2016 John Kartupelis. All rights reserved.
//

#import "NSData+Padding.h"

const NSInteger kInvalidPadding = -1;

@implementation NSData (Padding)

#pragma mark - PKCS12 Padding
-(NSData *)addKnownCharacterPaddingToBlockSize:(NSInteger)blockSize paddingCharacter:(char)paddingCharacter
{
    NSInteger length = self.length;
    NSInteger paddingToAdd = blockSize -(length % blockSize);
    if(paddingToAdd == blockSize && self.length != 0)
    {
        return self;
    }
    else
    {
        NSMutableData* data = self.mutableCopy;
        for(int x = 0; x < paddingToAdd; x++)
        {
            [data appendBytes:&paddingCharacter length:1];
        }
        return data;
    }
}

-(NSData *)addPKCS12PaddingToBlockSize:(NSInteger)blockSize
{
    NSInteger length = self.length;
    NSInteger paddingToAdd = blockSize -(length % blockSize);
    if(paddingToAdd == blockSize && self.length != 0)
    {
        return self;
    }
    else
    {
        char paddingCharacter = (char)paddingToAdd;
        NSMutableData* data = self.mutableCopy;
        for(int x = 0; x < paddingToAdd; x++)
        {
            [data appendBytes:&paddingCharacter length:1];
        }
        return data;
    }
}

-(NSData *)stripPKCS12PaddingWithBlockSize:(NSInteger)blockSize error:(NSError *__autoreleasing *)error
{
    //Guard against uninitialised data
    if(self.length < 1)
    {
        return self;
    }
    
    //Get how much padding we expect there to be
    const char* bytes = (const char*)self.bytes;
    unsigned int lastChar = (int)bytes[self.length - 1];
    
    if((NSInteger)lastChar < blockSize)
    {
        //We expect there to be padding - check if it's valid
        
        NSData* nonPaddedData = [self subdataWithRange:NSMakeRange(0, self.length - (NSInteger)lastChar)];
        NSData* paddedData = [self subdataWithRange:NSMakeRange(self.length - (NSInteger)lastChar, (NSInteger)lastChar)];
        
        BOOL isValidPadding = TRUE;
        const char* paddedDataBytes = (const char*)paddedData.bytes;
        for(int x = 0; x < paddedData.length; x++)
        {
            const char c = paddedDataBytes[x];
            if(c != lastChar)
            {
                isValidPadding = FALSE;
                break;
            }
        }
        
        if(isValidPadding)
        {
            return nonPaddedData;
        }
        else
        {
            if(error)
            {
                *error = [NSError errorWithDomain:@"" code:kInvalidPadding userInfo:nil];
            }
            return nil;
        }
    }
    else
    {
        if(error)
        {
            *error = [NSError errorWithDomain:@"" code:kInvalidPadding userInfo:nil];
        }
        return nil;
    }
}


@end
