//
//  OpenHousesDecoder.m
//  Shopper
//
//  Created by Ninan Thomas on 2/17/16.
//
//

#import "CommonDecoder.h"
#import "CommonShareMgr.h"
#import "ItemKey.h"
#import "LocalList.h"
#import "AppCmnUtil.h"

@implementation CommonDecoder



-(instancetype) init
{
    self = [super init];
    return self;
}


-(bool) decodeMessage:(char*)buffer msglen:(ssize_t)mlen
{
    bool bRet = [super decodeMessage:buffer msglen:mlen];
    
    
    int msgTyp;
    memcpy(&msgTyp, buffer+sizeof(int), sizeof(int));
    
    switch (msgTyp)
    {
        
        case SHARE_ITEM_MSG:
        {
            bRet = [self processShareItemMessage:buffer msglen:mlen];
        }
        break;
            
                   
                   
        default:
            bRet = true;
            break;
    }
    

    
    return bRet;
    
}


-(bool) processShareItemMessage:(char *)buffer msglen:(ssize_t)mlen
{
   
    int namelen=0;
    memcpy(&namelen, buffer + 2*sizeof(int) + sizeof(long long), sizeof(int));
    NSString *list = [NSString stringWithCString:(buffer + 4*sizeof(int) + namelen + sizeof (long long)) encoding:NSASCIIStringEncoding];
    
    CommonShareMgr *pCmnShrMgr = (CommonShareMgr *)self.pShrMgr;
    
    NSArray *arr = [list componentsSeparatedByString:@"];;;]"];
    
    
    [pCmnShrMgr processItem:[arr objectAtIndex:0]];
    NSString *checkLst = [arr objectAtIndex:1];
    long long share_id =0;
    memcpy(&share_id, buffer +2*sizeof(int), sizeof(long long));
    NSString *name = [NSString stringWithCString:(buffer + 4*sizeof(int) + sizeof (long long)) encoding:NSASCIIStringEncoding];
    if (checkLst && [checkLst length])
    {
        
        ItemKey *itk  = [[ItemKey alloc] init];
        itk.name = name;
        itk.share_id = share_id;
        
        
        NSArray *listItems = [checkLst componentsSeparatedByString:@"]:;"];
        NSMutableDictionary *itemMp;
        itemMp = [[NSMutableDictionary alloc] init];
        NSUInteger cnt = [listItems count];
        
        for (NSUInteger i=0; i < cnt; ++i)
        {
            
            NSString *itemrow = [listItems objectAtIndex:i];
            NSArray *itemrowarr = [itemrow componentsSeparatedByString:@":"];
            NSUInteger cnt1 = [itemrowarr count];
            if (cnt1 != 3)
                continue;
            NSString *rownoStr = [itemrowarr objectAtIndex:0];
            NSString *item = [itemrowarr objectAtIndex:1];
            long long rowno1 = [rownoStr longLongValue];
            NSNumber *rowno = [NSNumber numberWithLongLong:rowno1];
            NSString *hiddenStr = [itemrowarr objectAtIndex:2];
            BOOL hidden = [hiddenStr boolValue];
            LocalList *litem = [[LocalList alloc] init];
            litem.name = name;
            litem.item = item;
            litem.share_id = share_id;
            litem.rowno = rowno1;
            litem.hidden = hidden;
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

    }
    return true;
}

@end
