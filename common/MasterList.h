//
//  MasterList.h
//  EasyGrocList
//
//  Created by Ninan Thomas on 3/31/13.
//  Copyright (c) 2013 Ninan Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface MasterList : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * item;
@property long long rowno;

@end
