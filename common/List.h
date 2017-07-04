//
//  List.h
//  EasyGrocList
//
//  Created by Ninan Thomas on 5/19/13.
//  Copyright (c) 2013 Ninan Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface List : NSManagedObject

@property long long rowno;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * item;
@property (nonatomic, retain) NSDate   *date;
@property BOOL hidden;
@property (nonatomic) long long share_id;


@end
