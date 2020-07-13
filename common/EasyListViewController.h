//
//  EasyListViewController.h
//  EasyGrocList
//
//  Created by Ninan Thomas on 3/5/13.
//  Copyright (c) 2013 Ninan Thomas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemKey.h"

/**
 <#Description#>
 */
@interface EasyListViewController : UITableViewController <UITextFieldDelegate>
{
    
    NSDictionary *picDic;
    NSArray *unFiltrdList;
    NSMutableArray *seletedItems;
}

@property (nonatomic, retain) NSArray *list;
@property (nonatomic) bool bShareView;

@property (nonatomic) bool itemSelected;


-(void) refreshList;

-(void) filter:(NSString *) str;
-(void) removeFilter;

-(ItemKey *) getSelectedItem;

@end
