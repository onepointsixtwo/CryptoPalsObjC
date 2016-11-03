//
//  SetTwo.m
//  CryptoPalsChallenges
//
//  Created by John Kartupelis on 04/08/2016.
//  Copyright © 2016 John Kartupelis. All rights reserved.
//

#import "SetTwo.h"
#import "NSData+Encoding.h"
#import "NSString+PlainText.h"
#import "OrderedKeysMutableDictionary.h"
#import "NSData+Padding.h"
#import "NSData+AES128.h"
#import "NSData+Blocks.h"
#import "NSData+XOR.h"
#import "NSData+Helpers.h"

@interface SetTwo ()
{
    //2:13 vars
    NSInteger userIdCount;
    NSData* randomEncryptionKey;
    
    //2:16 vars
    NSData* randomCBCKey;
    NSData* initialisationVector;
}

@end

@implementation SetTwo

-(void)start
{
    //2:9
    //[self setTwoChallengeNine];
    
    //2:10
    //[self setTwoChallengeTen];
    
    //2:11
    //[self setTwoChallengeEleven];
    
    //2:12
    //[self setTwoChallengeTwelve];
    
    //2:13
    //[self setTwoChallengeThirteen];
    
    //2:14
    //[self setTwoChallengeFourteen];
    
    //2:15
    //[self setTwoChallengeFifteen];
    
    //2:16
    [self setTwoChallengeSixteen];
}

-(void)setTwoChallengeNine
{
    //PKCS12 Pad data
    NSData* data = [@"YELLOW SUBMARINE" dataUsingEncoding:NSASCIIStringEncoding];
    NSInteger blockSize = 20;
    data = [data addPKCS12PaddingToBlockSize:blockSize];
    NSAssert(data.length == 20, @"Data length should be padded to a blocksize of 20");
}

-(void)setTwoChallengeTen
{
    //Implement AES128 CBC
    
    //Get the file input as data
    NSString* filePath = @"/Users/johnkartupelis/Documents/Personal/CryptoPalsChallenges/CryptoPalsChallenges/s2c10";
    NSString* fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:nil];
    NSData* fileData = [NSData dataWithBase64EncodedString:fileContents];
    
    //Set the blocksize
    NSInteger blockSize = 16;
    
    //Create the key
    NSString* key = @"YELLOW SUBMARINE";
    
    //Create the initialisation vector
    char ivByte = '\x00';
    NSMutableData* iv = [[NSMutableData alloc] init];
    for(int x = 0; x < blockSize; x++)
    {
        [iv appendBytes:&ivByte length:1];
    }
    
    NSData* decryptedData = [fileData AES128CBCDecryptWithKey:key initialisationVector:iv];
    NSLog(@"\nDECRYPTED AES128 CBC DATA:\n%@\n", [[NSString alloc] initWithData:decryptedData encoding:NSASCIIStringEncoding]);
}

-(void)setTwoChallengeEleven
{
    NSData* startingData = [@"YELLOW SUBMARINEYELLOW SUBMARINEYELLOW SUBMARINEYELLOW SUBMARINEYELLOW SUBMARINEYELLOW SUBMARINEYELLOW SUBMARINE" dataUsingEncoding:NSASCIIStringEncoding];
    
    for(int x = 0; x < 20; x++)
    {
        NSData* data = [startingData AES128RandomisedEncryption];
        BOOL ECB = [data isPotentiallyECB128Encrypted];
        if(ECB)
        {
            NSLog(@"DETECTED: encrypted using ECB");
        }
        else
        {
            NSLog(@"DETECTED: encrypted using CBC");
        }
    }
}

