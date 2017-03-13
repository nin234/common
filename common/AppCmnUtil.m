//
//  AppCmnUtil.m
//  common
//
//  Created by Ninan Thomas on 3/12/17.
//  Copyright © 2017 Sinacama. All rights reserved.
//

#import "AppCmnUtil.h"

@implementation AppCmnUtil

@synthesize dataSync;
@synthesize navViewController ;
@synthesize mlistName;

-(instancetype) init
{
    self = [super init];
    if (self)
    {
        mlistName = [[NSString alloc] init];
        return self;
    }
    
    return nil;
    
}

@end
