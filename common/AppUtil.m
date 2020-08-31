//
//  AppUtil.m
//  common
//
//  Created by Rekha Thomas on 3/12/16.
//  Copyright © 2016 Sinacama. All rights reserved.
//

#import "AppUtil.h"
#import "TemplListViewController.h"
#import <Social/SLComposeViewController.h>
#import <Social/SLServiceTypes.h>
#import "AppCmnUtil.h"
#import "common.h"
#import "List.h"

@implementation AppUtil

@synthesize navViewController;
@synthesize dataSync;
@synthesize appShrUtl;
@synthesize inapp;
@synthesize pShrMgr;
@synthesize delegate;
@synthesize productId;
@synthesize bNoICloudAlrt;
@synthesize bFBAction;
@synthesize bEmailConfirm;
@synthesize aViewController1;
@synthesize window;
@synthesize mainVwNavCntrl;
@synthesize aViewController2;


-(void) setPurchsd:(NSString *)trid
{
    NSLog(@"Setting purchased to true");
    [appShrUtl setPurchsdTokens:trid];
    appShrUtl.purchased = true;
    [delegate setPurchsed];
    [inapp stop];
    
    
    
}

-(instancetype) init
{
    self = [super init];
    if (self)
    {
        
        bNoICloudAlrt = false;
        bUpgradeAlert = false;
        inapp = [[InAppPurchase alloc] init];
        [inapp setProductId:productId];
        [inapp setDelegate:self];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:inapp];
        
        
        

        return self;
    }
    return  nil;
}

-(void) setNavViewController:(UINavigationController *)navViewControll
{
    navViewController = navViewControll;
    AppCmnUtil *appCmnUtil = [AppCmnUtil sharedInstance];
    appCmnUtil.navViewController = navViewControll;
    appCmnUtil.bEasyGroc = false;
    
}



-(void) setDataSync:(DataOps *)dataSyn
{
    dataSync = dataSyn;
    AppCmnUtil *appCmnUtil = [AppCmnUtil sharedInstance];
  appCmnUtil.dataSync = dataSyn;
}

-(void) shareNow:(NSString *) shareStr
{
    id itm = [aViewController1.pAllItms getMessage:PHOTOREQSOURCE_SHARE];
    NSString *picMetaStr = shareStr;
    NSString *shrStr = [shareStr stringByAppendingString:@":::"];
    NSString *shrMsg = [delegate getShareMsg:itm];
    NSString *name = [delegate getItemName:itm];
    long long share_id = [delegate getItemShareId:itm];
    if (name == nil)
        return;
    picMetaStr  = [picMetaStr stringByAppendingString:name];
    shrStr = [shrStr stringByAppendingString:shrMsg];
    ItemKey *itk = [delegate getItemKey:itm];
    NSArray* checkListArr = [dataSync getList:itk];
    NSUInteger nItems = [checkListArr count];
    shrStr = [shrStr stringByAppendingString:@"::]}]::"];
    for (NSUInteger i=0; i < nItems; ++i)
    {
        List *item = [checkListArr objectAtIndex:i];
        shrStr = [shrStr stringByAppendingString:[[NSNumber numberWithLongLong:item.rowno] stringValue]];
        shrStr = [shrStr stringByAppendingString:keyValSeparator];
        shrStr = [shrStr stringByAppendingString:[[NSNumber numberWithBool:item.hidden] stringValue]];
        shrStr = [shrStr stringByAppendingString:keyValSeparator];
        shrStr = [shrStr stringByAppendingString:item.item];
        shrStr = [shrStr stringByAppendingString:@"]:;"];
    }

    [pShrMgr shareItem:shrStr listName:name shrId:share_id];
    NSUInteger cnt =  [aViewController1.pAllItms.attchments count];
    for (NSUInteger i =0; i < cnt; ++i)
    {
        NSURL *picUrl = [aViewController1.pAllItms.attchments objectAtIndex:i];
        NSArray *pathcomps = [picUrl pathComponents];
        NSString *picName = [pathcomps lastObject];
        if (picName == nil)
            continue;
        /*
        if ([picName hasSuffix:@".MOV"])
        {
            picName = [picName stringByReplacingOccurrencesOfString:@"MOV" withString:@"mp4"];
            picUrl = [picUrl URLByDeletingLastPathComponent];
            picUrl = [picUrl URLByAppendingPathComponent:picName];
        }
         */
        
        [pShrMgr sharePicture:picUrl metaStr:picMetaStr shrId:share_id];
    }
    [aViewController1.pAllItms.attchments removeAllObjects];
    [aViewController1.pAllItms.movOrImg removeAllObjects];
}



