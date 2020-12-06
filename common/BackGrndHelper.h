//
//  BackGrndHelper.h
//  common
//
//  Created by Ninan Thomas on 12/3/20.
//  Copyright © 2020 nshare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BackgroundTasks/BackgroundTasks.h>

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(ios(13.0))
@interface BackGrndHelper : NSObject

@property (nonatomic, retain) BGTask *sharingBkgrndTsk;

@end

NS_ASSUME_NONNULL_END
