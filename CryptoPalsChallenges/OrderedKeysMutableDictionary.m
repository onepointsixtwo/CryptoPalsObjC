//
//  OrderedKeysMutableDictionary.m
//  CryptoPalsChallenges
//
//  Created by John Kartupelis on 09/08/2016.
//  Copyright © 2016 John Kartupelis. All rights reserved.
//

#import "OrderedKeysMutableDictionary.h"

@interface OrderedKeysMutableDictionary ()

@property (strong, nonatomic) NSMutableDictionary* innerDictionary;
@property (strong, nonatomic) NSMutableArray* keysArray;

@end

@implementation OrderedKeysMutableDictionary

#pragma mark - Overrides
-(id)objectForKey:(id)aKey
{
    return [self.innerDictionary objectForKey:aKey];
}

-(void)setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    if(anObject)
    {
        [self addToKeysArray:aKey];
    }
    else
    {
        [self removeMatchingFromKeysArray:aKey];
    }
    [self.innerDictionary setObject:anObject forKey:aKey];
}

-(void)removeObjectForKey:(id)aKey
{
    [self removeMatchingFromKeysArray:aKey];
    [self.innerDictionary removeObjectForKey:aKey];
}

-(id)copyWithZone:(NSZone *)zone
{
    OrderedKeysMutableDictionary* dictionary = [super copyWithZone:zone];
    if(dictionary)
    {
        dictionary.keysArray = self.keysArray.copy;
        dictionary.innerDictionary = self.innerDictionary.copy;
    }
    return dictionary;
}

-(id)mutableCopyWithZone:(NSZone *)zone
{
    OrderedKeysMutableDictionary* dictionary = [super copyWithZone:zone];
    if(dictionary)
    {
        dictionary.keysArray = self.keysArray.copy;
        dictionary.innerDictionary = self.innerDictionary.copy;
    }
    return dictionary;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.keysArray forKey:@"keys"];
    [aCoder encodeObject:self.innerDictionary forKey:@"dict"];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        self.keysArray = [aDecoder decodeObjectForKey:@"keys"];
        self.innerDictionary = [aDecoder decodeObjectForKey:@"dict"];
    }
    return self;
}

-(NSArray *)allKeys
{
    return self.keysArray;
}

-(NSString *)description
{
    return self.innerDictionary.description;
}

#pragma mark - Key helpers
-(void)removeMatchingFromKeysArray:(id)key
{
    id objMatching = nil;
    for(id object in self.keysArray)
    {
        if([object isEqual:objMatching])
        {
            objMatching = object;
            break;
        }
    }
    
    if(objMatching)
    {
        [self.keysArray removeObject:objMatching];
    }
}

-(void)addToKeysArray:(id)key
{
    [self removeMatchingFromKeysArray:key];
    [[self keysArray] addObject:key];
}

#pragma mark - Acessors
-(NSMutableArray *)keysArray
{
    if(!_keysArray)
    {
        _keysArray = [[NSMutableArray alloc] init];
    }
    return _keysArray;
}

-(NSMutableDictionary *)innerDictionary
{
    if(!_innerDictionary)
    {
        _innerDictionary = [[NSMutableDictionary alloc] init];
    }
    return _innerDictionary;
}

@end
