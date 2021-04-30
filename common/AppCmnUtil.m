//
//  AppCmnUtil.m
//  common
//
//  Created by Ninan Thomas on 3/12/17.
//  Copyright © 2017 Sinacama. All rights reserved.
//

#import "AppCmnUtil.h"
#import "common-Swift.h"
#import "TemplListViewController.h"
#import "EasyDisplayViewController.h"
#import "SubscribeViewController.h"
#import "sharing/SHKeychainItemWrapper.h"

@implementation AppCmnUtil

@synthesize dataSync;
@synthesize navViewController ;
@synthesize templNavViewController;
@synthesize bEasyGroc;
@synthesize pFlMgr;
@synthesize pPicsDir;
@synthesize pThumbNailsDir;
@synthesize aViewController1;
@synthesize listName;
@synthesize itemsMp;
@synthesize share_id;
@synthesize appId;
@synthesize inapp;

-(instancetype) init
{
    self = [super init];
    if (self)
    {
        
        itemsMp = nil;
        bEasyGroc = false;
        share_id =0;
        inapp = nil;
        SHKeychainItemWrapper * kchain = [[SHKeychainItemWrapper alloc] initWithIdentifier:@"SharingData" accessGroup:@"3JEQ693MKL.com.rekhaninan.frndlst"];
                
       NSString *share_id_str = [kchain objectForKey:(__bridge id)kSecValueData];

        if (share_id_str != nil)
            share_id = [share_id_str intValue];
        else
            share_id = 0;
        
       
        return self;

    }
    
    return nil;
    
}

-(void) setAppId:(int)aId
{
    appId = aId;
    inapp = [InAppPurchase alloc];
    [inapp setAppId:appId];
    inapp = [inapp init];
    
}

-(void ) startInAppPurchase
{
    
}

-(void) showPicList:(NSString *)name pictName:(NSString *)picName imagePicker:(UIImagePickerController *) imagePick
{
    [imagePick dismissViewControllerAnimated:NO completion:^{
        [self popView];
        EasyDisplayViewController *photoVwCntrl = [EasyDisplayViewController alloc];
        photoVwCntrl.picName = picName;
        photoVwCntrl.listName = name;
        photoVwCntrl.share_id = share_id;
        photoVwCntrl = [photoVwCntrl initWithNibName:nil bundle:nil];
        [self.navViewController pushViewController:photoVwCntrl animated:YES];
    }];
    
    return;
}

-(bool) canContinue:(UIViewController *) vwCntrl
{
    if ((share_id > 1000 && share_id < 2500) && share_id != 2352 && share_id != 2354)
    {
        return true;
    }
    bool bCont = [inapp canContinue:vwCntrl];
    if (bCont)
        return true;
    
    SubscribeViewController *pSubView = [[SubscribeViewController alloc] initWithNibName:@"SubscribeViewController" bundle:nil];
    
    [self.navViewController pushViewController:pSubView animated:YES];
    
    return false;
}



+ (instancetype)sharedInstance
{
    static AppCmnUtil *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AppCmnUtil alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

-(void) popView
{
    //putchar('N');
    NSArray *vws = [self.navViewController viewControllers];
    NSLog(@"No of view controllers %ld", (unsigned long)[vws count]);
    [self.navViewController popViewControllerAnimated:NO];
    vws = [self.navViewController viewControllers];
    NSLog(@"No of view controllers %ld", (unsigned long)[vws count]);
    
   
}



@end
