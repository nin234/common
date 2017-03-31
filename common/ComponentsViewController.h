//
//  ComponentsViewController.h
//  common
//
//  Created by Ninan Thomas on 3/25/17.
//  Copyright © 2017 Sinacama. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComponentsViewController : UITableViewController

@property (nonatomic, retain) NSString *masterListName;
@property (nonatomic, retain) NSString *masterInvListName;
@property (nonatomic, retain) NSString *masterScrathListName;
@property (nonatomic, retain) NSArray* mlist;
@property (nonatomic, retain) NSArray* mlistInv;
@property (nonatomic, retain) NSArray* mlistScrtch;

@end