//
//  LocalMasterList.h
//  EasyGrocList
//
//  Created by Ninan Thomas on 4/5/13.
//  Copyright (c) 2013 Ninan Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MasterList;

@interface LocalMasterList : NSObject
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * item;
@property long long rowno;
@property int startMonth;
@property int endMonth;
@property int inventory;
@property (nonatomic) long long share_id;

-(instancetype) initFromMasterList:(MasterList *)list;

@end
