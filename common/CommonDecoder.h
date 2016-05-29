//
//  OpenHousesDecoder.h
//  Shopper
//
//  Created by Ninan Thomas on 2/17/16.
//
//

#import <Foundation/Foundation.h>
#include "Constants.h"
#import <sharing/MessageDecoder.h>


@interface CommonDecoder : MessageDecoder


-(bool) decodeMessage:(char*)buffer msglen:(ssize_t)mlen;

-(instancetype) init;



@end
