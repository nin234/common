//
//  TemplListViewController.h
//  EasyGrocList
//
//  Created by Ninan Thomas on 4/28/13.
//  Copyright (c) 2013 Ninan Thomas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListViewController.h"
#import "ItemKey.h"


@protocol TemplListViewControllerDelegate <NSObject>

-(void) templShareMgrStartAndShow;
-(void) shareContactsSetSelected;

@end

enum templateNameButtons
{
    CANCEL_TEMPL_NAME_BUTTON,
    ADD_TEMPL_NAME_BUTTON
    
};

@interface TemplListViewController : UITableViewController<UIAlertViewDelegate, UIActionSheetDelegate>
{
    NSInteger cnt;
    NSArray *masterList;
    NSMutableArray *seletedItems;
    bool uniqueNameAlert;
    ItemKey *itkDisp;
}

-(void) refreshMasterList;

@property (nonatomic, weak) id<TemplListViewControllerDelegate> delegate;

@property (nonatomic, retain) IBOutlet UINavigationController *navViewController;

@property (nonatomic, retain) ListViewController *recurrLst;
@property (nonatomic, retain) ListViewController *recurrLstDisp;
@property (nonatomic, retain) ListViewController *invLst;
@property (nonatomic, retain) ListViewController *invLstDisp;
@property (nonatomic, retain) ListViewController *scrtchLst;
@property (nonatomic, retain) ListViewController *scrtchLstDisp;

@property (nonatomic, retain) NSString *masterListName;
@property (nonatomic, retain) NSString *masterInvListName;
@property (nonatomic, retain) NSString *masterScrathListName;

@property bool bShareTemplView;
-(ItemKey *) getSelectedItem;
@property bool bCheckListView;
-(void) showScratchPad;
- (void) showRecurringList;
- (void) showInventoryList;
- (void)templItemEdit;
-(void) templItemEditCancel;
- (void) templItemEditDone;
-(void) templItemEditOHASpree;
@end