-(void)setTwoChallengeTwelve
{
    //Byte-at-a-time ECB decryption
    
    //Discover the block size of the cypher by feeding it one byte at a time.
    const unsigned char testChar = '\x26';
    NSMutableData* data = [[NSMutableData alloc] init];
    NSData* outputData = nil;
    NSInteger blockLength = 0;
    NSInteger unknownStringLength = 0;
    for(int x = 2; x < INT_MAX; x+=2)
    {
        //Append another byte to the mutable data.
        [data appendBytes:&testChar length:1];
        [data appendBytes:&testChar length:1];
        
        //Get the encrypted data
        NSData* output = [data AES128UnknownConsistentKeyEncryption];
        
        //Split into blocks which would be of the current block length
        NSArray<NSData*>* blocks = [output splitDataIntoBlocks:x / 2];
        
        //Find out if the first block matches the second
        if(blocks.count > 1 && [blocks[0] isEqualToData:blocks[1]])
        {
            unknownStringLength = output.length - data.length;
            outputData = output;
            blockLength = x / 2;
            break;
        }
    }
    

    //Check if the encryption was ECB
    BOOL isECB = [outputData isPotentiallyECB128Encrypted];

    //Only bother to attempt this if it *is* ECB
    if(isECB)
    {
        /*
            You know that it's block based, so you can feed it a block of blocksize - 1 which will then fill in the last byte with the unknown starting byte.
            You can then feed it blocks of blocksize where the last character tries every possible value for that byte, and find which matches the original input
         */
        
        //Create the mutable data to store the output to
        NSMutableData* decryptedString = [[NSMutableData alloc] init];
        
        while(decryptedString.length < unknownStringLength)
        {
            //TODO: work out how to get the starting input data based on the number of characters found in the decrypted string basically just keep replacing the unknown characters with the known and shifting to the left.
            //Need to continue to make the string
            
            /*
             
             The STARTING INPUT DATA / THE BIT TO CHECK AGAINST
             - this just needs to be the current block size - the current block ordinal. When the block is > 0 then this can actually be a blank data array, as the rest will be filled with the unknown string, and then its blocks can be iterated over in order until we get to the end.
             
             The DICTIONARY DATA / DATA TO CHECK FOR MATCHING
             - This is more complex - this needs to be the blank string at first, and for each iteration for the first <blocksize> iterations this needs to be filled in with the blank data - (the number found + 1). After the first block, this changes to move through the block of decrypted string of length (blocksize - 1) and the last character can be tested.
             
             */
            
            //Get the current block ordinal
            NSInteger currentBlockOrdinal = floor(decryptedString.length / blockLength);
            NSInteger currentBlockIndex = decryptedString.length % blockLength;
            NSInteger padding = (blockLength - 1) - currentBlockIndex;
            
            //Create a var for the starting input data
            NSData* startingInputDataEncrypted = nil;

            //Create the starting data
            NSMutableData* startingInputData = [[NSMutableData alloc] init];
            if(padding != 0)
            {
                startingInputData = [[[NSData alloc] init] addKnownCharacterPaddingToBlockSize:padding paddingCharacter:'A'].mutableCopy;
            }
            
            //Create the original input
            startingInputDataEncrypted = [[startingInputData AES128UnknownConsistentKeyEncryption] splitDataIntoBlocks:blockLength][currentBlockOrdinal];
            
            
            
            //Iterate over the characters to test which matches the expected data
            for(unsigned char c = 0; c < UCHAR_MAX; c++)
            {
                //Create the output data holder
                NSMutableData* outputData = [NSMutableData new];
                
                if(currentBlockOrdinal == 0)
                {
                    if(padding > 0)
                    {
                        outputData = [[[[NSMutableData alloc] init] addKnownCharacterPaddingToBlockSize:padding paddingCharacter:'A'] mutableCopy];
                    }
                    [outputData appendData:decryptedString];
                    
                    //Pad with character at end, and split into blocks. Take the block of current block ordinal
                    outputData = (NSMutableData*)[[[outputData addKnownCharacterPaddingToBlockSize:blockLength paddingCharacter:c] AES128UnknownConsistentKeyEncryption] splitDataIntoBlocks:blockLength][currentBlockOrdinal];
                }
                else
                {
                    //TODO: work out how to do for blocks after block zero
                    [outputData appendData:[decryptedString subdataWithRange:NSMakeRange(decryptedString.length - 15, 15)]];
                    [outputData appendBytes:&c length:1];
                    outputData = (NSMutableData*)[[outputData AES128UnknownConsistentKeyEncryption] splitDataIntoBlocks:blockLength][0];
                }
                
                //Check if equal to starting output data
                if([outputData isEqualToData:startingInputDataEncrypted])
                {
                    [decryptedString appendBytes:&c length:1];
                    break;
                }
            }
        }
        
        NSLog(@"\nDECRYPTED STRING:\n%@\n", [[NSString alloc] initWithData:decryptedString encoding:NSASCIIStringEncoding]);
    }
}

