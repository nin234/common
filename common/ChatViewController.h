//
//  ChatViewController.h
//  smartmsg
//
//  Created by Ninan Thomas on 2/28/18.
//  Copyright © 2018 Nshare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatsSharingDelegate.h"
#import <sharing/FriendDetails.h>

@interface ChatViewController : UICollectionViewController<UICollectionViewDelegateFlowLayout>

@property(nonatomic, retain) ChatsSharingDelegate *pShrDelegate;
@property (nonatomic, retain) FriendDetails *to;
@property (nonatomic, retain) UITextView *notes;

@end
