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
}

-(void) refreshMasterList;

@property (nonatomic, weak) id<TemplListViewControllerDelegate> delegate;

@property bool bShareTemplView;
-(ItemKey *) getSelectedItem;
@property bool bCheckListView;

@end
