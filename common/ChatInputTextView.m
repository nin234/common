//
//  ChatInputTextView.m
//  common
//
//  Created by Ninan Thomas on 4/9/18.
//  Copyright © 2018 Sinacama. All rights reserved.
//

#import "ChatInputTextView.h"

@implementation ChatInputTextView

@synthesize bShowKeyBoard;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!bShowKeyBoard)
    {
        [super touchesBegan:touches withEvent:event];
    }
    
   printf("got touches begin event in ChatInputTextView %d\n", bShowKeyBoard);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!bShowKeyBoard)
    {
        [super touchesMoved:touches withEvent:event];
    }
    NSLog(@"Got touches moved in ChatInputTextView %d", bShowKeyBoard);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!bShowKeyBoard)
    {
        [super touchesEnded:touches withEvent:event];
    }
    
     NSLog(@"Got touches ended in ChatInputTextView %d", bShowKeyBoard);
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!bShowKeyBoard)
    {
        [super touchesCancelled:touches withEvent:event];
    }
     NSLog(@"Got touches cancelled in ChatInputTextView %d", bShowKeyBoard);
}


@end
