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


-(void) getItems
{
    char *pMsgToSend = NULL;
    int len =0;
    pMsgToSend = [self.pTransl getItems:self.share_id msgLen:&len];
    [self putMsgInQ:pMsgToSend msgLen:len];
    return;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.pTransl = [[CommonTranslator alloc] init];
        self.pDecoder = [[CommonDecoder alloc] init];
    }
    return self;
}


@end
