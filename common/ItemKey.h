//
//  ItemKey.h
//  common
//
//  Created by Ninan Thomas on 7/4/17.
//  Copyright © 2017 Sinacama. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ItemKey : NSObject

@property (nonatomic, retain) NSString *name;
@property NSUInteger share_id;


- (id)copyWithZone:(NSZone *)zone;
- (BOOL)isEqual:(id)anObject;
- (NSUInteger)hash;

@end
