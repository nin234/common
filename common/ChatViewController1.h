//
//  ChatViewController1.h
//  common
//
//  Created by Ninan Thomas on 3/24/18.
//  Copyright © 2018 Sinacama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sharing/FriendDetails.h>
#import "AlbumContentsTableViewCell.h"
#import "PhotoDisplayViewController.h"

@interface ChatViewController1 : UITableViewController<AlbumContentsTableViewCellSelectionDelegate, PhotoDisplayViewControllerDelegate>
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

@property (nonatomic, retain) FriendDetails *to;
-(void) scrollToBottom;
//MARK: Properties

@property (nonatomic, assign) IBOutlet AlbumContentsTableViewCell *tmpCell;
-(void) deletedPhotoAtIndx:(NSUInteger)nIndx;

@end
