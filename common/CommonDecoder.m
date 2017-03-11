//
//  OpenHousesDecoder.m
//  Shopper
//
//  Created by Ninan Thomas on 2/17/16.
//
//

#import "CommonDecoder.h"
#import "CommonShareMgr.h"

@implementation CommonDecoder



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
   
    int namelen;
    memcpy(buffer + 2*sizeof(int), &namelen, sizeof(int));
    NSString *list = [NSString stringWithCString:(buffer + 4*sizeof(int) + namelen + sizeof (long long)) encoding:NSASCIIStringEncoding];
    
    CommonShareMgr *pCmnShrMgr = (CommonShareMgr *)self.pShrMgr;
    
    [pCmnShrMgr processItem:list];
    return true;
}

@end
