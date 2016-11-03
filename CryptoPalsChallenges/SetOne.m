//
//  SetOne.m
//  CryptoPalsChallenges
//
//  Created by John Kartupelis on 04/08/2016.
//  Copyright © 2016 John Kartupelis. All rights reserved.
//

#import "SetOne.h"
#import "NSData+Encoding.h"
#import "NSString+PlainText.h"
#import "NSData+XOR.h"
#import "NSData+Helpers.h"
#import "NSData+AES128.h"

@implementation SetOne

-(void)start
{
    //1:1
    [self setOneChallengeOne];
    
    //1:2
    [self setOneChallengeTwo];
    
    //1:3
    [self setOneChallengeThree];
    
    //1:4
    [self setOneChallengeFour];
    
    //1:5
    [self setOneChallengeFive];
    
    //1:6
    [self setOneChallengeSix];
    
    //1:7
    [self setOneChallengeSeven];
    
    //1:8
    [self setOneChallengeEight];
}

-(void)setOneChallengeOne
{
    //Convert hex string to base64 string
    NSString* startingHex = @"49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d";
    NSData* data = [NSData dataWithHexEncodedString:startingHex];
    NSString* outputBase64 = [data base64EncodedString];
    NSAssert([outputBase64 isEqualToString:@"SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t"], @"Set one challenge one should produce the correct output");
}

-(void)setOneChallengeTwo
{
    //XOR fixed length buffer
    NSString* xorHexStringOne = @"1c0111001f010100061a024b53535009181c";
    NSString* xorHexStringTwo = @"686974207468652062756c6c277320657965";
    
    //Convert to data
    NSData* dataOne = [NSData dataWithHexEncodedString:xorHexStringOne];
    NSData* dataTwo = [NSData dataWithHexEncodedString:xorHexStringTwo];
    
    //XOR
    NSData* xorData = [dataOne symmetricLengthXorWithData:dataTwo];
    
    //Output
    NSString* xorHexString = [xorData hexEncodedString];
    
    NSAssert([xorHexString isEqualToString:@"746865206b696420646f6e277420706c6179"], @"Output should equal result");
}

-(void)setOneChallengeThree
{
    //Work out which single character has been used to XOR based on output plain text received
    
    //Starting data
    NSString* hexStringStarting = @"1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736";
    NSData* startingData = [NSData dataWithHexEncodedString:hexStringStarting];
    
    //Try xor-ing with every character, and rate the outputs
    NSString* bestString = @"";
    float bestStringRating = 0.f;
    for(unsigned char x = 0; x < UCHAR_MAX; x++)
    {
        NSData* output = [startingData singleCharacterXorCharacter:x];
        NSString* outputString = [[NSString alloc] initWithData:output encoding:NSASCIIStringEncoding];
        float rating = [outputString plainTextRating];
        if(rating > bestStringRating)
        {
            bestString = outputString;
            bestStringRating = rating;
        }
    }
    
    //Output the best found string
    //NSLog(@"Best string found:%@", bestString);
    
    //Added afterwards for neatness.
    NSAssert([bestString isEqualToString:@"Cooking MC's like a pound of bacon"], @"Output should be 'Cooking MC's like a pound of bacon'");
}

-(void)setOneChallengeFour
{
    //Detect single character XOR
    
    //Get the file as a string.
    NSString* filePath = @"/Users/johnkartupelis/Documents/Personal/CryptoPalsChallenges/CryptoPalsChallenges/set1challenge4xor.txt";
    NSString* fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:nil];
    
    //Convert to an array (split by newline)
    NSArray* lines = [fileContents componentsSeparatedByString:@"\n"];
    
    //Iterate over the lines
    NSData* bestData = nil;
    NSString* bestString = @"";
    float bestRating = 0.f;
    for(NSString* line in lines)
    {
        //Get the data
        NSData* data = [NSData dataWithHexEncodedString:line];
        
        //Iterate over single character xor to find the best string
        for(unsigned char x = 0; x < UCHAR_MAX; x++)
        {
            NSData* output = [data singleCharacterXorCharacter:x];
            NSString* outputString = [[NSString alloc] initWithData:output encoding:NSASCIIStringEncoding];
            float rating = [outputString plainTextRating];
            if(rating > bestRating)
            {
                bestString = outputString;
                bestRating = rating;
                bestData = data;
            }
        }
    }
    
    //Print out the best data
    NSString* hexString = [bestData hexEncodedString];
    NSLog(@"\nBEST ORIGINAL DATA:\n%@\nBEST STRING:%@\n", hexString, bestString);
}

