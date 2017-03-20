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
    
    
    
    
      
    NSCondition *workToDo;
   
    NSMutableArray *masterListNamesArr;
    
    
  
    
        
    
    int itemsToAdd;
    
    
    
    
    
    
    int inapp_skip_count;
    
}





@property (nonatomic) bool inAppCancelTimer;







-(void) lock;
-(void) unlock;





@end
