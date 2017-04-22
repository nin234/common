//
//  MasterListNames.h
//  EasyGrocList
//
//  Created by Ninan Thomas on 4/3/13.
//  Copyright (c) 2013 Ninan Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface MasterListNames : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic) long long share_id;
@property (nonatomic, retain) NSString *share_name;


@end
