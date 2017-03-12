//
//  EasyViewController.h
//  EasyGrocList
//
//  Created by Ninan Thomas on 3/5/13.
//  Copyright (c) 2013 Ninan Thomas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EasyListViewController.h"

@interface EasyViewController : UIViewController <UISearchBarDelegate>

@property (strong, nonatomic) EasyListViewController *pAllItms;
@property (strong, nonatomic) UISearchBar *pSearchBar;
@property (nonatomic) bool bShareView;

- (void)enableCancelButton:(UISearchBar *)aSearchBar;

@end
