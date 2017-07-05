//
//  LocalMasterList.m
//  EasyGrocList
//
//  Created by Ninan Thomas on 4/5/13.
//  Copyright (c) 2013 Ninan Thomas. All rights reserved.
//

#import "LocalMasterList.h"
#import "MasterList.h"

@implementation LocalMasterList

@synthesize  name;
@synthesize  item;
@synthesize  rowno;
@synthesize  startMonth;
@synthesize  endMonth;
@synthesize  inventory;
@synthesize share_id;

-(instancetype) initFromMasterList:(MasterList *)mlist
{
    if (self)
    {
        self.rowno = mlist.rowno;
        self.name = mlist.name;
        self.item = mlist.item;
        self.startMonth = mlist.startMonth;
        self.endMonth = mlist.endMonth;
        self.inventory = mlist.inventory;
        self.share_id   = mlist.share_id;
        return self;
    }
    return nil;

}

@end
