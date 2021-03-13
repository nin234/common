//
//  ShareMgr.m
//  EasyGrocList
//
//  Created by Ninan Thomas on 9/22/15.
//  Copyright (c) 2015 Ninan Thomas. All rights reserved.
//

#import "ListShareMgr.h"
#import "ListTranslator.h"
#import "ListDecoder.h"



@implementation ListShareMgr



-(void) storeTemplItemInCloud:(NSString *)name itemsDic:(NSMutableDictionary*) itmsMp
{
    
    NSString *storeLst = [self.pTransl getTemplItemStr:itmsMp];
    [self archiveItem:storeLst itemName:name];
    return;
}


- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.pTransl = [[ListTranslator alloc] init];
        ListDecoder* pDcd = [[ListDecoder alloc] init];
        pDcd.pShrMgr = self;
        self.pDecoder = pDcd;
    }
    return self;
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    return;
}

@end
