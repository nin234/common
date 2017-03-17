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

@interface ListViewController : UITableViewController <UITextFieldDelegate, UIActionSheetDelegate>
{
    bool inEditAction;
    NSInteger textFldRowNo;
    NSMutableDictionary *rowTarget;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *default_name;
@property (nonatomic, retain) NSMutableDictionary *itemMp;
@property enum eViewMode editMode;
@property NSUInteger nRows;
@property (nonatomic, retain) NSArray* mlist;


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

@end
