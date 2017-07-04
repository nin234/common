//
//  LocalList.m
//  common
//
//  Created by Ninan Thomas on 5/22/17.
//  Copyright © 2017 Sinacama. All rights reserved.
//

#import "LocalList.h"
#import "List.h"

@implementation LocalList

@synthesize rowno;
@synthesize name;
@synthesize item;
@synthesize date;
@synthesize hidden;
@synthesize share_id;

-(id) copyFromList:(List *)list
{
    self.rowno = list.rowno;
    self.name = list.name;
    self.item = list.item;
    self.date = list.date;
    self.hidden = list.hidden;
    self.share_id = list.share_id;
    
    return self;
}

-(instancetype) initFromList:(List *)list
{
    if (self)
    {
        self.rowno = list.rowno;
        self.name = list.name;
        self.item = list.item;
        self.date = list.date;
        self.hidden = list.hidden;
        self.share_id   = list.share_id;
        return self;
    }
    return nil;
}

@end