-(void)setOneChallengeFive
{
    //Use a repeating key xor on the original data
    
    //Get the starting string / key
    NSString* startingString = @"Burning 'em, if you ain't quick and nimble\nI go crazy when I hear a cymbal";
    NSString* key = @"ICE";
    
    //Convert to data
    NSData* startingStringData = [startingString dataUsingEncoding:NSASCIIStringEncoding];
    NSData* keyData = [key dataUsingEncoding:NSASCIIStringEncoding];
    
    //Get the output data
    NSData* outputData = [startingStringData repeatingKeyXorwithKey:keyData];
    
    //Output as hex
    NSString* outputHexString = [outputData hexEncodedString];
    
    NSAssert([outputHexString isEqualToString:@"0b3637272a2b2e63622c2e69692a23693a2a3c6324202d623d63343c2a26226324272765272a282b2f20430a652e2c652a3124333a653e2b2027630c692b20283165286326302e27282f"], @"The output should be correct");
}

-(void)setOneChallengeSix
{
    //FIRST PROPER CHALLENGE! Decrypt the file.
    
    //Get the file as data
    NSString* filePath = @"/Users/johnkartupelis/Documents/Personal/CryptoPalsChallenges/CryptoPalsChallenges/set1challenge6decryption.txt";
    NSString* fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:nil];
    NSData* fileData = [NSData dataWithBase64EncodedString:fileContents];
    
    //Iterate over key sizes
    NSMutableDictionary<NSNumber*, NSNumber*> *keySizeToHammingDistanceDictionary = [NSMutableDictionary new];
    for(NSInteger keySize = 2; keySize <= 40; keySize++)
    {
        //Take the hamming distance between some blocks.
        NSInteger blocksToAverage = 4;
        NSInteger totalHammingDistance = 0;
        NSInteger totalAdded = 0;
        NSData* previousData;
        for(int block = 0; block < blocksToAverage; block++)
        {
            NSData* data = [fileData subdataWithRange:NSMakeRange(block * keySize, keySize)];
            
            if(previousData)
            {
                //Get the hamming distance between the previous data and this
                NSInteger hammingDistance = [data hammingDistanceFromData:previousData];
                totalHammingDistance += hammingDistance;
                totalAdded++;
            }
            
            previousData = data;
        }
        
        //Get the average hamming distance
        double averageHammingDistance = (double)totalHammingDistance / (double)totalAdded;
        
        //normalise by dividing by keysize
        double normalisedHammingDistance = averageHammingDistance / (double)keySize;
        
        [keySizeToHammingDistanceDictionary setObject:@(keySize) forKey:@(normalisedHammingDistance)];
    }
    
    //Get the best x key sizes
    NSInteger keysToTry = 3;
    NSMutableArray<NSNumber*>* keySizes = [NSMutableArray new];
    NSArray<NSNumber*>* hammingDistances = [keySizeToHammingDistanceDictionary allKeys];
    NSSortDescriptor *lowestToHighest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:TRUE];
    hammingDistances = [hammingDistances sortedArrayUsingDescriptors:[NSArray arrayWithObject:lowestToHighest]];
    for(int x = 0; x < keysToTry; x++)
    {
        [keySizes addObject:[keySizeToHammingDistanceDictionary objectForKey:[hammingDistances objectAtIndex:x]]];
    }
    
    
    //Iterate over the keys and try decrypting - take the best.
    float bestDecryptedDataStringRating = 0.f;
    NSString* bestDecryptedDataString = @"";
    NSInteger keySizeActual = 0;
    for(NSNumber* keySize in keySizes)
    {
        //Get the key size as an integer
        NSInteger bestKeySize = keySize.integerValue;
        
        //Break the ciphertext into blocks the length of the best keysize
        NSMutableArray<NSData*>* originalBlocksOfKeysizeLength = [NSMutableArray new];
        NSInteger loops = ceil(fileData.length / bestKeySize);
        for(NSInteger x = 0; x < loops; x++)
        {
            NSInteger startingRange = x * bestKeySize;
            NSInteger bytes = bestKeySize;
            if(startingRange + bytes >= fileData.length)
            {
                bytes = 1;
            }
            NSData* data = [fileData subdataWithRange:NSMakeRange(startingRange, bytes)];
            [originalBlocksOfKeysizeLength addObject:data];
        }
        
        
        //IMPORTANT TO NOT SCREW UP!
        //Transpose the blocks:make a block that is the first byte of every block, and a block that is the second byte of every block, and so on
        
        //Create the transposed block storage
        NSMutableArray<NSMutableData*>* transposedBlocks = [NSMutableArray new];
        for(int x = 0; x < bestKeySize; x++)
        {
            [transposedBlocks addObject:[NSMutableData new]];
        }
        
        //Add the data to the transposed blocks
        for(NSData* data in originalBlocksOfKeysizeLength)
        {
            for(int x = 0; x < data.length; x++)
            {
                NSData* subData = [data subdataWithRange:NSMakeRange(x, 1)];
                NSMutableData* storage = [transposedBlocks objectAtIndex:x];
                [storage appendData:subData];
            }
        }
        
        
        //Create a mutable data array to store the key as its found
        NSMutableData* keyData = [NSMutableData new];
        for(NSData* data in transposedBlocks)
        {
            CGFloat bestRating = CGFLOAT_MIN;
            unsigned char bestChar;
            
            //Iterate over single character xor to find the best string
            for(unsigned char x = 0; x < UCHAR_MAX; x++)
            {
                NSData* output = [data singleCharacterXorCharacter:x];
                NSString* outputString = [[NSString alloc] initWithData:output encoding:NSASCIIStringEncoding];
                float rating = [outputString plainTextRating];
                if(rating > bestRating)
                {
                    bestRating = (CGFloat)rating;
                    bestChar = x;
                }
            }
            
            [keyData appendBytes:&bestChar length:1];
        }
        
        //Try to read the original data using the key
        NSData* decryptedData = [fileData repeatingKeyXorwithKey:keyData];
        NSString* decryptedDataString = [[NSString alloc] initWithData:decryptedData encoding:NSASCIIStringEncoding];
        CGFloat rating = [decryptedDataString plainTextRating];
        if(rating > bestDecryptedDataStringRating)
        {
            bestDecryptedDataString = decryptedDataString;
            bestDecryptedDataStringRating = rating;
            keySizeActual = bestKeySize;
        }
    }
    
    //Print out the best decrypted string
    NSLog(@"\nBest decrypted string (KEYSIZE:%i):\n\n%@", (int)keySizeActual, bestDecryptedDataString);
}