- (NSString *) getAlbumDir: (NSString *) album_name
{
    NSString *pHdir = NSHomeDirectory();
    NSString *pAlbums = @"/Documents/albums";
    NSString *pAlbumsDir = [pHdir stringByAppendingString:pAlbums];
    pAlbumsDir = [pAlbumsDir stringByAppendingString:@"/"];
    NSString *pNewAlbum = [pAlbumsDir stringByAppendingString:album_name];
    NSURL *url = [NSURL fileURLWithPath:pNewAlbum isDirectory:YES];
    return [url absoluteString];
}

-(void) iCloudOrEmail
{
    NSLog(@"Showing iCloud email action sheet \n");
    
    //Move files to iCloud, pull files from iCloud
    //how to reconcile
    //Album directory name by time of
    
    UIActionSheet *pSh;
    
    pSh= [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share", @"Check Lists", nil];
    
    MainViewController *pMainVwCntrl = [self.navViewController.viewControllers objectAtIndex:0];
    [pMainVwCntrl.pAllItms lockItems];
    [pSh setDelegate:self];
    [pSh showInView:pMainVwCntrl.pAllItms.tableView];
    
    
    
    
    return;
}

-(void) iCloudEmailCancel
{
    
    MainViewController *pMainVwCntrl = [self.navViewController.viewControllers objectAtIndex:0];
    pMainVwCntrl.pAllItms.bInEmail = false;
    pMainVwCntrl.pAllItms.bInICloudSync = false;
    [pMainVwCntrl.pAllItms unlockItems];
    [pMainVwCntrl.pAllItms attchmentsClear];
    
    UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(iCloudOrEmail)];
    pMainVwCntrl.pAllItms.tableView.tableFooterView = nil;
    
    self.navViewController.navigationBar.topItem.leftBarButtonItem = pBarItem1;
    
    self.dataSync.updateNow = true;
    [pMainVwCntrl.pAllItms resetSelectedItems];
    self.navViewController.toolbarHidden = YES;
    return;
}

-(void) refreshShareMainLst
{
    [dataSync updateShareMainLstVwCntrl:aViewController1];
}

-(void) refreshShareView
{
    [dataSync updateShareMainLstVwCntrl:aViewController1];
}

