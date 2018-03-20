//
//  ChatsDecoder.h
//  common
//
//  Created by Ninan Thomas on 3/19/18.
//  Copyright © 2018 Sinacama. All rights reserved.
//

#import <sharing/MessageDecoder.h>

@interface ChatsDecoder : MessageDecoder

-(bool) decodeMessage:(char*)buffer msglen:(ssize_t)mlen;

-(instancetype) init;

@end
