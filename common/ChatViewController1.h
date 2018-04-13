//
//  ChatViewController1.h
//  common
//
//  Created by Ninan Thomas on 3/24/18.
//  Copyright © 2018 Sinacama. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ChatViewController1 : UITableViewController
{
    int nRows;
    NSArray *chatItems;
    NSArray *rowIndexes;
    CGFloat fromLeftInset;
    CGFloat fromRightInset;
    CGFloat toLeftInset;
    CGFloat toRightInset;
    CGFloat preferredMaxWidth;
    
}


@end
