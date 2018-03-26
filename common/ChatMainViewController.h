//
//  ChatMainViewController.h
//  common
//
//  Created by Ninan Thomas on 3/25/18.
//  Copyright © 2018 Sinacama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatViewController1.h"
#import <sharing/FriendDetails.h>

@interface ChatMainViewController : UIViewController

@property (nonatomic, retain) UITextView *notes;
@property (nonatomic, retain) FriendDetails *to;
@property  (nonatomic, retain) ChatViewController1 *pChatTableVw;
@property (nonatomic, retain) UIView *pChatInputView;


-(void) gotMsgNow:(NSString *)msg;


@end
