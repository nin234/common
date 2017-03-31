//
//  AppCmnUtil.h
//  common
//
//  Created by Ninan Thomas on 3/12/17.
//  Copyright © 2017 Sinacama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataOps.h"
#import "EasyViewController.h"

enum eEditActionItems
{
    eSaveList,
    eDeleteList
};

@interface AppCmnUtil : NSObject

@property (nonatomic, retain) DataOps *dataSync;
@property (nonatomic, retain) UINavigationController *navViewController;
@property (nonatomic, retain) NSString *listName;
@property bool bEasyGroc;

@property (nonatomic, retain) NSFileManager *pFlMgr;
@property (nonatomic, retain) NSURL *pThumbNailsDir;
@property (nonatomic, retain) NSURL *pPicsDir;
@property (nonatomic, retain) EasyViewController *aViewController1;
@property (nonatomic, retain) NSMutableDictionary* itemsMp;

+ (instancetype)sharedInstance;

-(void) popView;

-(void) showPicList:(NSString *)name pictName:(NSString *)picName imagePicker:(UIImagePickerController *) imagePick;

@end
