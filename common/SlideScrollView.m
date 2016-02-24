//
//  SlideScrollView.m
//  Shopper
//
//  Created by Ninan Thomas on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SlideScrollView.h"

@implementation SlideScrollView


- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    NSLog(@"touchesShouldCancel call\n");
    return NO;
}

@end
