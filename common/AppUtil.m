//
//  AppUtil.m
//  common
//
//  Created by Rekha Thomas on 3/12/16.
//  Copyright © 2016 Sinacama. All rights reserved.
//

#import "AppUtil.h"
#import "MainViewController.h"
#import <Social/SLComposeViewController.h>
#import <Social/SLServiceTypes.h>

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

-(void) setPurchsd:(NSString *)trid
{
    NSLog(@"Setting purchased to true");
    [appShrUtl setPurchsdTokens:trid];
    appShrUtl.purchased = true;
    [delegate setPurchsed];
    [inapp stop];
    
    if (!bShrMgrStarted)
    {
        [pShrMgr start];
        bShrMgrStarted = true;
    }
    
}

-(instancetype) init
{
    self = [super init];
    if (self)
    {
        bShrMgrStarted = false ;
        bNoICloudAlrt = false;
        inapp = [[InAppPurchase alloc] init];
        [inapp setProductId:productId];
        [inapp setDelegate:self];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:inapp];
        return self;
    }
    return  nil;
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
    
    pSh= [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email", @"Facebook share", @"Upgrade", @"Share", nil];
    
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
    self.dataSync.dontRefresh = false;
    UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(iCloudOrEmail)];
    pMainVwCntrl.pAllItms.tableView.tableFooterView = nil;
    
    self.navViewController.navigationBar.topItem.leftBarButtonItem = pBarItem1;
    
    self.dataSync.updateNow = true;
    [pMainVwCntrl.pAllItms resetSelectedItems];
    self.navViewController.toolbarHidden = YES;
    return;
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    MainViewController *pMainVwCntrl = [self.navViewController.viewControllers objectAtIndex:0];
    printf("Clicked button at index %ld\n", (long)buttonIndex);
    UIBarButtonItem *pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(iCloudEmailCancel) ];
    self.navViewController.navigationBar.topItem.leftBarButtonItem = pBarItem;
    self.navViewController.toolbarHidden = NO;
    
    UIBarButtonItem *flexibleSpaceButtonItem = [[UIBarButtonItem alloc]
                                                initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                target:nil action:nil];
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 45)];
    footer.backgroundColor = [UIColor clearColor];
    pMainVwCntrl.pAllItms.tableView.tableFooterView = footer;
    UIBarButtonItem *pBarItem1;
    if (bUpgradeAction)
    {
        bUpgradeAction = false;
        switch (buttonIndex)
        {
            case 0:
                NSLog(@"Purchasing openhouses_unlocked");
                //purchased = false;
                if (!appShrUtl.purchased)
                    [inapp start:true];
                else
                    NSLog(@"Already upgraded, ignoring");
                [self iCloudEmailCancel];
                break;
                
            case 1:
                NSLog(@"Restoring openhouses_unlocked");
                if (!appShrUtl.purchased)
                    [inapp start:false];
                else
                    NSLog(@"Already upgraded, ignoring");
                [self iCloudEmailCancel];
                
                break;
                
            default:
                [self iCloudEmailCancel];
                
                break;
        }
        return;
    }
    
    if (buttonIndex == 0)
    {
        NSLog(@"In email \n");
        pMainVwCntrl.pAllItms.bInEmail = true;
        pMainVwCntrl.emailAction = true;
        pBarItem1 = [[UIBarButtonItem alloc] initWithTitle:@"Email" style:UIBarButtonItemStylePlain target:self action:@selector(emailNow)];
        
    }
    else if (buttonIndex == 1)
    {
        UIDevice *dev = [UIDevice currentDevice];
        if ([[dev systemVersion] doubleValue] < 6.0)
        {
            [self iCloudEmailCancel];
            return;
        }
        NSLog(@"In facebook share\n");
        pMainVwCntrl.pAllItms.bInEmail = true;
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
        {
            pBarItem1 = [[UIBarButtonItem alloc] initWithTitle:@"Facebook" style:UIBarButtonItemStylePlain target:self action:@selector(fbshareNow)];
            
            
        }
        else
        {
            UIAlertView *pAvw = [[UIAlertView alloc] initWithTitle:@"No Facebook Account" message:@"Please set up facebook account in settings. House details including pictures can be shared with selected group of friends on Facebook" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            bNoICloudAlrt = true;
            [pAvw show];
        }
    }
    else if (buttonIndex == 2)
    {
        
        [self iCloudEmailCancel];
        bUpgradeAction = true;
        UIActionSheet *pSh;
        
        pSh= [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Purchase", @"Restore Purchases", nil];
        
        MainViewController *pMainVwCntrl = [self.navViewController.viewControllers objectAtIndex:0];
        [pMainVwCntrl.pAllItms lockItems];
        [pSh setDelegate:self];
        [pSh showInView:pMainVwCntrl.pAllItms.tableView];
        
        
        
    }
    else
    {
        [self iCloudEmailCancel];
        return;
    }
    
    [pMainVwCntrl setToolbarItems:[NSArray arrayWithObjects:
                                   flexibleSpaceButtonItem,
                                   pBarItem1,
                                   flexibleSpaceButtonItem,
                                   nil]
                         animated:YES];
    self.dataSync.updateNowSetDontRefresh = true;
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
    
    MainViewController *pMainVwCntrl = [self.navViewController.viewControllers objectAtIndex:0];
    int attchmnts = (int)buttonIndex;
    
    if(bNoICloudAlrt)
    {
        [self iCloudEmailCancel];
        bNoICloudAlrt = false;
        return;
    }
    
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
