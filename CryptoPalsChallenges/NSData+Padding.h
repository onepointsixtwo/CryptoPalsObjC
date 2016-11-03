//
//  NSData+Padding.h
//  CryptoPalsChallenges
//
//  Created by John Kartupelis on 11/08/2016.
//  Copyright © 2016 John Kartupelis. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN const NSInteger kInvalidPadding;

@interface NSData (Padding)

//General padding
-(NSData *)addKnownCharacterPaddingToBlockSize:(NSInteger)blockSize paddingCharacter:(char)paddingCharacter;

//PKCS12 Padding
-(NSData *)addPKCS12PaddingToBlockSize:(NSInteger)blockSize;
-(NSData *)stripPKCS12PaddingWithBlockSize:(NSInteger)blockSize error:(NSError**)error;

@end
