//
//  ChatsDBIntf.m
//  common
//
//  Created by Ninan Thomas on 3/2/18.
//  Copyright © 2018 Sinacama. All rights reserved.
//

#import "ChatsDBIntf.h"

@implementation ChatsDBIntf

@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    return;
}

-(bool) chatExists:(FriendDetails *) contact
{
    NSManagedObjectContext *moc = self.managedObjectContext;
    NSEntityDescription *descr = [NSEntityDescription entityForName:@"ChatsHeader" inManagedObjectContext:moc];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:descr];
    [req setPredicate:[NSPredicate predicateWithFormat:@"from == %@ OR to == %@", [NSNumber numberWithLongLong:[contact.name longLongValue]]]];
    NSError *error = nil;
    NSArray *chatsHeaders = [moc executeFetchRequest:req error:&error];
    if (chatsHeaders == nil || [chatsHeaders count] == 0)
    {
        return false;
    }
    return true;
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *)managedObjectContext {
    
    NSLog(@"getting moc");
    
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    NSLog(@"getting moc1");
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil)
    {
        // Make life easier by adopting the new NSManagedObjectContext concurrency API
        // the NSMainQueueConcurrencyType is good for interacting with views and controllers since
        // they are all bound to the main thread anyway
        NSManagedObjectContext* moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        
        [moc performBlockAndWait:^{
            // even the post initialization needs to be done within the Block
            [moc setPersistentStoreCoordinator: coordinator];
            
        }];
        __managedObjectContext = moc;
    }
    [__managedObjectContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
    return __managedObjectContext;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    NSLog(@"getting psc");
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    NSLog(@"getting psc1");
    NSError *error = nil;
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"chatsdb.sqlite"];
    
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSLog(@"Setting URL to %@", storeURL);
    
    
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        
        
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        
        UIAlertView *pAvw = [[UIAlertView alloc] initWithTitle:@"System error" message:@"Restart the app. If Delete the app and reinstall and  restart." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [pAvw show];
    }
    return __persistentStoreCoordinator;
    
    
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"chatsdb" withExtension:@"momd"];
    NSLog(@"Setting modelURL to %@", modelURL);
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
    
    
}


#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
