//
//  TemplListViewController.h
//  EasyGrocList
//
//  Created by Ninan Thomas on 4/28/13.
//  Copyright (c) 2013 Ninan Thomas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppCmnUtil.h"

@protocol TemplListViewControllerDelegate <NSObject>

-(AppCmnUtil *) getAppCmnUtil;

@end


@interface TemplListViewController : UITableViewController<UIAlertViewDelegate>
{
    NSInteger cnt;
    NSArray *masterList;
}

-(void) refreshMasterList;

@property (nonatomic, weak) id<TemplListViewControllerDelegate> delegate;

@end
