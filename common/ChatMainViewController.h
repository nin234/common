//
//  ChatMainViewController.h
//  common
//
//  Created by Ninan Thomas on 3/25/18.
//  Copyright © 2018 Sinacama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatViewController1.h"
#import "ChatViewController2.h"
#import <sharing/FriendDetails.h>

@interface ChatMainViewController : UIViewController


@property (nonatomic, retain) FriendDetails *to;
@property  (nonatomic, retain) ChatViewController1 *pChatOutputView;
@property (nonatomic, retain) ChatViewController2 *pChatInputView;
@property (nonatomic) bool bViewWithKeyBoard;


-(void) gotMsgNow:(NSString *)msg;
-(void) showViewWithoutKeyBoard;

@end