-(void)setTwoChallengeThirteen
{
    /*
     This method will only work for a known ordering of the profile such that it has role= as the last part. This is why the ordered keys mutable dictionary class exists - such that the dictionary keys will definitely be in the same order as inserted. We can then make sure that the role= is aligned with the end of a data block, and replace this with an alternative ending block to change the user role of length 16 (when the padding is added).
     */
    
    //Create a profile where the last block will contain just 'user' (the previous will contain the role= part). This means the length of the email address needs to be 14 characters as the string without email is 22 characters and it needs to overlap the block by 4 characters (22 + 14 will take it up to 36, 4 characters larger than the second block).
    NSData* profileToModify = [self profileForEmail:@"john@gmail.com"];
    
    //Create a profile where the second block will contain only the text 'admin' with filler at the end. Since the email starts to come in at the 7th byte position, this means filling with blank up to 16 (adding 10 blank spaces). After 9 blank spaces add the text 'admin'. Then after this add the filler character from here until the end (11).
    NSMutableData* emailAddressData = [[NSMutableData alloc] init];
    char paddingChar = '\x01';
    for(int x = 0; x < 10; x++)
    {
        [emailAddressData appendBytes:&paddingChar length:1];
    }
    [emailAddressData appendData:[@"admin" dataUsingEncoding:NSASCIIStringEncoding]];
    [emailAddressData addPKCS12PaddingToBlockSize:16];
    NSData* profileToPinchFrom = [self profileForEmail:[[NSString alloc] initWithData:emailAddressData encoding:NSASCIIStringEncoding]];
    
    //Remove the last block from the profile to modify
    NSMutableData* profileToModifyMutable = [profileToModify subdataWithRange:NSMakeRange(0, 32)].mutableCopy;
    
    //Append the second block from the profile to pinch from
    [profileToModifyMutable appendData:[profileToPinchFrom splitDataIntoBlocks:16][1]];
    
    //The profile to modify mutable should now be an admin role - test this using the decryption method.
    NSDictionary<NSString*,NSString*>* decryptedProfile = [self decryptUserProfile:profileToModifyMutable];
    NSString* role = [decryptedProfile objectForKey:@"role"];
    BOOL isAdmin = [role isEqualToString:@"admin"];
    NSAssert(isAdmin, @"The modified role should now be admin");
}

