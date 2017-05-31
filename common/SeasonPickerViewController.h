//
//  SeasonPickerViewController.h
//  common
//
//  Created by Ninan Thomas on 5/29/17.
//  Copyright © 2017 Sinacama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocalMasterList.h"

@interface SeasonPickerViewController : UITableViewController<UIPickerViewDelegate, UIPickerViewDataSource>
{
    NSArray *_pickerData;
    NSInteger startMonth;
    NSInteger endMonth;

}

@property(nonatomic, retain) LocalMasterList *mitem;
@property (nonatomic, retain) UIPickerView *seasonPicker;

@end
