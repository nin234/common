//
//  EasyAddViewController.h
//  EasyGrocList
//
//  Created by Ninan Thomas on 3/12/13.
//  Copyright (c) 2013 Ninan Thomas. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EasyAddViewController : UITableViewController <UIImagePickerControllerDelegate>
{
    NSInteger mcnt;
    NSArray *masterList;
}

@property (nonatomic, retain) UIImagePickerController *imagePickerController;

@end
