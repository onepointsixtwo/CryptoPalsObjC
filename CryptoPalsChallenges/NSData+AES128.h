//
//  NSData+AES128.h
//  CryptoPalsChallenges
//
//  Created by John Kartupelis on 11/08/2016.
//  Copyright © 2016 John Kartupelis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (AES128)

//AES128 ECB
-(NSData *)AES128ECBEncryptWithKey:(NSString *)key;
-(NSData *)AES128ECBDecryptWithKey:(NSString *)key;
-(BOOL)isPotentiallyECB128Encrypted;

//AES128 CBC
-(NSData *)AES128CBCEncryptWithKey:(NSString *)key initialisationVector:(NSData*)initialisationVector;
-(NSData *)AES128CBCDecryptWithKey:(NSString *)key initialisationVector:(NSData*)initialisationVector;

//AES128 Extras
-(NSData*)AES128RandomisedEncryption;
-(NSData*)AES128UnknownConsistentKeyEncryption;
-(NSData*)AES128UnknownConsistentKeyEncryptionWithRandomBytesAtStart;

@end
