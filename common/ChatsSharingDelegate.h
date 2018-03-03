//
//  SharingDelegate.h
//  smartmsg
//
//  Created by Ninan Thomas on 2/19/18.
//  Copyright © 2018 Nshare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sharing/ContactsViewController.h>
#import <sharing/ShareMgr.h>


@interface ChatsSharingDelegate : NSObject<ContactsViewControllerDelegate, ShareMgrDelegate>

-(void) launchChat:(FriendDetails *) frnd;
-(NSURL *) getPicUrl:(long long ) shareId picName:(NSString *) name itemName:(NSString *) iName;
-(void) storeThumbNailImage:(NSURL *)picUrl;
-(void) setShareId : (long long) shareId;
-(void) shareNow:(NSString *) shareStr;
-(void) refreshShareMainLst;

@end
