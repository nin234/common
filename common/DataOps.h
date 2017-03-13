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

@protocol DataOpsDelegate <NSObject>

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
@optional
-(NSString *)getAddtionalPredStr:(NSUInteger) scnt predStrng:(NSString *)predStr;
-(bool ) isEqualToLclItem:(id) item local:(id) litem;
-(MainViewController *) getMainViewController;

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
}

-(void) main;

@property(nonatomic) dispatch_queue_t shareQ;
@property (nonatomic) bool dontRefresh;
@property (nonatomic) bool refreshNow;
@property (nonatomic) bool updateNow;
@property (nonatomic) bool loginNow;
@property (nonatomic) bool updateNowSetDontRefresh;

-(void) lock;
-(void) unlock;
 

-(void) addItem:(id)item;
-(void) editedItem:(id)item;
-(void) deletedItem: (id)item;

@property (nonatomic, weak) id<DataOpsDelegate> delegate;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
-(NSString *) getAlbumName:(long long ) shareId itemName:(NSString *) iName;
-(bool) isNewItem:(id) item;
-(NSArray *) getMasterListNames

@end
