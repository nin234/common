//
//  OpenHousesDecoder.m
//  Shopper
//
//  Created by Ninan Thomas on 2/17/16.
//
//

#import "CommonDecoder.h"

@implementation CommonDecoder

-(instancetype) init
{
    self = [super init];
    return self;
}


-(bool) decodeMessage:(char*)buffer msglen:(ssize_t)mlen
{
    if ([super decodeMessage:buffer msglen:mlen])
    {
        return true;
    }
    
    bool bRet = true;
    
    return bRet;
    
}

@end
