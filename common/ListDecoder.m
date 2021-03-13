//
//  MessageDecoder.m
//  EasyGrocList
//
//  Created by Ninan Thomas on 9/27/15.
//  Copyright (c) 2015 Ninan Thomas. All rights reserved.
//

#import "AppCmnUtil.h"
#import "ListDecoder.h"
#import "LocalMasterList.h"
#import "ItemKey.h"
#import "LocalList.h"
#import "common.h"

@implementation ListDecoder

-(instancetype) init
{
    self = [super init];
    return self;
}


-(bool) decodeMessage:(char*)buffer msglen:(ssize_t)mlen
{
    [super decodeMessage:buffer msglen:mlen];
   
    bool bRet = true;
    int msgTyp;
    memcpy(&msgTyp, buffer+sizeof(int), sizeof(int));
    
    switch (msgTyp)
    {
       
            
        case SHARE_ITEM_MSG:
        {
            bRet = [self processShareItemMessage:buffer msglen:mlen];
        }
        break;
            
        case SHARE_TEMPL_ITEM_MSG:
        {
            bRet = [self processShareTemplItemMessage:buffer msglen:mlen];
        }
        break;

        default:
            break;
    }
    
    return bRet;
}

/*
 NSString *const keyValSeparator = @":|:";
 
 NSString *const contactItemSeperator = @":::";
 
 NSString *const itemSeparator = @"]:;";
 
 NSString *const templListSeperator = @":;]:;";
 */

-(bool) processShareTemplItemMessage:(char *)buffer msglen:(ssize_t)mlen
{
    NSString *name = [NSString stringWithCString:(buffer + 4*sizeof(int) + sizeof (long long)) encoding:NSASCIIStringEncoding];
    int namelen = 0;
    memcpy(&namelen, buffer + 2*sizeof(int) + sizeof (long long),  sizeof(int));
    long long share_id = 0;
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
   
    
    NSString *list = [NSString stringWithCString:(buffer + 4*sizeof(int) + namelen + sizeof(long long)) encoding:NSASCIIStringEncoding];
    NSLog(@"Received from server list=%@ share_id=%lld name=%@ %s %d", list, share_id, name, __FILE__, __LINE__ );
    
    NSArray *listcomps = [list componentsSeparatedByString:templListSeperator];
    NSUInteger comps = [listcomps count];
    bool bAddName = false;
    for (NSUInteger j=0; j < comps; ++j)
    {
       

        NSArray *listItems = [[listcomps objectAtIndex:j] componentsSeparatedByString:itemSeparator];
        NSMutableDictionary *itemMp;
        itemMp = [[NSMutableDictionary alloc] init];
        NSUInteger cnt = [listItems count];
        NSString *adjstedname = name;
        if (j == 2)
            adjstedname= [name stringByAppendingString:@":INV"];
        else if (j==3)
            adjstedname = [name stringByAppendingString:@":SCRTCH"];
        

        if (!cnt)
            continue;
        for (NSUInteger i=0; i < cnt; ++i)
        {
            NSString *itemrow = [listItems objectAtIndex:i];
            NSArray *itemrowarr = [itemrow componentsSeparatedByString:keyValSeparator];
           if (!j)
           {
               NSString *shIdStr = [itemrowarr objectAtIndex:0];
                share_id =[shIdStr longLongValue];
                   continue;
           }
            NSUInteger cnt1 = [itemrowarr count];
            if (cnt1 != 5)
            {
                NSLog(@"Invalid cnt1 %lu %lu", (unsigned long)cnt1, (unsigned long)i);
                continue;
            }
            [self populateMasterListItem:itemrowarr adjName:adjstedname shId:share_id items:itemMp];
        }
        
        bool bNewItem = [self isNewItem:name shid:share_id];
        ItemKey *itk = [[ItemKey alloc] init];
        itk.name   = adjstedname;
        itk.share_id = share_id;
        
        if (bNewItem)
        {
            if (!bAddName)
            {
                [pAppCmnUtil.dataSync addTemplName:itk];
                bAddName = true;
            }
            [pAppCmnUtil.dataSync addTemplItem:itk itemsDic:itemMp];
        }
        else
        {
            [pAppCmnUtil.dataSync editedTemplItem:itk itemsDic:itemMp];
        }
    }
    
    return true;
}

