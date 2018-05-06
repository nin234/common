//
//  SharingDelegate.m
//  smartmsg
//
//  Created by Ninan Thomas on 2/19/18.
//  Copyright © 2018 Nshare. All rights reserved.
//

#import "ChatsSharingDelegate.h"
#import "ChatViewController.h"
#import "AVFoundation/AVAssetImageGenerator.h"

@implementation ChatsSharingDelegate

@synthesize dbIntf;
@synthesize tabBarController;
@synthesize selFrndCntrl;
@synthesize pShrMgr;
@synthesize pChatsVwCntrl;
@synthesize pChatsNavCntrl;
@synthesize controllersListView;
@synthesize bInRedrawViews;
@synthesize saveQ;
@synthesize bRedrawViewsOnPhotoDelete;
@synthesize pFlMgr;
@synthesize bRedrawChatsVwCntrl;


-(instancetype) init
{
    self = [super init];
    if (self)
    {
        dbIntf = [[ChatsDBIntf alloc] init];
        me = nil;
        pChatVw = nil;
        bInRedrawViews = false;
        bRedrawViewsOnPhotoDelete = false;
        saveQ = [[NSOperationQueue alloc] init];
        pFlMgr = [[NSFileManager alloc] init];
        bRedrawChatsVwCntrl = false;
        NSLog (@"initialized saveQ %s %d \n", __FILE__, __LINE__);
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
    bRedrawChatsVwCntrl = true;
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
    [pChatVw setViewWithKeyBoard:pChatVw.defaultNotesHeight text:nil];
    return true;
}

-(bool) sendPicture:(FriendDetails *) to Msg:(NSURL *)picurl
{
    if (![self fillMeDetailsifRequd])
    {
        NSLog(@"Cannot get my details sendPicture failed");
        return false;
    }
    NSString *shareStr = [[NSString alloc] init];
    shareStr = [shareStr stringByAppendingString:to.name];
    shareStr = [shareStr stringByAppendingString:@";"];
    shareStr = [shareStr stringByAppendingString:@"photo_caption"];
    [dbIntf insertPicture:to From:me Msg:picurl];
    [pShrMgr sharePicture:picurl metaStr:shareStr shrId:pShrMgr.share_id];
    return true;
}

-(bool) sendMovie:(FriendDetails *) to Msg:(NSURL *)movurl
{
    if (![self fillMeDetailsifRequd])
    {
        NSLog(@"Cannot get my details sendMovie failed");
        return false;
    }
    NSString *shareStr = [[NSString alloc] init];
    shareStr = [shareStr stringByAppendingString:to.name];
    shareStr = [shareStr stringByAppendingString:@";"];
    shareStr = [shareStr stringByAppendingString:@"movie_caption"];
    [dbIntf insertVideo:to From:me Msg:movurl];
    [pShrMgr sharePicture:movurl  metaStr:shareStr shrId:pShrMgr.share_id];
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
    pShrMgr.shrMgrDelegate = self;
    pShrMgr.pNtwIntf.connectAddr = @"smartmsg.ddns.net";
    pShrMgr.pNtwIntf.connectPort = @"16792";
    
    [self initializeTabBarCntrl];
}

-(void) startSmartMsgApp
{
    [pShrMgr start];
}

-(void) storeThumbNailImage:(NSURL *)picUrl
{
    UIImage  *fullScreenImage ;
    NSString *pFlName = [picUrl lastPathComponent];
    if ([pFlName hasSuffix:@".mp4"] || [pFlName hasSuffix:@".MOV"] )
    {
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:[AVAsset assetWithURL:picUrl]];
        CMTime thumbTime = CMTimeMakeWithSeconds(0.0, 600);
        NSError *error = nil;
        CMTime actualTime;
        
        CGImageRef startImage = [generator copyCGImageAtTime:thumbTime actualTime:&actualTime error:&error];
        fullScreenImage = [UIImage imageWithCGImage:startImage];
    }
    else
    {
        fullScreenImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:picUrl] scale:1.0];
    }
    
    CGSize oImgSize;
    oImgSize.height = 71;
    oImgSize.width = 71;
    UIGraphicsBeginImageContext(oImgSize);
    [fullScreenImage drawInRect:CGRectMake(0, 0, oImgSize.width, oImgSize.height)];
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //  CGImageRef thumbnailImageRef = MyCreateThumbnailImageFromData (data, 5);
    // UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
    CGSize pImgSiz = [thumbnail size];
    NSLog(@"Added thumbnail Image height = %f width=%f \n", pImgSiz.height, pImgSiz.width);
    
    NSData *thumbnaildata = UIImageJPEGRepresentation(thumbnail, 0.3);
    
    // [pAlName stringByAppendingString:@"/thumbnails/"];
    NSURL *albumurl = [picUrl URLByDeletingLastPathComponent];
    albumurl = [albumurl URLByAppendingPathComponent:@"thumbnails" isDirectory:YES];
    // NSURL  *albumurl = pDlg.pThumbNailsDir;
    NSError *err;
    
    if ([pFlName hasSuffix:@".mp4"])
    {
        pFlName = [pFlName stringByReplacingOccurrencesOfString:@"mp4" withString:@"jpg"];
        
    }
    else if ([pFlName hasSuffix:@".MOV"])
    {
        pFlName = [pFlName stringByReplacingOccurrencesOfString:@"MOV" withString:@"jpg"];
    }
    
    NSURL *pFlUrl;
    if (albumurl != nil && [albumurl checkResourceIsReachableAndReturnError:&err])
    {
        
        pFlUrl = [albumurl URLByAppendingPathComponent:pFlName isDirectory:NO];
    }
    
    if ([thumbnaildata writeToURL:pFlUrl atomically:YES] == NO)
    {
        NSLog (@"Failed to write to thumbnail file  %@\n",  pFlUrl);
        return;
        // --nAlNo;
        
    }
    else
    {
        NSLog(@"Save thumbnail file %@\n", pFlUrl);
    }
    NSArray *pathComponents = [picUrl pathComponents];
    NSUInteger cnt = [pathComponents count];
    NSString *pShareIdStr = [pathComponents objectAtIndex:cnt-3];
    FriendDetails *from = [[FriendDetails alloc] init];
    from.name = pShareIdStr;
    [dbIntf insertPicture:me From:from Msg:picUrl];
    return;
}

