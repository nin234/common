//
//  AppCmnUtil.h
//  common
//
//  Created by Ninan Thomas on 3/12/17.
//  Copyright © 2017 Sinacama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataOps.h"

@interface AppCmnUtil : NSObject

@property (nonatomic, retain) DataOps *dataSync;
@property (nonatomic, retain) UINavigationController *navViewController;
@property (nonatomic, retain) NSString *mlistName;

@end
