//
//  SmartShareMgr.m
//  smartmsg
//
//  Created by Ninan Thomas on 2/19/18.
//  Copyright © 2018 Nshare. All rights reserved.
//

#import "SmartShareMgr.h"
#import "CommonTranslator.h"
#import "ChatsDecoder.h"

@implementation SmartShareMgr


- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.pTransl = [[CommonTranslator alloc] init];
        ChatsDecoder* pChatsDcd = [[ChatsDecoder alloc] init];
        pChatsDcd.pShrMgr = self;
        self.pDecoder = pChatsDcd;
        picSoFar = 0;
    }
    return self;
}

@end
