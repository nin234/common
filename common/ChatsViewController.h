//
//  ChatsViewController.h
//  smartmsg
//
//  Created by Ninan Thomas on 2/19/18.
//  Copyright © 2018 Nshare. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChatsViewControllerDelegate<NSObject>

@optional

-(void) showContactsSelectViewForNewChats;
@end


@interface ChatsViewController : UITableViewController
{
    NSArray *chatHeaders;
    NSMutableDictionary *frndDic;
}

@property (nonatomic, weak) id<ChatsViewControllerDelegate> delegate;
@end
