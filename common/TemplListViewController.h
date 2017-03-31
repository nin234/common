//
//  TemplListViewController.h
//  EasyGrocList
//
//  Created by Ninan Thomas on 4/28/13.
//  Copyright (c) 2013 Ninan Thomas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListViewController.h"


enum templateNameButtons
{
    CANCEL_TEMPL_NAME_BUTTON,
    ADD_TEMPL_NAME_BUTTON
    
};

@interface TemplListViewController : UITableViewController<UIAlertViewDelegate>
{
    NSInteger cnt;
    NSArray *masterList;
}

-(void) refreshMasterList;


@end
