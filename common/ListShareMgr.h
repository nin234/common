//
//  ShareMgr.h
//  EasyGrocList
//
//  Created by Ninan Thomas on 9/22/15.
//  Copyright (c) 2015 Ninan Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sharing/ShareMgr.h>

#include "Constants.h"


@interface ListShareMgr : ShareMgr
{
  
}


-(void) storeTemplItemInCloud:(NSString *)name itemsDic:(NSMutableDictionary*) itmsMp;


- (instancetype)init;

@end
