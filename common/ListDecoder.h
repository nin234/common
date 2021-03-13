//
//  MessageDecoder.h
//  EasyGrocList
//
//  Created by Ninan Thomas on 9/27/15.
//  Copyright (c) 2015 Ninan Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "Constants.h"
#import <sharing/MessageDecoder.h>

@interface ListDecoder : MessageDecoder
{

}

-(bool) decodeMessage:(char*)buffer msglen:(ssize_t)mlen;

-(instancetype) init;


@end
