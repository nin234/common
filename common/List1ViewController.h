//
//  List1ViewController.h
//  EasyGrocList
//
//  Created by Ninan Thomas on 5/19/13.
//  Copyright (c) 2013 Ninan Thomas. All rights reserved.
//

#import <UIKit/UIKit.h>

//#include <map>

enum eListMode
{
   eListModeDisplay,
   eListModeEdit,
   eListModeAdd
};

enum eDispActionItems
{
    eUndoHide,
    eRedoHide,
    eShowAll,
    eEditList
};


@interface List1ViewController : UITableViewController <UITextFieldDelegate, UIActionSheetDelegate, UISearchBarDelegate>
{
    NSUInteger nRows;
    NSArray* mlist;
    NSArray* list;
    bool bDicInit;
    NSDictionary *itemUnFiltrdMp;
    NSDictionary *hiddenUnFiltrdMp;
    NSDictionary *hiddenCellsUnFiltrdMp;
    
    
    NSMutableArray *undoArry;
    NSMutableArray *redoArry;
    bool inDeleteAction;
    bool inEditAction;
    bool bSearchStr;
    NSInteger textFldRowNo;
    NSMutableDictionary *rowTarget;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *default_name;
@property (nonatomic, retain) NSMutableDictionary *itemMp;
@property (nonatomic, retain) NSMutableDictionary *hiddenMp;
@property (nonatomic, retain) NSMutableDictionary *hiddenCells;

@property (nonatomic, retain) UISearchBar *pSearchBar;
@property enum eListMode editMode;

-(void) refreshMasterList;
-(void) refreshList;
-(void) refreshListFromCpy:(List1ViewController *)pLst;
-(void) DeleteConfirm;
- (void)enableCancelButton:(UISearchBar *)aSearchBar;
-(void) addRow : (NSUInteger) rowNo;
-(void) cleanUpItemMp;
- (void)itemAddDone;
- (void)itemEditDone;
//need a data structure clean up
@end