-(void)setOneChallengeSeven
{
    //Get the file as data
    NSString* filePath = @"/Users/johnkartupelis/Documents/Personal/CryptoPalsChallenges/CryptoPalsChallenges/s1c7.txt";
    NSString* fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:nil];
    NSData* fileData = [NSData dataWithBase64EncodedString:fileContents];
    
    //The key
    NSString* key = @"YELLOW SUBMARINE";
    
    //Decrypt the data
    NSData* decryptedData = [fileData AES128ECBDecryptWithKey:key];
    
    //Print out the decrypted data
    NSLog(@"\nDecrypted AES256:\n%@", [[NSString alloc] initWithData:decryptedData encoding:NSASCIIStringEncoding]);
}

-(void)setOneChallengeEight
{
    //Get the file as data
    NSString* filePath = @"/Users/johnkartupelis/Documents/Personal/CryptoPalsChallenges/CryptoPalsChallenges/s1c8";
    NSString* fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:nil];
    
    //Convert to an array (split by newline)
    NSArray* lines = [fileContents componentsSeparatedByString:@"\n"];
    
    //Iterate over the lines
    NSData* ecbData = nil;
    for(NSString* line in lines)
    {
        //Get the data
        NSData* data = [NSData dataWithHexEncodedString:line];
        if([data isPotentiallyECB128Encrypted])
        {
            ecbData = data;
            break;
        }
    }
    
    if(ecbData)
    {
        NSLog(@"\nFound potential ECB data:\n%@", [ecbData hexEncodedString]);
    }
}

@end
