//
//  NSData+XOR.h
//  CryptoPalsChallenges
//
//  Created by John Kartupelis on 11/08/2016.
//  Copyright © 2016 John Kartupelis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (XOR)

//XOR
-(NSData *)symmetricLengthXorWithData:(NSData *)data;
-(NSData *)singleCharacterXorCharacter:(const unsigned char)byte;
-(NSData *)repeatingKeyXorwithKey:(NSData*)key;

@end
