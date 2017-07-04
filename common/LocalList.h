//
//  LocalList.h
//  common
//
//  Created by Ninan Thomas on 5/22/17.
//  Copyright © 2017 Sinacama. All rights reserved.
//

#import <Foundation/Foundation.h>

@class List;

@interface LocalList : NSObject

@property long long rowno;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * item;
@property (nonatomic, retain) NSDate   *date;
@property BOOL hidden;
@property (nonatomic) long long share_id;

-(id) copyFromList:(List *)list;
-(instancetype) initFromList:(List *)list;

@end
