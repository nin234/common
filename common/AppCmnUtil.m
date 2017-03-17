//
//  AppCmnUtil.m
//  common
//
//  Created by Ninan Thomas on 3/12/17.
//  Copyright © 2017 Sinacama. All rights reserved.
//

#import "AppCmnUtil.h"
#import "ListViewController.h"
#import "TemplListViewController.h"
#import "EasyDisplayViewController.h"

@implementation AppCmnUtil

@synthesize dataSync;
@synthesize navViewController ;
@synthesize mlistName;
@synthesize bEasyGroc;
@synthesize pFlMgr;
@synthesize pPicsDir;
@synthesize pThumbNailsDir;
@synthesize aViewController1;
@synthesize listName;

-(instancetype) init
{
    self = [super init];
    if (self)
    {
        mlistName = [[NSString alloc] init];
        return self;

    }
    
    return nil;
    
}

-(void) showPicList:(NSString *)name pictName:(NSString *)picName imagePicker:(UIImagePickerController *) imagePick
{
    [imagePick dismissViewControllerAnimated:NO completion:^{
        [self popView];
        EasyDisplayViewController *photoVwCntrl = [EasyDisplayViewController alloc];
        photoVwCntrl.picName = picName;
        photoVwCntrl.listName = name;
        photoVwCntrl = [photoVwCntrl initWithNibName:nil bundle:nil];
        [self.navViewController pushViewController:photoVwCntrl animated:YES];
    }];
    
    return;
}

+ (instancetype)sharedInstance
{
    static AppCmnUtil *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AppCmnUtil alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

-(void) popView
{
    //putchar('N');
    [self.navViewController popViewControllerAnimated:NO];
   
}



@end
