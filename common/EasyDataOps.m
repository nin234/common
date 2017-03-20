//
//  EasyDataOps.m
//  EasyGrocList
//
//  Created by Ninan Thomas on 4/5/13.
//  Copyright (c) 2013 Ninan Thomas. All rights reserved.
//

#import "EasyDataOps.h"

#import "MasterList.h"



#import "EasyViewController.h"
#import "List1ViewController.h"

#define TIMER_INTERVAL_EasyDataOps 3
#define INAPP_SKIP_COUNT 40

@implementation EasyDataOps




@synthesize inAppCancelTimer;

-(void) main
{
    workToDo = [[NSCondition alloc]init];
    //refreshMainLst = false;
    inAppCancelTimer = false;
    
   
    
    
    
    
    
    inapp_skip_count = 0;
    
    
    
   
   
    
    
    
    
    
   
    bool bInitialMainScrnRefresh = false;
    
    for(;;)
        
    {
        [workToDo lock];
        if (  !itemsToAdd    || !inAppCancelTimer)
        {
            // NSLog(@"Waiting for work\n");
            if (bInitialMainScrnRefresh)
            {
                NSDate *checkTime = [NSDate dateWithTimeIntervalSinceNow:TIMER_INTERVAL_EasyDataOps];
                [workToDo waitUntilDate:checkTime];
            }
            else
            {
                NSDate *checkTime = [NSDate dateWithTimeIntervalSinceNow:0.1];
                [workToDo waitUntilDate:checkTime];
            }
            
        }
        [workToDo unlock];
    
                
        
                
     
                
        
       
               
                
       
    }
    return;
}









-(void) lock
{
    [workToDo lock];
    return;
}

-(void) unlock
{
    [workToDo unlock];
    return;
}


@end
