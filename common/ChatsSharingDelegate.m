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


-(instancetype) init
{
    self = [super init];
    if (self)
    {
        dbIntf = [[ChatsDBIntf alloc] init];
        return self;
    }
    return  nil;
}
-(void) launchChat:(FriendDetails *) frnd
{
    if ([dbIntf chatExists:frnd])
    {
        //launch ChatViewController with chat history
        NSLog(@"Launching ChatViewController");
        ChatViewController *pChatVw = [[ChatViewController alloc] initWithNibName:nil bundle:nil];
        [pChatsNavCntrl pushViewController:pChatVw animated:YES];
        
    }
    else
    {
        //launch empty ChatViewController
        NSLog(@"Launching ChatViewController");
        ChatViewController *pChatVw = [[ChatViewController alloc] initWithNibName:nil bundle:nil];
        [pChatsNavCntrl pushViewController:pChatVw animated:YES];
    }
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
