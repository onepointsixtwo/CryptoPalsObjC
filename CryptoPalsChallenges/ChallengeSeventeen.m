//
//  ChallengeSeventeen.m
//  CryptoPalsChallenges
//
//  Created by John Kartupelis on 11/08/2016.
//  Copyright © 2016 John Kartupelis. All rights reserved.
//

/*
 
 Challenge 17 is implementing the CBC padding attack. The oracle methods roughly simulate a web server which creates cookies encrypted and then validates their padding is correct.
 
 */

#import "ChallengeSeventeen.h"
#import "NSObject+Random.h"
#import "NSData+Helpers.h"
#import "NSData+AES128.h"
#import "NSData+Encoding.h"
#import "NSData+Padding.h"

@interface ChallengeSeventeen ()

@property (nonatomic, readonly, strong) NSArray<NSString*>* randomStrings;
@property (nonatomic, strong, readonly) NSString* key;

@end


@implementation ChallengeSeventeen

@synthesize randomStrings = _randomStrings, key = _key;

#pragma mark - Entry point
-(void)start
{
    for(int x = 0; x < 100000; x++)
    {
        NSData* iv = nil;
        NSData* randomData = [self getCBCEncryptedRandomString:&iv];
        NSMutableData* modifiedData = [NSMutableData new];
        const char* bytes = randomData.bytes;
        for(int y = 0; y < randomData.length; y++)
        {
            if(y > randomData.length - 5)
            {
                char character = '\x08';
                [modifiedData appendBytes:&character length:1];
            }
            else
            {
                [modifiedData appendBytes:&bytes[y] length:1];
            }
        }
        BOOL validPadding = [self dataHasValidPadding:modifiedData initialisationVector:iv];
        NSLog(@"%@", validPadding ? @"HAS VALID PADDING" : @"HAS INVALID PADDING");
    }
}


#pragma mark - Oracles
-(NSData*)getCBCEncryptedRandomString:(NSData**)initialisationVector
{
    NSString* key = self.key;
    NSData* iv = [NSData generateRandomBytesOfLength:16];
    NSData* dataToEncode = [self getRandomData];
    if(initialisationVector)
    {
        *initialisationVector = iv;
    }
    return [dataToEncode AES128CBCEncryptWithKey:key initialisationVector:iv];
}

-(BOOL)dataHasValidPadding:(NSData*)data initialisationVector:(NSData*)initialisationVector
{
    NSData* decodedData = [data AES128CBCDecryptWithKey:self.key initialisationVector:initialisationVector];
    NSError* error = nil;
    NSData* dataWithoutPadding = [decodedData stripPKCS12PaddingWithBlockSize:16 error:&error];
    if(error || !dataWithoutPadding)
    {
        return FALSE;
    }
    return TRUE;
}


#pragma mark - Helpers
-(NSData*)getRandomData
{
    return [NSData dataWithBase64EncodedString:[self getRandomBase64String]];
}

-(NSString*)getRandomBase64String
{
    NSArray* randomStrings = self.randomStrings;
    NSInteger randomPosition = [self randomIntegerInRange:NSMakeRange(0, randomStrings.count - 1)];
    return randomStrings[randomPosition];
}

-(NSArray<NSString *> *)randomStrings
{
    if(!_randomStrings)
    {
        NSString* filePath = @"/Users/johnkartupelis/Documents/Personal/CryptoPalsChallenges/CryptoPalsChallenges/c17";
        NSString* fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:nil];
        _randomStrings = [fileContents componentsSeparatedByString:@"\n"];
    }
    return _randomStrings;
}

-(NSString *)key
{
    if(!_key)
    {
        _key = [[NSString alloc] initWithData:[NSData generateRandomBytesOfLength:16] encoding:NSASCIIStringEncoding];
    }
    return _key;
}

@end
