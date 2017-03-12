//
//  EasySlideScrollView.m
//  Shopper
//
//  Created by Ninan Thomas on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EasySlideScrollView.h"

@implementation EasySlideScrollView


- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    NSLog(@"touchesShouldCancel call\n");
    return NO;
}

@end