-(bool) isNewItem:(NSString*) name shid:(long long )share_id
{
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    NSArray *pMasterListNames = [pAppCmnUtil.dataSync getMasterListNames];
    NSUInteger cnt = [pMasterListNames count];
    bool bNewItem = true;
    for (NSUInteger i=0; i < cnt ; ++i)
    {
        ItemKey *itk = [pMasterListNames objectAtIndex:i];
        if ([name isEqualToString:itk.name] && share_id == itk.share_id)
        {
            bNewItem = false;
            break;
        }
    }
    return bNewItem;
}


-(void) populateMasterListItem:(NSArray *)itemrowarr adjName:(NSString *)adjstedname shId:(long long) share_id items:(NSMutableDictionary *)itemMp
{
    LocalMasterList *mitem = [[LocalMasterList alloc] init];
    NSString *rownoStr = [itemrowarr objectAtIndex:0];
    long long rowno1 = [rownoStr longLongValue];
    NSNumber *rowno = [NSNumber numberWithLongLong:rowno1];
    mitem.rowno = rowno1;
    NSString *startMonthStr = [itemrowarr objectAtIndex:1];
    mitem.startMonth = [startMonthStr intValue];
    mitem.endMonth = [[itemrowarr objectAtIndex:2] intValue];
    mitem.inventory = [[itemrowarr objectAtIndex:3] intValue];
    mitem.name = adjstedname;
    mitem.share_id = share_id;
    mitem.item = [itemrowarr objectAtIndex:4];
    
    [itemMp setObject:mitem forKey:rowno];

}

-(bool) processShareItemMessage:(char *)buffer msglen:(ssize_t)mlen
{
    int namelenoffset = 2*sizeof(int) + sizeof(long long);
    NSLog(@"namelenoffset %d  %s %d", namelenoffset, __FILE__, __LINE__);
    NSString *name = [NSString stringWithCString:(buffer + 4*sizeof(int) +sizeof(long long)) encoding:NSASCIIStringEncoding];
    
    int namelen = 0;
    memcpy(&namelen, buffer + namelenoffset, sizeof(int));
    long long share_id = 0;
    memcpy(&share_id, buffer+2*sizeof(int), sizeof(long long));
    
    ItemKey *itk  = [[ItemKey alloc] init];
    itk.name = name;
    
    int listoffset = 4*sizeof(int) + namelen +sizeof(long long);
    NSString *list = [NSString stringWithCString:(buffer + listoffset) encoding:NSASCIIStringEncoding];
   
    
    NSArray *listItems = [list componentsSeparatedByString:itemSeparator];
    NSMutableDictionary *itemMp;
    itemMp = [[NSMutableDictionary alloc] init];
    NSUInteger cnt = [listItems count];
    
    for (NSUInteger i=0; i < cnt; ++i)
    {
        
        NSString *itemrow = [listItems objectAtIndex:i];
        NSArray *itemrowarr = [itemrow componentsSeparatedByString:keyValSeparator];
        NSUInteger cnt1 = [itemrowarr count];
        if (cnt1 != 2)
            continue;
        NSString *rownoStr = [itemrowarr objectAtIndex:0];
        NSString *item = [itemrowarr objectAtIndex:1];
        if (!i)
        {
            itk.share_id =[rownoStr longLongValue];
            continue;
        }
        long long rowno1 = [rownoStr longLongValue];
        NSNumber *rowno = [NSNumber numberWithLongLong:rowno1];
        LocalList *litem = [[LocalList alloc] init];
        litem.name = name;
        litem.item = item;
        litem.share_id = share_id;
        litem.rowno = rowno1;
        [itemMp setObject:litem forKey:rowno];
    }
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
   
    NSArray *pListNames = [pAppCmnUtil.dataSync getListNames];
    cnt = [pListNames count];
    bool bNewItem = true;
     NSLog (@"Received from shareId=%lld name=%@ item=%@ bNewItem=%d", share_id , name, list, bNewItem);
    for (NSUInteger i=0; i < cnt ; ++i)
    {
        ItemKey *key = [pListNames objectAtIndex:i];
        if ([name isEqualToString:key.name] && share_id == key.share_id)
        {
            bNewItem = false;
            break;
        }
    }
    if (bNewItem)
    {
        [pAppCmnUtil.dataSync addItem:itk itemsDic:itemMp];
    }
    else
    {
        [pAppCmnUtil.dataSync editItem:itk itemsDic:itemMp];
    }
    return true;
}


@end
