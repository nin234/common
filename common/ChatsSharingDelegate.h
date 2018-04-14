//
//  SharingDelegate.h
//  smartmsg
//
//  Created by Ninan Thomas on 2/19/18.
//  Copyright © 2018 Nshare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sharing/ContactsViewController.h>
#import <sharing/ShareMgr.h>
#import "SmartShareMgr.h"
#import "ChatsDBIntf.h"
#import "ChatsViewController.h"
#import "ChatMainViewController.h"


@interface ChatsSharingDelegate : NSObject<ContactsViewControllerDelegate, ShareMgrDelegate, UITabBarControllerDelegate, ChatsViewControllerDelegate>
{
    FriendDetails *me;
    ChatMainViewController *pChatVw;
    
}

-(void) launchChat:(FriendDetails *) frnd;
-(NSURL *) getPicUrl:(long long ) shareId picName:(NSString *) name itemName:(NSString *) iName;
-(void) storeThumbNailImage:(NSURL *)picUrl;
-(void) setShareId : (long long) shareId;
-(void) shareNow:(NSString *) shareStr;
-(void) refreshShareMainLst;
-(void) initSmartMsgApp;
-(void) startSmartMsgApp;
-(void) showContactsSelectViewForNewChats;
-(bool) sendMsg:(FriendDetails *) to Msg:(NSString *)msg;

@property (nonatomic, retain) ChatsDBIntf *dbIntf;
@property (nonatomic, retain)  UITabBarController  *tabBarController;
@property (nonatomic, retain) ContactsViewController  *selFrndCntrl;
@property (nonatomic, retain) SmartShareMgr *pShrMgr;
@property (nonatomic, retain) NSArray* controllersListView;
@property  (nonatomic, retain) ChatsViewController *pChatsVwCntrl;
@property  (nonatomic, retain) UINavigationController *pChatsNavCntrl;
@property (nonatomic) bool bInRedrawViews;

-(void) processItems;
-(void) getItems;
-(bool) insertTextMsg:(FriendDetails *) from Msg:(NSString *) msg;
+ (instancetype)sharedInstance;

-(void) showViewWithoutKeyBoard;
-(void) redrawViews:(CGFloat) inputTextViewHeight text:(NSString *) notesText;
-(void) showTabBar;

@end
