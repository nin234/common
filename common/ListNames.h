//
//  ListNames.h
//  EasyGrocList
//
//  Created by Ninan Thomas on 5/19/13.
//  Copyright (c) 2013 Ninan Thomas. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface ListNames : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate   *date;
@property (nonatomic, retain) NSString * picurl;
@property BOOL current;

@end
