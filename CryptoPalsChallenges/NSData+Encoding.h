//
//  NSData+Encoding.h
//  CryptoPalsChallenges
//
//  Created by John Kartupelis on 04/08/2016.
//  Copyright © 2016 John Kartupelis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Encoding)

//Base64
+(NSData *)dataWithBase64EncodedString:(NSString *)string;
-(instancetype)initWithBase64EncodedString:(NSString*)string;
-(NSString *)base64EncodedString;

//Hex
+(NSData*)dataWithHexEncodedString:(NSString*)hexString;
-(instancetype)initWithHexEncodedString:(NSString*)hexString;
-(NSString*)hexEncodedString;


@end
