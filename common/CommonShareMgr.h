//
//  OpenHousesShareMgr.h
//  Shopper
//
//  Created by Ninan Thomas on 2/17/16.
//
//

#import <Foundation/Foundation.h>
#import <sharing/ShareMgr.h>

@protocol CommonShareMgrDelegate <NSObject>

-(void) decodeAndStoreItem :(NSString *) ItemStr;


@end


@interface CommonShareMgr : ShareMgr
{
       
}


- (instancetype)init;

@property (nonatomic, weak) id<CommonShareMgrDelegate> delegate;

-(void) processItem:(NSString *)itemStr;


@end
