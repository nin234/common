//
//  ChatViewController.h
//  smartmsg
//
//  Created by Ninan Thomas on 2/28/18.
//  Copyright © 2018 Nshare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sharing/FriendDetails.h>

@interface ChatViewController : UICollectionViewController<UICollectionViewDelegateFlowLayout>
{
    NSString *tmpLabel;
}

@property (nonatomic, retain) FriendDetails *to;
@property (nonatomic, retain) UITextView *notes;
-(void) gotMsgNow:(NSString *)msg;

@end