-(void) initShareTabBar
{
    aViewController1 = [MainViewController alloc];
       aViewController1.delegate = (id)delegate;
    aViewController1.delegate_1  = (id) delegate;
    aViewController1.bShareView = true;
    aViewController1 = [aViewController1 initWithNibName:nil bundle:nil];
    
    aViewController2 = [MainViewController alloc];
    
    aViewController2.pAllItms.bInICloudSync = false;
    aViewController2.pAllItms.bInEmail = false;
    aViewController2.pAllItms.bAttchmentsInit = false;
   
    aViewController2.bShareView = false;
   
    aViewController2.delegate = (id)delegate;
    
    aViewController2.delegate_1  = (id) delegate;
    aViewController2 = [aViewController2 initWithNibName:nil bundle:nil];
    
    UIImage *image = [UIImage imageNamed:@"895-user-group@2x.png"];
    UIImage *imageSel = [UIImage imageNamed:@"895-user-group-selected@2x.png"];
    aViewController1.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Share" image:image selectedImage:imageSel];
    
    mainShareVwNavCntrl = [[UINavigationController alloc] initWithRootViewController:aViewController1];
    
    UIImage *imageHome = [UIImage imageNamed:@"802-dog-house@2x.png"];
    UIImage *imageHomeSel = [UIImage imageNamed:@"895-dog-house-selected@2x.png"];
    
    aViewController2.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Home" image:imageHome selectedImage:imageHomeSel];
    
    mainVwNavCntrl = [[UINavigationController alloc] initWithRootViewController:aViewController2];
    
    
    TemplListViewController *aViewController = [TemplListViewController alloc];
    aViewController = [aViewController initWithNibName:nil bundle:nil];
    aViewController.bCheckListView = true;
    dataSync.templListViewController = aViewController;
    
    UIImage *imagePlanner = [UIImage imageNamed:@"ic_event_note_white_36pt"];
        UIImage *imagePlannerSel = [UIImage imageNamed:@"ic_event_note_36pt"];
    aViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Checklists" image:imagePlanner selectedImage:imagePlannerSel];
    
    UINavigationController *checkListNavCntrl = [[UINavigationController alloc] initWithRootViewController:aViewController];
    aViewController.navViewController = checkListNavCntrl;
    dataSync.templNavViewController = checkListNavCntrl;
    
    
    [appShrUtl initializeTabBarCntrl:mainShareVwNavCntrl mainNavCntrl:mainVwNavCntrl     checkListCntrl:checkListNavCntrl ContactsDelegate:self];

}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    MainViewController *pMainVwCntrl = [self.navViewController.viewControllers objectAtIndex:0];
    printf("Clicked button at index %ld\n", (long)buttonIndex);
    //UIBarButtonItem *pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(iCloudEmailCancel) ];
   // self.navViewController.navigationBar.topItem.leftBarButtonItem = pBarItem;
   // self.navViewController.toolbarHidden = NO;
    
  //  UIBarButtonItem *flexibleSpaceButtonItem = [[UIBarButtonItem alloc]
    //                                            initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
      //                                          target:nil action:nil];
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 45)];
    footer.backgroundColor = [UIColor clearColor];
    pMainVwCntrl.pAllItms.tableView.tableFooterView = footer;
    //UIBarButtonItem *pBarItem1;
        
    if (buttonIndex == 0)
    {
        [appShrUtl showShareView];
                
    }
    
    else if (buttonIndex == 1)
    {
        
        TemplListViewController *aViewController = [TemplListViewController alloc];
        
        aViewController = [aViewController initWithNibName:nil bundle:nil];
        aViewController.bCheckListView = true;
        [self.navViewController pushViewController:aViewController animated:YES];
        
        
    }
    else
    {
        [self iCloudEmailCancel];
        return;
    }
    /*
    [pMainVwCntrl setToolbarItems:[NSArray arrayWithObjects:
                                   flexibleSpaceButtonItem,
                                   pBarItem1,
                                   flexibleSpaceButtonItem,
                                   nil]
                         animated:YES];
    */
    //[pMainVwCntrl.pAllItms.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationLeft];
    return;
    
    
}

-(void) emailRightNow
{
    
    MainViewController *pMainVwCntrl = [self.navViewController.viewControllers objectAtIndex:0];
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:@"House details"];
    
    [controller setMessageBody:[delegate getEmailFbMsg:[pMainVwCntrl.pAllItms getMessage:PHOTOREQSOURCE_EMAIL]] isHTML:NO];
    
    NSUInteger cnt = [pMainVwCntrl.pAllItms.attchments count];
    NSLog (@"Attaching %lu images\n",(unsigned long)cnt);
    for (NSUInteger i=0; i < cnt; ++i)
    {
        if ([[pMainVwCntrl.pAllItms.movOrImg objectAtIndex:i] boolValue])
        {
            [controller addAttachmentData:[NSData dataWithContentsOfURL:[pMainVwCntrl.pAllItms.attchments objectAtIndex:i]] mimeType:@"image/jpeg" fileName:@"photo"];
        }
        else
        {
            [controller addAttachmentData:[NSData dataWithContentsOfURL:[pMainVwCntrl.pAllItms.attchments objectAtIndex:i]] mimeType:  @"video/quicktime" fileName:@"video"];
        }
    }
    if (controller)
        [pMainVwCntrl presentViewController:controller animated:YES completion:nil];
    [self iCloudEmailCancel];
    return;
}

