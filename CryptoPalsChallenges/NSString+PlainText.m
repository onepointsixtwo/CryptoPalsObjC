//
//  NSString+PlainText.m
//  CryptoPalsChallenges
//
//  Created by John Kartupelis on 04/08/2016.
//  Copyright © 2016 John Kartupelis. All rights reserved.
//

#import "NSString+PlainText.h"
#import "OrderedKeysMutableDictionary.h"

static NSDictionary<NSString*, NSNumber*>* lookupTable;

@implementation NSString (PlainText)

#pragma mark - Plaintext rating
/*
    This algorithm will probably be improved over time. It gives a rating between 0 and 1 for the given plain text input for 'likelyhood of being correct string'.
 
    Uses a lookup in a frequency table.
 */
-(float)plainTextRating
{
    //Get the string length
    NSInteger stringLength = self.length;
    
    //Create the total rating var
    float totalRating = 0.f;
    
    if(stringLength > 0)
    {
        //iterate over the string and give rating based on character type
        for(int x = 0; x < stringLength; x++)
        {
            //Get the character, and convert to uppercase because lookup table is all uppercase
            NSString* characterStr = [self substringWithRange:NSMakeRange(x, 1)];
            characterStr = [characterStr uppercaseString];
            
            //Get the frequency
            NSNumber* num = [[self englishLanguageLetterFreqeuncyLookupTable] objectForKey:characterStr];
            if(num)
            {
                float value = num.floatValue;
                totalRating += value;
            }
            else
            {
                //Minus three for weird characters
                if(![self inRemainingNormalCharactersSet:[self characterAtIndex:x]])
                {
                    totalRating -= 10.f;
                }
            }
        }
    }
    
    return (totalRating / stringLength);
}

-(BOOL)inRemainingNormalCharactersSet:(unichar)character
{
    NSCharacterSet* characterSet = [NSCharacterSet characterSetWithCharactersInString:@"01234567890. "];
    return [characterSet characterIsMember:character];
}

-(NSDictionary<NSString*, NSNumber*>*)englishLanguageLetterFreqeuncyLookupTable
{
    if(!lookupTable)
    {
        lookupTable = @{@"E": @(12.02f), @"T": @(9.1f), @"A": @(8.12f), @"O": @(7.68f), @"I": @(7.31f), @"N": @(6.95f), @"S": @(6.28f), @"R": @(6.02f), @"H": @(5.92f), @"D": @(4.32f), @"L": @(3.98f), @"U": @(2.88f), @"C": @(2.71f), @"M": @(2.61f), @"F": @(2.30f), @"Y": @(2.11f), @"W": @(2.09f), @"G":@(2.03f), @"P": @(1.82f), @"B": @(1.49f), @"V": @(1.11f), @"K": @(0.69f), @"X": @(0.17f), @"Q": @(0.11f), @"J": @(0.1f), @"Z": @(0.07f)};
    }
    return lookupTable;
}


#pragma mark - Parsing Key Values
-(NSDictionary<NSString *,NSString *> *)parseKeyValueStringIntoDictionary
{
    //Create the return value dictionary
    OrderedKeysMutableDictionary* dictionary = [[OrderedKeysMutableDictionary alloc] init];
    
    //Split on separating character '&'
    NSArray* kvSets = [self componentsSeparatedByString:@"&"];
    for(NSString* kvSet in kvSets)
    {
        //Split on KV separator '='
        NSArray* kvSetArray = [kvSet componentsSeparatedByString:@"="];
        if(kvSetArray.count == 2)
        {
            NSString* key = [kvSetArray[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString* value = [kvSetArray[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [dictionary setObject:value forKey:key];
        }
    }
    
    return dictionary;
}

+(NSString *)keyValuesStringFromDictionary:(NSDictionary<NSString *,NSString *> *)dictionary
{
    NSMutableString* str = [[NSMutableString alloc] init];
    
    int loopNum = 0;
    for(NSString* key in dictionary.allKeys)
    {
        NSString* value = [dictionary valueForKey:key];
        
        if(loopNum > 0)
        {
            [str appendString:@"&"];
        }
        
        [str appendFormat:@"%@=%@", key, value];
        
        loopNum++;
    }
    
    return str;
}

@end
