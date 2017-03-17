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
    
    
    
    
    NSMutableArray *listMps;
    NSMutableArray *listEditNames;
    NSMutableArray *listEditMps;
    NSMutableArray *listHiddenMps;
    
   
    NSMutableArray *listDeletedNames;
    NSCondition *workToDo;
   
    NSMutableArray *masterListNamesArr;
    
    
  
    
        
    //the two parameters below are used to update the selected item in the list for apple watch
    NSString *selectedItem;
    bool itemSelectedChanged;

    
    int itemsToAdd;
    
    int itemsEdited;
    int itemsHidden;
    
    
    int itemsDeleted;
    int inapp_skip_count;
    
}



@property (nonatomic) bool refreshMainLst;

@property (nonatomic) bool inAppCancelTimer;
-(void) addTemplItem:(NSString *)name itemsDic:(NSMutableDictionary*) itmsMp;
-(void) addItem:(NSString *)name itemsDic:(NSMutableDictionary*) itmsMp;
-(void) editItem:(NSString *)name itemsDic:(NSMutableDictionary*) itmsMp;
-(void) hiddenItems:(NSString *)name itemsDic:(NSMutableDictionary*) itmsMp hiddenDic:(NSMutableDictionary*) hiddensMp;



-(void) deletedItem:(NSString *)name;
-(void) lock;
-(void) unlock;
-(NSArray *) getListNames;
-(NSDictionary *) getPics;
-(NSArray *) getMasterList: (NSString *)key;

-(void) selectedItem: (NSString *) selectedItem;

@end
