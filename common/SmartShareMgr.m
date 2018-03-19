//
//  SmartShareMgr.m
//  smartmsg
//
//  Created by Ninan Thomas on 2/19/18.
//  Copyright © 2018 Nshare. All rights reserved.
//

#import "SmartShareMgr.h"
#import "CommonTranslator.h"
#import "CommonDecoder.h"

@implementation SmartShareMgr

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.pTransl = [[CommonTranslator alloc] init];
        CommonDecoder* pCommonDcd = [[CommonDecoder alloc] init];
        pCommonDcd.pShrMgr = self;
        self.pDecoder = pCommonDcd;
        picSoFar = 0;
    }
    return self;
}

@end
