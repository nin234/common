//
//  ChatsHeader.h
//  smartmsg
//
//  Created by Ninan Thomas on 3/2/18.
//  Copyright © 2018 Nshare. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@interface ChatsHeader : NSManagedObject

@property long long timestamp;
@property int type;
@property long long from;
@property long long to;
@property(nonatomic, retain) NSString* handle;
@property(nonatomic, retain) NSString* text;

@end