-(void)setTwoChallengeFourteen
{
    //This is almost a repeat of 12, but with an unknown length of random bytes at the start. Discover the length of the bytes and always offset for it.
    
    //Discover the block size of the cypher by feeding it one byte at a time.
    const unsigned char testChar = '\x26';
    NSInteger sizeOfRandomBytesAtStart = 0;
    NSData* outputData = nil;
    NSInteger blockSize = 0;
    NSInteger unknownStringLength = 0;
    
    //I'm only testing block sizes from 4 to 128 - I'm not sure if that's good enough for real life testing(?)
    for(int testedBlocksize = 4; testedBlocksize < 128; testedBlocksize++)
    {
        BOOL foundBlockSize = FALSE;
        
        NSMutableData* data = [[NSMutableData alloc] init];
        
        //Testing up to blocksize * 3 guarantees that we hit 2 consecutive blocks even if the size of the random bytes is blocksize - 1
        for(int x = 1; x < (testedBlocksize * 3); x++)
        {
            //Append another byte to the mutable data.
            [data appendBytes:&testChar length:1];
            
            //Get the encrypted data
            NSData* output = [data AES128UnknownConsistentKeyEncryptionWithRandomBytesAtStart];
            
            //Split into blocks which would be of the current block length
            NSArray<NSData*>* blocks = [output splitDataIntoBlocks:testedBlocksize];
            
            for(int y = 0; y < (blocks.count - 1); y++)
            {
                NSData* blockOne = blocks[y];
                NSData* blockTwo = blocks[y+1];
                if([blockOne isEqualToData:blockTwo])
                {
                    //Calculate the bytes of random data.
                    NSInteger blockStart = y * testedBlocksize;
                    NSInteger appendedCharactersBeforeMatchingBlocks = x - (testedBlocksize * 2);
                    NSInteger randomBytesSize = blockStart - appendedCharactersBeforeMatchingBlocks;
                    sizeOfRandomBytesAtStart = randomBytesSize;
                    
                    //Set the output data
                    outputData = output;
                    
                    //Set the blocksize
                    blockSize = testedBlocksize;
                    
                    //Set the unknown string length
                    unknownStringLength = output.length - data.length - sizeOfRandomBytesAtStart;
                    
                    //Set found block size to true to break free from all nested loops
                    foundBlockSize = TRUE;
                    
                    //Break out of the loop
                    break;
                }
            }
            if(foundBlockSize) break;
        }
        if(foundBlockSize) break;
    }
    
    
    //Check if the encryption was ECB
    BOOL isECB = [outputData isPotentiallyECB128Encrypted];
    
    //Only bother to attempt this if it *is* ECB
    if(isECB)
    {
        //This is almost exactly the same as 12 at this point - the only difference is that it needs to have a constant amount of padding to bring it up to the nearest complete block after the random data at the start, and a starting block offset to effectively ignore the blocks with the random bytes.
        
        //Work out starting padding and block offset.
        NSInteger startingPaddingBytes = blockSize - (sizeOfRandomBytesAtStart % blockSize);
        NSInteger startingBlockOffset = (sizeOfRandomBytesAtStart + startingPaddingBytes) / blockSize;
        
        /*
         You know that it's block based, so you can feed it a block of blocksize - 1 which will then fill in the last byte with the unknown starting byte.
         You can then feed it blocks of blocksize where the last character tries every possible value for that byte, and find which matches the original input
         */
        
        //Create the mutable data to store the output to
        NSMutableData* decryptedString = [[NSMutableData alloc] init];
        
        while(decryptedString.length < unknownStringLength)
        {
            
            //Get the current block ordinal
            NSInteger currentBlockOrdinal = floor(decryptedString.length / blockSize) + startingBlockOffset;
            NSInteger currentBlockIndex = decryptedString.length % blockSize;
            NSInteger padding = ((blockSize - 1) - currentBlockIndex) + startingPaddingBytes;
            
            //Create a var for the starting input data
            NSData* startingInputDataEncrypted = nil;
            
            //Create the starting data
            NSMutableData* startingInputData = [[NSMutableData alloc] init];
            if(padding != 0)
            {
                startingInputData = [[[NSData alloc] init] addKnownCharacterPaddingToBlockSize:padding paddingCharacter:'A'].mutableCopy;
            }
            
            //Create the original input
            startingInputDataEncrypted = [[startingInputData AES128UnknownConsistentKeyEncryptionWithRandomBytesAtStart] splitDataIntoBlocks:blockSize][currentBlockOrdinal];
            
            
            
            //Iterate over the characters to test which matches the expected data
            for(unsigned char c = 0; c < UCHAR_MAX; c++)
            {
                //Create the output data holder
                NSMutableData* outputData = [NSMutableData new];
                
                if(currentBlockOrdinal == startingBlockOffset)
                {
                    if(padding > 0)
                    {
                        outputData = [[[[NSMutableData alloc] init] addKnownCharacterPaddingToBlockSize:padding paddingCharacter:'A'] mutableCopy];
                    }
                    [outputData appendData:decryptedString];
                    
                    //Pad with character at end, and split into blocks. Take the block of current block ordinal
                    outputData = (NSMutableData*)[[[outputData addKnownCharacterPaddingToBlockSize:blockSize paddingCharacter:c] AES128UnknownConsistentKeyEncryptionWithRandomBytesAtStart] splitDataIntoBlocks:blockSize][currentBlockOrdinal];
                }
                else
                {
                    //TODO: work out how to do for blocks after block zero
                    [outputData appendData:[[[NSData alloc] init] addKnownCharacterPaddingToBlockSize:startingPaddingBytes paddingCharacter:c]];
                    [outputData appendData:[decryptedString subdataWithRange:NSMakeRange(decryptedString.length - 15, 15)]];
                    [outputData appendBytes:&c length:1];
                    outputData = (NSMutableData*)[[outputData AES128UnknownConsistentKeyEncryptionWithRandomBytesAtStart] splitDataIntoBlocks:blockSize][startingBlockOffset];
                }
                
                //Check if equal to starting output data
                if([outputData isEqualToData:startingInputDataEncrypted])
                {
                    [decryptedString appendBytes:&c length:1];
                    break;
                }
            }
        }
        
        NSLog(@"\nDECRYPTED STRING:\n%@\n", [[NSString alloc] initWithData:decryptedString encoding:NSASCIIStringEncoding]);

    }
}

