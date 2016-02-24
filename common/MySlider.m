//
//  MySlider.m
//  Shopper
//
//  Created by Ninan Thomas on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MySlider.h"

@implementation MySlider

- (CGRect)minimumValueImageRectForBounds:(CGRect)bounds
{
    return CGRectMake(8, 9.7, 16, 12);
}

- (CGRect)maximumValueImageRectForBounds:(CGRect)bounds
{
    return CGRectMake(73, 10.3, 18, 9);
}

@end
