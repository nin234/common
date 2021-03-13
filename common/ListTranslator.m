//
//  MessageTranslator.m
//  EasyGrocList
//
//  Created by Ninan Thomas on 9/24/15.
//  Copyright (c) 2015 Ninan Thomas. All rights reserved.
//

#import "ListTranslator.h"
#include "Constants.h"


@implementation ListTranslator





-(NSString *) getTemplItemStr:(NSMutableDictionary*) itmsMp
{
    if (![itmsMp count])
        return NULL;
    
    NSString *storeLst = [[NSString alloc] init];
    
    
    for (NSNumber *rowno in itmsMp)
    {
        NSString *item = [itmsMp objectForKey:rowno];
        storeLst = [storeLst stringByAppendingString:[rowno stringValue]];
        storeLst = [storeLst stringByAppendingString:@":"];
        storeLst = [storeLst stringByAppendingString:item];
        storeLst = [storeLst stringByAppendingString:@"]:;"];
        
    }
    return storeLst;
}


@end
