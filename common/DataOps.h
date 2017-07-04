//
//  DataOps.h
//  Shopper
//
//  Created by Ninan Thomas on 11/17/12.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "MainViewController.h"
#import "ItemKey.h"


@protocol DataOpsDelegate <NSObject>

@optional
-(bool) updateEditedItem:(id) item local:(id) litem;
-(NSString *) getAlbumName:(id) item;
-(id) getNewItem:(NSEntityDescription *) entity context:(NSManagedObjectContext *) managedObjectContext;
-(void) addToCount;
-(void) copyFromLocalItem:(id) item local:(id)litem;
-(NSString *) getSearchStr;
-(NSString *) sortDetails:(bool *)ascending;
-(id) getLocalItem;
-(void) copyFromItem:(id) itm local:(id)litm;

-(NSString *)getAlbumName:(long long) shareId itemName:(NSString *) name item:(id)itm;

-(NSString *)getAddtionalPredStr:(NSUInteger) scnt predStrng:(NSString *)predStr;
-(int ) getAdditionalPredArgs;
-(bool ) isEqualToLclItem:(id) item local:(id) litem;
-(MainViewController *) getMainViewController;
-(NSString *) getEntityName;


@end

@interface DataOps: NSThread<UIAlertViewDelegate> 
{
    NSMutableArray *newItems;
    NSCondition *workToDo;
    NSLock *dbLock;
    int itemsToAdd;
    int itemsEdited;
    int itemsDeleted;
    int itemsToShare;
    int itemsToDownloadOnStartUp;
    int itemsToDownload;
    NSMutableArray *editedItems;
    NSMutableArray *deletedItems;
     NSMutableArray *seletedItems;
    NSMutableArray *sharedItems;
    NSMutableArray *downloadIds;
     NSArray *indexes;
     NSMutableArray *itemNames;
    
    NSMutableArray *seletedItemsTmp;
    NSMutableArray *indexesTmp;
     NSArray *itemNamesTmp;
    
    NSArray *unFilteredItemsTmp;
    NSMutableArray *unFilteredItems;
    
    bool bInitRefresh;
    bool forceRefresh;
    NSDate *refreshTime;
    dispatch_queue_t shareQ;
    bool bInUpload;
    bool bInDownload;
    bool bInStartUpDownload;
    bool bRedColor;
    int waitTime;
    bool bAnimateNow;
    bool bAnimateOnDwld;
    bool bAnimateOnStrtUp;
    bool bShowSelfHelp;
    UIBackgroundTaskIdentifier upldBkTaskId;
    UIBackgroundTaskIdentifier dwldBkTaskId;
    UIBackgroundTaskIdentifier dwldStrtUpTaskId;
    UIBackgroundTaskIdentifier loginTaskId;
    
    NSMutableArray *masterListNamesArr;
     NSArray *masterListNamesTmp;
    NSArray *masterListTmp;
    NSMutableDictionary *masterListArr;
    int templItemsToAdd;
    int templShareItemsToAdd;
    NSMutableArray *masterListNames;
    NSMutableArray *shareMasterListNames;
    NSMutableArray *masterListMps;
    NSMutableArray *shareMasterListMps;
    NSMutableArray *masterListEditNames;
    NSMutableArray *masterListEditMps;
    int templItemsEdited;
     NSMutableArray *masterListDeletedNames;
    int templItemsDeleted;
    NSMutableArray *listNames;
    NSMutableArray *listPicUrls;
    int picItemsToAdd;
    NSMutableArray *listPicNames;
    NSArray *listNamesTmp;
    //array of the list names
    NSMutableArray *listNamesArr;
     NSMutableDictionary *picDic;
    NSArray *listTmp;
    //dictionary of list names as key and the actual list as the value
    NSMutableDictionary *listArr;
    int easyItemsToAdd;
    NSMutableArray *listMps;
    //the two parameters below are used to update the selected item in the list for apple watch
    NSString *selectedItem;
    bool itemSelectedChanged;
    NSMutableArray *listEditNames;
    NSMutableArray *listEditMps;
    NSMutableArray *listHiddenMps;
    int itemsHidden;
    int itemsEasyEdited;
    int itemsEasyDeleted;
     NSMutableArray *listDeletedNames;
    
    int templNameItemsToAdd;
    NSMutableArray *masterListNamesOnly;
   
}

-(void) main;
@property NSInteger listCnt;
@property(nonatomic) dispatch_queue_t shareQ;

@property (nonatomic) bool refreshNow;
@property (nonatomic) bool updateNow;
@property (nonatomic) bool loginNow;



-(void) lock;
-(void) unlock;
@property NSInteger masterListCnt;
 

-(void) addItem:(id)item;
-(void) editedItem:(id)item;
-(void) deletedItem: (id)item;

-(void) addItem:(ItemKey *)name itemsDic:(NSMutableDictionary*) itmsMp;

@property (nonatomic, weak) id<DataOpsDelegate> delegate;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (readonly, strong, nonatomic) NSManagedObjectContext *easyManagedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *easyManagedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *easyPersistentStoreCoordinator;

@property (nonatomic, retain) UINavigationController *navViewController;
@property (nonatomic, retain) NSString *appName;
@property (nonatomic) bool refreshMainLst;

- (void)saveContext;
-(NSString *) getAlbumName:(long long ) shareId itemName:(NSString *) iName;
-(bool) isNewItem:(id) item;
-(NSArray *) getMasterListNames;
- (void)saveEasyContext;
-(NSArray *) getMasterList: (NSString *)key;
-(void) addTemplItem:(NSString *)name itemsDic:(NSMutableDictionary*) itmsMp;
-(void) addShareTemplItem:(NSString *)name itemsDic:(NSMutableDictionary*) itmsMp;
-(void) editedTemplItem:(NSString *)name itemsDic:(NSMutableDictionary*) itmsMp;
-(void) deletedTemplItem:(NSString *)name;
-(void) addPicItem:(NSString *)name picItem:(NSString *)picUrl;
-(NSArray *) getList: (NSString *)key;
-(void) selectedItem: (NSString *) selectedItem;
-(void) hiddenItems:(NSString *)name itemsDic:(NSMutableDictionary*) itmsMp hiddenDic:(NSMutableDictionary*) hiddensMp;
-(void) editItem:(ItemKey *)name itemsDic:(NSMutableDictionary*) itmsMp;
-(void) deletedEasyItem:(NSString *)name;
-(NSArray *) getListNames;
-(NSDictionary *) getPics;
-(void) addTemplName:(NSString *)name;
-(bool) checkMlistNameExist:(NSString *)name;


@end
