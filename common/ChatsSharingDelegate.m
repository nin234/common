//
//  SharingDelegate.m
//  smartmsg
//
//  Created by Ninan Thomas on 2/19/18.
//  Copyright © 2018 Nshare. All rights reserved.
//

#import "ChatsSharingDelegate.h"
#import "ChatViewController.h"

@implementation ChatsSharingDelegate

@synthesize dbIntf;
@synthesize tabBarController;
@synthesize selFrndCntrl;
@synthesize pShrMgr;
@synthesize pChatsVwCntrl;
@synthesize pChatsNavCntrl;
@synthesize controllersListView;
@synthesize bInRedrawViews;


-(instancetype) init
{
    self = [super init];
    if (self)
    {
        dbIntf = [[ChatsDBIntf alloc] init];
        me = nil;
        pChatVw = nil;
        bInRedrawViews = false;
        return self;
    }
    return  nil;
}

+ (instancetype)sharedInstance
{
    static ChatsSharingDelegate *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ChatsSharingDelegate alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

-(bool) fillMeDetailsifRequd
{
    if (me == nil)
    {
        if (pShrMgr.share_id)
        {
            me = [[FriendDetails alloc] init];
            me.nickName = @"ME";
            me.name = [NSString stringWithFormat:@"%lld", pShrMgr.share_id];
        }
        else
        {
            return false;
        }
    }
    return true;
}

-(bool) insertTextMsg:(FriendDetails *) from Msg:(NSString *) msg
{
    if (![self fillMeDetailsifRequd])
    {
        return false;
    }
    
    [dbIntf insertTextMsg:me From:from Msg:msg];
    
    if (pChatVw != nil && [pChatVw.to.name isEqualToString:from.name])
    {
        [pChatVw gotMsgNow:msg];
    }
     
    return true;
}

-(bool) sendMsg:(FriendDetails *) to Msg:(NSString *)msg
{
    if (![self fillMeDetailsifRequd])
    {
        NSLog(@"Cannot get my details sendMsg failed");
        return false;
    }
    NSString *shareStr = [[NSString alloc] init];
    shareStr = [shareStr stringByAppendingString:to.name];
    shareStr = [shareStr stringByAppendingString:@";"];
    shareStr = [shareStr stringByAppendingString:@":::"];
    shareStr = [shareStr stringByAppendingString:msg];
    [dbIntf insertTextMsg:to From:me Msg:msg];
    [pShrMgr shareItem:shareStr listName:me.name shrId:pShrMgr.share_id];
    return true;
}

-(void) showViewWithoutKeyBoard
{
    [pChatVw showViewWithoutKeyBoard];
}

-(void) processItems
{
    [pShrMgr processItems];
}

-(void) getItems
{
    [pShrMgr getItems];
}

-(void) launchChat:(FriendDetails *) frnd
{
    if (frnd == nil)
    {
        NSLog(@"Error frnd is nil , Cannot launch chat");
        return;
    }
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
   
    //launch ChatViewController with chat history
    NSLog(@"Launching ChatViewController");
    self.tabBarController.selectedIndex = 0;
    [self.tabBarController.tabBar setHidden:YES];
    pChatVw = [ChatMainViewController alloc];
    
    pChatVw.to = frnd;
    
     pChatVw = [pChatVw initWithNibName:nil bundle:nil];
    
    [pChatsNavCntrl pushViewController:pChatVw animated:YES];
        
    
}

-(void) showTabBar
{
    [self.tabBarController.tabBar setHidden:NO];
}

-(void) redrawViews:(CGFloat) inputTextViewHeight text:(NSString *) notesText
{
    if (bInRedrawViews)
    {
        NSLog(@"Already in redrawViews ignoring this call");
        return;
    }
    bInRedrawViews = true;
    [pChatVw redrawViews:inputTextViewHeight text:notesText];
}

-(void) initializeTabBarCntrl
{
    UIImage *image = [UIImage imageNamed:@"895-user-group@2x.png"];
    UIImage *imageSel = [UIImage imageNamed:@"895-user-group-selected@2x.png"];
    tabBarController = [[UITabBarController alloc] init];
    tabBarController.delegate = self;
    selFrndCntrl = [[ContactsViewController alloc] initWithNibName:nil bundle:nil];
    selFrndCntrl.pShrMgr = pShrMgr;
    selFrndCntrl.delegate = self;
    pChatsVwCntrl = [ChatsViewController alloc];
    pChatsVwCntrl.delegate = self;
    pChatsVwCntrl = [pChatsVwCntrl initWithNibName:nil bundle:nil];
    pChatsVwCntrl.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Share" image:image selectedImage:imageSel];
    pChatsNavCntrl = [[UINavigationController alloc] initWithRootViewController:pChatsVwCntrl];
    selFrndCntrl.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemContacts tag:0];
    UINavigationController *selFrndNavCntrl = [[UINavigationController alloc] initWithRootViewController:selFrndCntrl];
    controllersListView = [NSArray arrayWithObjects:pChatsNavCntrl, selFrndNavCntrl, nil];
    tabBarController.viewControllers = controllersListView;
    selFrndCntrl.tabBarController = tabBarController;
}

-(void) showContactsSelectViewForNewChats
{
    self.tabBarController.selectedIndex = 1;
    self.selFrndCntrl.eViewCntrlMode = eModeSelectToShare;
}

-(void) initSmartMsgApp
{
    pShrMgr = [[SmartShareMgr alloc] init];
    pShrMgr.pNtwIntf.connectAddr = @"smartmsg.ddns.net";
    pShrMgr.pNtwIntf.connectPort = @"16792";
    
    [self initializeTabBarCntrl];
}

-(void) startSmartMsgApp
{
    [pShrMgr start];
}


-(NSURL *) getPicUrl:(long long ) shareId picName:(NSString *) name itemName:(NSString *) iName
{
    return nil;
}

-(void) storeThumbNailImage:(NSURL *)picUrl
{
    
}

-(void) setShareId : (long long) shareId
{
    
}

-(void) shareNow:(NSString *) shareStr
{
    
}

-(void) refreshShareMainLst
{
    
}
@end