-(void)setTwoChallengeFifteen
{
    //Add and remove valid PKCS padding
    
    //Add invalid padding
    NSData* invalidPadding = [[@"ICE ICE BABY" dataUsingEncoding:NSASCIIStringEncoding] addKnownCharacterPaddingToBlockSize:16 paddingCharacter:'\x05'];
    NSError* error = nil;
    NSData* unpaddedData = [invalidPadding stripPKCS12PaddingWithBlockSize:16 error:&error];
    NSAssert(error != nil && unpaddedData == nil, @"Should give back error on invalid padding");
    
    //Add valid padding
    NSData* validPadding = [[@"ICE ICE BABY" dataUsingEncoding:NSASCIIStringEncoding] addPKCS12PaddingToBlockSize:16];
    error = nil;
    NSData* unpaddedValidData = [validPadding stripPKCS12PaddingWithBlockSize:16 error:&error];
    NSAssert(error == nil && unpaddedValidData != nil && [[[NSString alloc] initWithData:unpaddedValidData encoding:NSASCIIStringEncoding] isEqualToString:@"ICE ICE BABY"], @"Should give back unpadded data on valid padding");
}

-(void)setTwoChallengeSixteen
{
    //This challenge is the hardest yet, as you'd expect. It's CBC bitflipping. It relies on the idea that corrupting a previous segment in CBC causes the next to be incorrectly XORed against it when the reversal is done.
    
    //1. Confirm that it is not possible to just string inject.
    
    //Do an initial check to confirm that you can't just inject as a string.
    NSString* comment = @";admin=true;";
    NSData* data = [self createCommentEncrypted:[comment dataUsingEncoding:NSASCIIStringEncoding]];
    BOOL admin = [self commentWasMadeByAdmin:data];
    NSAssert(!admin, @"It should not be possible to create an admin by simply injecting the value in. It should be done by breaking the encryption.");
    
    //2.
    
    //This is the output block you want to produce.
    NSData* adminEntryBlock = [@"0000;admin=true;" dataUsingEncoding:NSASCIIStringEncoding];
    
    //Create a known 16 bytes of just the letter 'O'
    NSData* known16Bytes = [[[NSData alloc] init] addKnownCharacterPaddingToBlockSize:16 paddingCharacter:'O'];

    //Create a known 16 bytes of just the letter 'L'
    NSData* otherKnown16Bytes = [[[NSData alloc] init] addKnownCharacterPaddingToBlockSize:16 paddingCharacter:'L'];
    
    //Get an output from the oracle function and take the second block - to find out what the known 16 bytes is after encryption
    NSData* originalOutput = [[self createCommentEncrypted:known16Bytes] splitDataIntoBlocks:16][2];
    
    //XOR the admin block first against the other known 16 bytes
    NSData* firstXoredAdminEntryBlock = [adminEntryBlock symmetricLengthXorWithData:otherKnown16Bytes];
    
    //XOR the already XORed admin entry block against the known 16 bytes. This has now been done twice - the first time against the block which will be the replacement, the second against the known XORing value. The known XORing value will produce an output of the first XORed value when it is encrypted, and when decrypted with the block replaced, it will output the admin entry block itself.
    NSData* xoredAdminEntryBlock = [firstXoredAdminEntryBlock symmetricLengthXorWithData:originalOutput];
    
    //Create the second input to the oracle
    NSMutableData* secondInput = [[NSMutableData alloc] initWithData:known16Bytes];
    [secondInput appendData:xoredAdminEntryBlock];
    
    //Get the data blocks from the second input
    NSArray<NSData*>* commentDataBlocks = [[self createCommentEncrypted:secondInput] splitDataIntoBlocks:16];
    
    //Alter the data to replace the third block
    NSMutableData* alteredCommentData = [[NSMutableData alloc] init];
    for(int x = 0; x < commentDataBlocks.count; x++)
    {
        if(x == 2)
        {
            [alteredCommentData appendData:otherKnown16Bytes];
        }
        else
        {
            [alteredCommentData appendData:commentDataBlocks[x]];
        }
    }
    
    //Check whether the outputted user is now indeed, an admin
    BOOL isAdmin = [self commentWasMadeByAdmin:alteredCommentData];
    
    NSAssert(isAdmin, @"The altered ciphertext should have produced an admin user");
}





