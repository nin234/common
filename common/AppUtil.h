//
//  AppUtil.h
//  common
//
//  Created by Rekha Thomas on 3/12/16.
//  Copyright © 2016 Sinacama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DataOps.h"
#import "sharing/AppShrUtil.h"
#import "sharing/InAppPurchase.h"
#import "sharing/ShareMgr.h"
#import "sharing/ContactsViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "MainViewController.h"

#import "TemplListViewController.h"

#define   PHOTOREQSOURCE_FB 1
#define  PHOTOREQSOURCE_EMAIL 0
#define  PHOTOREQSOURCE_SHARE 2

@protocol AppUtilDelegate <NSObject>

-(void) setPurchsed;
-(NSString *) getEmailFbMsg:(id)itm;
-(NSString *) getShareMsg:(id)itm;
-(NSString *) getItemName:(id)itm;
-(long long ) getItemShareId:(id) itm;
-(ItemKey *) getItemKey:(id) itm;

@end

@interface AppUtil : NSObject<UIActionSheetDelegate, InAppPurchaseDelegate, MFMailComposeViewControllerDelegate, ContactsViewControllerDelegate, UIAlertViewDelegate>
{
    
     bool bUpgradeAlert;
    UINavigationController *mainShareVwNavCntrl;
    
}


@property (nonatomic, retain) IBOutlet UINavigationController *navViewController;
@property (nonatomic, retain) DataOps *dataSync;
@property (nonatomic, retain) AppShrUtil *appShrUtl;
@property (nonatomic, retain) InAppPurchase *inapp;
@property (nonatomic, retain) ShareMgr *pShrMgr;
@property (nonatomic, weak) id<AppUtilDelegate> delegate;
@property (nonatomic, retain) UINavigationController *mainVwNavCntrl;
@property bool bFBAction;
@property bool bEmailConfirm;
@property bool bNoICloudAlrt;
@property (nonatomic, strong) NSString *productId;
@property (nonatomic, retain) MainViewController *aViewController1;
@property (nonatomic, retain) MainViewController *aViewController2;
@property (nonatomic, retain) UIWindow *window;


-(void) iCloudEmailCancel;
- (NSString *) getAlbumDir: (NSString *) album_name;
-(void) iCloudOrEmail;
-(void) photoActions:(int) source;
-(void) shareNow:(NSString *) shareStr;
-(void) setNavViewController:(UINavigationController *)navViewController;
-(void) initShareTabBar;
-(void) refreshShareView;
-(void) refreshShareMainLst;


@end
