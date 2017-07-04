//
//  ItemKey.m
//  common
//
//  Created by Ninan Thomas on 7/4/17.

//  Copyright © 2017 Sinacama. All rights reserved.
//

#import "ItemKey.h"

@implementation ItemKey

@synthesize share_id;
@synthesize name;

- (id)copyWithZone:(NSZone *)zone
{
    ItemKey *itk = [[ItemKey allocWithZone:zone] init];
    itk.name = [NSString stringWithString:self.name];
    itk.share_id = self.share_id;
    
    return itk;
}



- (BOOL)isEqual:(id)anObject
{
    ItemKey *itk = (ItemKey *) anObject;
    if ([itk.name isEqualToString:self.name] && itk.share_id == self.share_id)
        return YES;
    return NO;
}

- (NSUInteger)hash
{
   NSUInteger hash = [self.name hash];
    hash ^= share_id;
    return hash;
}

@end
