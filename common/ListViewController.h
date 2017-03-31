//
//  ListViewController.h
//  EasyGrocList
//
//  Created by Ninan Thomas on 4/2/13.
//  Copyright (c) 2013 Ninan Thomas. All rights reserved.
//

#import <UIKit/UIKit.h>




enum eViewMode {
    eViewModeDisplay,
    eViewModeEdit,
    eViewModeAdd
    };

enum eEasyGrocType {
    eRecurrngLst,
    eInvntryLst,
    eScratchLst
};

@interface ListViewController : UITableViewController <UITextFieldDelegate, UIActionSheetDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
{
    bool inEditAction;
    NSInteger textFldRowNo;
    NSMutableDictionary *rowTarget;
    NSUInteger seasonPickerRowNo;
    NSArray *_pickerData;
    NSInteger startMonth;
    NSInteger endMonth;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *mlistName;
@property (nonatomic, retain) NSString *default_name;
@property (nonatomic, retain) NSMutableDictionary *itemMp;
@property enum eViewMode editMode;
@property enum eEasyGrocType easyGrocLstType;
@property NSUInteger nRows;
@property (nonatomic, retain) NSArray* mlist;
@property (nonatomic, retain) UIPickerView *seasonPicker;

-(void) refreshMasterList;
-(void) refreshMasterListCpyFromLstVwCntrl:(ListViewController *) pLst;
-(void) DeleteConfirm;
-(void) addRow : (NSUInteger) rowNo;
-(void) cleanUpItemMp;
-(void) templItemEditCancel;
- (void) templItemEditDone;
- (void)templItemAddDone;
-(void) templItemDisplay:(NSString *)templ_name lstcntr:(ListViewController *) pLst;
- (void)templItemEdit;
-(void) showSeasonPicker : (NSUInteger) rowNo;

@end