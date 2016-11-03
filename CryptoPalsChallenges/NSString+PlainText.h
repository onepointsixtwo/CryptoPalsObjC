//
//  NSString+PlainText.h
//  CryptoPalsChallenges
//
//  Created by John Kartupelis on 04/08/2016.
//  Copyright © 2016 John Kartupelis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (PlainText)

-(float)plainTextRating;
-(NSDictionary<NSString*, NSString*>*)parseKeyValueStringIntoDictionary;
+(NSString*)keyValuesStringFromDictionary:(NSDictionary<NSString*,NSString*>*)dictionary;

@end
