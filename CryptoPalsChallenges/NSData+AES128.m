//
//  NSData+AES128.m
//  CryptoPalsChallenges
//
//  Created by John Kartupelis on 11/08/2016.
//  Copyright © 2016 John Kartupelis. All rights reserved.
//

#import "NSData+AES128.h"
#import <CommonCrypto/CommonCrypto.h>
#import "NSData+Blocks.h"
#import "NSData+XOR.h"
#import "NSObject+Random.h"
#import "NSData+Helpers.h"
#import "NSData+Padding.h"
#import "NSData+Encoding.h"

static NSData* AES128ConsistentUnknownKey;
static NSData* AES128RandomBytes;

@implementation NSData (AES128)

#pragma mark - AES128 ECB
- (NSData *)AES128ECBEncryptWithKey:(NSString *)key
{
    unsigned char keyPtr[kCCKeySizeAES128+1];
    
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:(char*)keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSInteger dataLength = [self length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionECBMode,
                                          keyPtr, kCCKeySizeAES128,
                                          NULL ,
                                          [self bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer);
    
    return nil;
}

- (NSData *)AES128ECBDecryptWithKey:(NSString *)key
{
    unsigned char keyPtr[kCCKeySizeAES128+1];
    
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:(char*)keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSInteger dataLength = [self length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionECBMode,
                                          keyPtr, kCCKeySizeAES128,
                                          NULL ,
                                          [self bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer);
    
    return nil;
}

#pragma mark Detection
-(BOOL)isPotentiallyECB128Encrypted
{
    //Check if there are any matching 16 byte-wide blocks
    BOOL potentiallyECB = FALSE;
    
    NSInteger iterations = (NSInteger)((float)self.length * 0.5f);
    for(int y = 0; y <= iterations; y++)
    {
        //Split into blocks of 16 bytes
        NSInteger blockLength = 16;
        NSMutableArray<NSData*>* dataBlocks = [NSMutableArray new];
        NSInteger blocks = ceil(self.length / blockLength);
        for(int x = 0; x < blocks; x++)
        {
            NSInteger rangeStart = x * blockLength + y;
            NSInteger rangeLength = blockLength;
            if(rangeStart + rangeLength < self.length)
            {
                [dataBlocks addObject:[self subdataWithRange:NSMakeRange(rangeStart, rangeLength)]];
            }
        }
        
        for(int x = 0; x < dataBlocks.count; x++)
        {
            for(int y = (x + 1); y < dataBlocks.count; y++)
            {
                NSData* data = dataBlocks[x];
                NSData* data2 = dataBlocks[y];
                if([data isEqualToData:data2])
                {
                    potentiallyECB = TRUE;
                    break;
                }
            }
        }
        
        if(potentiallyECB) break;
    }
    
    return potentiallyECB;
}


/*
 
 CBC works thusly:
 
 - Generate a 'blocksize' piece of random bytes and use this as the initialisation vector - block 0.
 - Iterate over the original data in chunks of size blocksize.
 - XOR each block against the previously encrypted block. This is why the initialisation vector is required - to XOR the first block of the original data against.
 - After XORing each block, encrypt using ECB and append to the output encrypted bytes
 
 Undo by reversing the above process.
 
 NOTE: when the challenge pages use the term adding, they could mean XORing since in a sense this is an addition operation. Probably worth noting when reading future exercises.
 
 */

#pragma mark - AES128 CBC
-(NSData *)AES128CBCEncryptWithKey:(NSString *)key initialisationVector:(NSData*)initialisationVector
{
    NSAssert(key.length == initialisationVector.length, @"The length of the key and the initialisation vector should be equal!");
    
    //Create the mutable data for the output
    NSMutableData* outputData = [[NSMutableData alloc] init];
    
    //Get the blocksize from the size of the initialisation vector.
    NSInteger blockSize = initialisationVector.length;
    
    //Split into blocks
    NSArray<NSData*>* blocks = [self splitDataIntoBlocks:blockSize];
    
    //Iterate over the data and encrypt
    NSData* previousData = initialisationVector;
    for(NSData* block in blocks)
    {
        //XOR against the previous data.
        NSData* dataToEncrypt = [block symmetricLengthXorWithData:previousData];
        
        //Encrypt using AES128ECB
        NSData* encryptedData = [dataToEncrypt AES128ECBEncryptWithKey:key];
        
        //Append the encrypted data to the output data
        [outputData appendData:encryptedData];
        
        //Set the previous data to this encrypted data.
        previousData = encryptedData;
    }
    
    return outputData;
}

-(NSData *)AES128CBCDecryptWithKey:(NSString *)key initialisationVector:(NSData*)initialisationVector
{
    NSAssert(key.length == initialisationVector.length, @"The length of the key and the initialisation vector should be equal!");
    
    //Create the mutable data for the output
    NSMutableData* outputData = [[NSMutableData alloc] init];
    
    //Get the blocksize from the size of the initialisation vector.
    NSInteger blockSize = initialisationVector.length;
    
    //Split into blocks
    NSArray<NSData*>* blocks = [self splitDataIntoBlocks:blockSize];
    
    //Iterate over the data and decrypt
    NSMutableArray<NSData*>* outputDataArray = [[NSMutableArray alloc] init];
    NSInteger startingX = blocks.count - 1;
    for(NSInteger x = startingX; x >= 0; x--)
    {
        //Get the data being decrypted now.
        NSData* dataToDecrypt = blocks[x];
        
        //Get the data to XOR
        NSData* xorData = nil;
        NSInteger index = x - 1;
        if(x < 1)
        {
            xorData = initialisationVector;
        }
        else
        {
            xorData = blocks[index];
        }
        
        //Decrypt the data using AES128ECB
        NSData* decryptedData = [dataToDecrypt AES128ECBDecryptWithKey:key];
        
        //XOR the decrypted data with the xorData
        decryptedData = [decryptedData symmetricLengthXorWithData:xorData];
        
        //Append the data to the output data
        [outputDataArray addObject:decryptedData];
    }
    
    //Add on the data in the reverse order to get it back the right way around.
    for(NSData* data in outputDataArray.reverseObjectEnumerator)
    {
        [outputData appendData:data];
    }
    
    return outputData;
}


#pragma mark - AES128 Randomised
-(NSData *)AES128RandomisedEncryption
{
    //Generate a random key
    NSData* randomKey = [NSData generateRandomBytesOfLength:16];
    
    //Add random number of bytes before and after the plaintext.
    NSData* randomBytesBefore = [NSData generateRandomBytesOfLength:[self randomIntegerInRange:NSMakeRange(5, 10)]];
    NSData* randomBytesAfter = [NSData generateRandomBytesOfLength:[self randomIntegerInRange:NSMakeRange(5, 10)]];
    
    //Add the before and after bytes to the starting data
    NSMutableData* dataToEncrypt = [[NSMutableData alloc] init];
    [dataToEncrypt appendData:randomBytesBefore];
    [dataToEncrypt appendData:self];
    [dataToEncrypt appendData:randomBytesAfter];
    dataToEncrypt = (NSMutableData*)[dataToEncrypt addPKCS12PaddingToBlockSize:16];
    
    //Decide randomly whether to use ECB or CBC
    if([self randomIntegerInRange:NSMakeRange(1, 2)] == 1)
    {
        //Use ECB
        NSLog(@"Encrypt using AES128 ECB");
        return [dataToEncrypt AES128ECBEncryptWithKey:[[NSString alloc] initWithData:randomKey encoding:NSASCIIStringEncoding]];
    }
    else
    {
        //Use CBC
        NSLog(@"Encrypt using AES128 CBC");
        return [dataToEncrypt AES128CBCEncryptWithKey:[[NSString alloc] initWithData:randomKey encoding:NSASCIIStringEncoding] initialisationVector:[NSData generateRandomBytesOfLength:16]];
    }
}

-(NSData *)AES128UnknownConsistentKeyEncryption
{
    //Generate a random key once
    if(AES128ConsistentUnknownKey == nil)
    {
        AES128ConsistentUnknownKey = [NSData generateRandomBytesOfLength:16];
    }
    
    //The data to append to the end of the plain text
    NSData* appendData = [NSData dataWithBase64EncodedString:@"Um9sbGluJyBpbiBteSA1LjAKV2l0aCBteSByYWctdG9wIGRvd24gc28gbXkgaGFpciBjYW4gYmxvdwpUaGUgZ2lybGllcyBvbiBzdGFuZGJ5IHdhdmluZyBqdXN0IHRvIHNheSBoaQpEaWQgeW91IHN0b3A/IE5vLCBJIGp1c3QgZHJvdmUgYnkK"];
    
    
    //Append the data to the end of the plaintext
    NSMutableData* plaintext = self.mutableCopy;
    [plaintext appendData:appendData];
    NSData* plaintextFull = [plaintext addKnownCharacterPaddingToBlockSize:16 paddingCharacter:'A'];
    
    return [plaintextFull AES128ECBEncryptWithKey:[[NSString alloc] initWithData:AES128ConsistentUnknownKey encoding:NSASCIIStringEncoding]];
}

-(NSData *)AES128UnknownConsistentKeyEncryptionWithRandomBytesAtStart
{
    //Generate a random key once
    if(AES128ConsistentUnknownKey == nil)
    {
        AES128ConsistentUnknownKey = [NSData generateRandomBytesOfLength:16];
    }
    
    //Generate some random bytes to prepend to the string
    if(AES128RandomBytes == nil)
    {
        NSInteger randomLength = [self randomIntegerInRange:NSMakeRange(5, 50)];
        AES128RandomBytes = [NSData generateRandomBytesOfLength:randomLength];
        NSLog(@"Random bytes generated of length %i", (int)AES128RandomBytes.length);
    }
    
    //The data to append to the end of the plain text
    NSData* appendData = [NSData dataWithBase64EncodedString:@"Um9sbGluJyBpbiBteSA1LjAKV2l0aCBteSByYWctdG9wIGRvd24gc28gbXkgaGFpciBjYW4gYmxvdwpUaGUgZ2lybGllcyBvbiBzdGFuZGJ5IHdhdmluZyBqdXN0IHRvIHNheSBoaQpEaWQgeW91IHN0b3A/IE5vLCBJIGp1c3QgZHJvdmUgYnkK"];
    
    
    //Append the data to the end of the plaintext
    NSMutableData* plaintext = [[NSMutableData alloc] init];
    [plaintext appendData:AES128RandomBytes];
    [plaintext appendData:self];
    [plaintext appendData:appendData];
    NSData* plaintextFull = [plaintext addKnownCharacterPaddingToBlockSize:16 paddingCharacter:'A'];
    
    return [plaintextFull AES128ECBEncryptWithKey:[[NSString alloc] initWithData:AES128ConsistentUnknownKey encoding:NSASCIIStringEncoding]];
}



@end
