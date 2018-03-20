//
//  ChatsDecoder.m
//  common
//
//  Created by Ninan Thomas on 3/19/18.
//  Copyright © 2018 Sinacama. All rights reserved.
//

#import "ChatsDecoder.h"
#import "ChatsSharingDelegate.h"
#import <sharing/FriendDetails.h>

@implementation ChatsDecoder



-(instancetype) init
{
    self = [super init];
    return self;
}


-(bool) decodeMessage:(char*)buffer msglen:(ssize_t)mlen
{
    bool bRet = [super decodeMessage:buffer msglen:mlen];
    
    
    int msgTyp;
    memcpy(&msgTyp, buffer+sizeof(int), sizeof(int));
    
    switch (msgTyp)
    {
            
        case SHARE_ITEM_MSG:
        {
            bRet = [self processShareItemMessage:buffer msglen:mlen];
        }
            break;
            
            
            
        default:
            bRet = true;
            break;
    }
    
    
    
    return bRet;
    
}

-(bool) processShareItemMessage:(char *)buffer msglen:(ssize_t)mlen
{
    int namelen=0;
    memcpy(&namelen, buffer + 2*sizeof(int) + sizeof(long long), sizeof(int));
    NSString *list = [NSString stringWithCString:(buffer + 4*sizeof(int) + namelen + sizeof (long long)) encoding:NSASCIIStringEncoding];
    long long share_id =0;
    memcpy(&share_id, buffer +2*sizeof(int), sizeof(long long));
    FriendDetails *from = [[FriendDetails alloc] init];
    from.nickName = @"NA"; //Nick name not used in db insert
    from.name = [NSString stringWithFormat:@"%lld", share_id];
    ChatsSharingDelegate *pShrDelegate = [ChatsSharingDelegate sharedInstance];
    [pShrDelegate insertTextMsg:from Msg:list];
    
    return true;
}

@end
