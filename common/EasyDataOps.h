//
//  EasyDataOps.h
//  EasyGrocList
//
//  Created by Ninan Thomas on 4/5/13.
//  Copyright (c) 2013 Ninan Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EasyDataOps : NSThread
{
    NSMutableArray *masterListNames;
    NSMutableArray *masterListMps;
    NSMutableArray *listNames;
    NSMutableArray *listPicNames;
    NSMutableArray *listPicUrls;
    NSMutableArray *listMps;
    NSMutableArray *listEditNames;
    NSMutableArray *listEditMps;
    NSMutableArray *listHiddenMps;
    NSMutableArray *masterListEditNames;
    NSMutableArray *masterListEditMps;
    NSMutableArray *masterListDeletedNames;
    NSMutableArray *listDeletedNames;
    NSCondition *workToDo;
    NSArray *masterListNamesTmp;
    NSArray *masterListTmp;
    NSArray *listNamesTmp;
    NSArray *listTmp;
    NSMutableArray *masterListNamesArr;
    NSMutableDictionary *masterListArr;
    
    //array of the list names
    NSMutableArray *listNamesArr;
    
    //dictionary of list names as key and the actual list as the value
    NSMutableDictionary *listArr;
    NSMutableDictionary *picDic;
    
    //the two parameters below are used to update the selected item in the list for apple watch
    NSString *selectedItem;
    bool itemSelectedChanged;

    int templItemsToAdd;
    int itemsToAdd;
    int picItemsToAdd;
    int itemsEdited;
    int itemsHidden;
    int templItemsEdited;
    int templItemsDeleted;
    int itemsDeleted;
    int inapp_skip_count;
    
}

@property NSInteger masterListCnt;
@property NSInteger listCnt;
@property (nonatomic) bool refreshMainLst;

@property (nonatomic) bool inAppCancelTimer;
-(void) addTemplItem:(NSString *)name itemsDic:(NSMutableDictionary*) itmsMp;
-(void) addItem:(NSString *)name itemsDic:(NSMutableDictionary*) itmsMp;
-(void) addPicItem:(NSString *)name picItem:(NSString *)picUrl;
-(void) editItem:(NSString *)name itemsDic:(NSMutableDictionary*) itmsMp;
-(void) hiddenItems:(NSString *)name itemsDic:(NSMutableDictionary*) itmsMp hiddenDic:(NSMutableDictionary*) hiddensMp;

-(void) editedTemplItem:(NSString *)name itemsDic:(NSMutableDictionary*) itmsMp;
-(void) deletedTemplItem:(NSString *)name;
-(void) deletedItem:(NSString *)name;
-(void) lock;
-(void) unlock;
-(NSArray *) getMasterListNames;
-(NSArray *) getListNames;
-(NSDictionary *) getPics;
-(NSArray *) getMasterList: (NSString *)key;
-(NSArray *) getList: (NSString *)key;
-(void) selectedItem: (NSString *) selectedItem;

@end
