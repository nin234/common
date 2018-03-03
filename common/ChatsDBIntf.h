//
//  ChatsDBIntf.h
//  common
//
//  Created by Ninan Thomas on 3/2/18.
//  Copyright © 2018 Sinacama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import <sharing/FriendDetails.h>

@interface ChatsDBIntf : NSObject<UIAlertViewDelegate>

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

-(bool) chatExists:(FriendDetails *) contact;

@end
