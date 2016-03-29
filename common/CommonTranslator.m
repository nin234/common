//
//  OpenHousesTranslator.m
//  Shopper
//
//  Created by Rekha Thomas on 2/6/16.
//
//

#import "CommonTranslator.h"
#include "Constants.h"

@implementation CommonTranslator

-(char *) getItems:(long long)shareId msgLen:(int *)len
{
    return [self getItems:shareId msgLen:len msgId:GET_OPENHOUSES_ITEMS];
}


@end
