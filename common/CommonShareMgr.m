//
//  OpenHousesShareMgr.m
//  Shopper
//
//  Created by Ninan Thomas on 2/17/16.
//
//

#import "CommonShareMgr.h"
#import "CommonTranslator.h"
#import "CommonDecoder.h"

@implementation CommonShareMgr



- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.pTransl = [[CommonTranslator alloc] init];
        CommonDecoder* pCommonDcd = [[CommonDecoder alloc] init];
        pCommonDcd.pShrMgr = self;
        self.pDecoder = pCommonDcd;
    }
    return self;
}


@end
