//
//  EasyViewController.h
//  EasyGrocList
//
//  Created by Ninan Thomas on 3/5/13.
//  Copyright (c) 2013 Ninan Thomas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EasyListViewController.h"

enum eActionSheet
{
    eActnShetMainScreen,
    eActnShetInAppPurchse
};

@protocol EasyViewControllerDelegate <NSObject>

-(void) shareMgrStartAndShow;
-(void) shareContactsSetSelected;
-(id) getTemplListVwCntrlDelegate;

@end

@interface EasyViewController : UIViewController <UISearchBarDelegate, UIActionSheetDelegate>
{
    enum eActionSheet eAction;
}

@property (strong, nonatomic) EasyListViewController *pAllItms;
@property (strong, nonatomic) UISearchBar *pSearchBar;
@property (nonatomic) bool bShareView;

- (void)enableCancelButton:(UISearchBar *)aSearchBar;
- (void)itemAdd;
-(void) mainScreenActions: (NSInteger) buttonIndex;
@property (nonatomic, weak) id<EasyViewControllerDelegate> delegate;

@end