#pragma mark - Helpers


#pragma mark 2:16 Create comment / check admin status of commenter
-(void)generateCBCKey
{
    if(!randomCBCKey)
    {
        randomCBCKey = [NSData generateRandomBytesOfLength:16];
    }
    
    if(!initialisationVector)
    {
        initialisationVector = [[[NSData alloc] init] addKnownCharacterPaddingToBlockSize:16 paddingCharacter:'\x00'];
    }
}

-(NSData*)createCommentEncrypted:(NSData*)commentData
{
    [self generateCBCKey];
    NSData* prependString = [@"comment1=cooking%20MCs;userdata=" dataUsingEncoding:NSASCIIStringEncoding];
    NSData* appendString = [@";comment2=%20like%20a%20pound%20of%20bacon" dataUsingEncoding:NSASCIIStringEncoding];
    
    NSMutableData* fullCommentData = [[NSMutableData alloc] init];
    [fullCommentData appendData:prependString];
    const char* characters = commentData.bytes;
    for(int x = 0; x < commentData.length; x++)
    {
        const char character = characters[x];
        if(character != ';' && character != '=')
        {
            [fullCommentData appendBytes:&character length:1];
        }
        else
        {
            NSLog(@"bad char found");
        }
    }
    [fullCommentData appendData:appendString];

    return [fullCommentData AES128CBCEncryptWithKey:[[NSString alloc] initWithData:randomCBCKey encoding:NSASCIIStringEncoding] initialisationVector:initialisationVector];
}

-(BOOL)commentWasMadeByAdmin:(NSData*)encryptedCommentData
{
    NSData* decryptedData = [encryptedCommentData AES128CBCDecryptWithKey:[[NSString alloc] initWithData:randomCBCKey encoding:NSASCIIStringEncoding] initialisationVector:initialisationVector];
    NSString* decryptedString = [[NSString alloc] initWithData:decryptedData encoding:NSASCIIStringEncoding];
    BOOL isAdmin = FALSE;
    if([decryptedString containsString:@";admin=true;"])
    {
        isAdmin = TRUE;
    }
    return isAdmin;
}




#pragma mark 2:13 Profile Generation Etc.
-(NSData*)profileForEmail:(NSString*)emailAddress
{
    emailAddress = [[emailAddress stringByReplacingOccurrencesOfString:@"&" withString:@""] stringByReplacingOccurrencesOfString:@"=" withString:@""];
    OrderedKeysMutableDictionary* dictionary = [[OrderedKeysMutableDictionary alloc] init];
    [dictionary setObject:emailAddress forKey:@"email"];
    [dictionary setObject:[NSString stringWithFormat:@"%li", userIdCount++] forKey:@"uid"];
    [dictionary setObject:@"user" forKey:@"role"];
    return [self encryptUserProfile:[NSString keyValuesStringFromDictionary:dictionary]];
}

-(void)generateRandomEncryptionKey
{
    if(!randomEncryptionKey)
    {
        randomEncryptionKey = [NSData generateRandomBytesOfLength:16];
    }
}

-(NSData*)encryptUserProfile:(NSString*)userProfile
{
    [self generateRandomEncryptionKey];
    return [[[userProfile dataUsingEncoding:NSASCIIStringEncoding] addPKCS12PaddingToBlockSize:16] AES128ECBEncryptWithKey:[[NSString alloc] initWithData:randomEncryptionKey encoding:NSASCIIStringEncoding]];
}

-(NSDictionary<NSString*,NSString*>*)decryptUserProfile:(NSData*)userProfileData
{
    NSData* data = [userProfileData AES128ECBDecryptWithKey:[[NSString alloc] initWithData:randomEncryptionKey encoding:NSASCIIStringEncoding]];
    NSString* decryptedString = [[NSString alloc] initWithData:[data stripPKCS12PaddingWithBlockSize:16 error:nil] encoding:NSASCIIStringEncoding];
    return [decryptedString parseKeyValueStringIntoDictionary];
}

@end