-(void) photoActions:(int) source
{
    switch (source)
    {
        case PHOTOREQSOURCE_EMAIL:
            [self emailRightNow];
            break;
            
        case PHOTOREQSOURCE_FB:
            [self fbshareRightNow];
            break;
            
        default:
            break;
    }
    return;
}



-(void) fbshareRightNow
{
    MainViewController *pMainVwCntrl = [self.navViewController.viewControllers objectAtIndex:0];
    SLComposeViewController *fbVwCntrl = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    if (fbVwCntrl != nil)
    {
       
        [fbVwCntrl setInitialText:[delegate getEmailFbMsg:[pMainVwCntrl.pAllItms getMessage:PHOTOREQSOURCE_FB]]];
        NSUInteger cnt = [pMainVwCntrl.pAllItms.attchments count];
        NSLog (@"Attaching %lu images\n",(unsigned long)cnt);
        for (NSUInteger i=0; i < cnt; ++i)
        {
            [fbVwCntrl addImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[pMainVwCntrl.pAllItms.attchments objectAtIndex:i]]]];
        }
        [fbVwCntrl setCompletionHandler:^(SLComposeViewControllerResult result)
         {
             if (result == SLComposeViewControllerResultCancelled)
                 NSLog(@"User cancelled fb post\n");
             else
                 NSLog(@"Posted to fb\n");
             [self iCloudEmailCancel];
         }
         ];
        [pMainVwCntrl presentViewController:fbVwCntrl animated:YES completion:nil];
    }
    return;
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Clicked button at index %ld", (long)buttonIndex);
    if (bUpgradeAlert)
    {
        NSLog(@"Resetting bUpgradeAlert in alertview action");
        bUpgradeAlert = false;
        return;
    }
    
    MainViewController *pMainVwCntrl = [self.navViewController.viewControllers objectAtIndex:0];
    
    if(bNoICloudAlrt)
    {
        [self iCloudEmailCancel];
        bNoICloudAlrt = false;
        return;
    }
    int attchmnts = (int)buttonIndex;

    switch (attchmnts)
    {
        case 0:
            NSLog(@"Attaching no photos\n");
            if (bFBAction)
            {
                bFBAction = false;
                [self fbshareRightNow];
                return;
            }
            if (bEmailConfirm)
            {
                bEmailConfirm = false;
                [self emailRightNow];
            }
            break;
            
        case 1:
        {
            NSLog(@"Attaching all the photos\n");
            if (bFBAction)
            {
                bFBAction = false;
                [pMainVwCntrl.pAllItms getPhotos:0 source:PHOTOREQSOURCE_FB];
                return;
            }
            
            if(bEmailConfirm)
            {
                bEmailConfirm =false;
                [pMainVwCntrl.pAllItms getPhotos:0 source:PHOTOREQSOURCE_EMAIL];
            }
         }
         break;
            
        default:
            break;
    }
    
    NSLog(@"Email selected items\n");
    return;
}

-(void) fbshareNow
{
    MainViewController *pMainVwCntrl = [self.navViewController.viewControllers objectAtIndex:0];
    if(![pMainVwCntrl.pAllItms itemsSelected])
    {
        [self iCloudEmailCancel];
        return;
    }
    bFBAction = true;
    UIAlertView *pAvw = [[UIAlertView alloc] initWithTitle:@"Post Pictures" message:@"Only images can be posted. Movies cannot be posted" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [pAvw show];
    
    return;
}

-(void) shareDone
{
  
    appShrUtl.selFrndCntrl.eViewCntrlMode = eModeContactsMgmt;
    appShrUtl.tabBarController.selectedIndex = 0;
}


-(void) emailNow
{
    if ([MFMailComposeViewController canSendMail])
    {
        MainViewController *pMainVwCntrl = [self.navViewController.viewControllers objectAtIndex:0];
        if(![pMainVwCntrl.pAllItms itemsSelected])
        {
            [self iCloudEmailCancel];
            return;
        }
        bEmailConfirm = true;
        
        UIAlertView *pAvw = [[UIAlertView alloc] initWithTitle:@"Attach Pictures" message:@"" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        [pAvw show];
        
    }
    
    return;
}

@end