-(NSURL *) getPicUrl:(long long ) shareId picName:(NSString *) name itemName:(NSString *) iName
{
    NSString *pShareIdDir = [[NSNumber numberWithLongLong:shareId] stringValue];
    NSString *pHdir = NSHomeDirectory();
    NSString *pImgs = @"/Documents/";
    NSString *pImgsDir = [pHdir stringByAppendingString:pImgs];
    pImgsDir = [pImgsDir stringByAppendingString:pShareIdDir];
    pImgsDir = [pImgsDir stringByAppendingString:@"/images"];
    NSURL *pImgsURL = [NSURL fileURLWithPath:pImgsDir isDirectory:YES];
    NSString   *pThumbNailsDir = [pImgsDir stringByAppendingString:@"/thumbnails"];
    NSURL *pThumbNailsUrl = [NSURL fileURLWithPath:pThumbNailsDir isDirectory:YES];
    NSURL *pFlUrl;
    NSError *err;
    if (pThumbNailsUrl != nil && [pThumbNailsUrl checkResourceIsReachableAndReturnError:&err])
    {
        
        pFlUrl = [pImgsURL URLByAppendingPathComponent:name isDirectory:NO];
    }
    else
    {
        [pFlMgr createDirectoryAtURL:pThumbNailsUrl withIntermediateDirectories:YES attributes:nil error:nil];
        pFlUrl = [pImgsURL URLByAppendingPathComponent:name isDirectory:NO];
    }
    
    return pFlUrl;
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
