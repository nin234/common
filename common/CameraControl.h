//
//  CameraControl.h
//  common
//
//  Created by Ninan Thomas on 4/15/18.
//  Copyright © 2018 Sinacama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MySlider.h"

@protocol CameraControlDelegate <NSObject>

-(void) saveQAdd:(NSInvocationOperation*) theOp;
-(void) imageFurtherAction:(NSURL *) imgUrl thumbUrl:(NSURL *) turl;
-(void) movieFurtherAction:(NSURL *) imgUrl thumbUrl:(NSURL *) turl;

@end

@interface CameraControl : NSObject<UIImagePickerControllerDelegate>
{
    bool bInPicCapture;
    bool bSaveLastPic;
    bool bInShowCam;
    struct timeval last_mode_change;
    NSString *pImgsDir;
    NSString *pThumbNailsDir;
}

@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic, retain) MySlider *pSlider;
@property bool bSliderPic;
@property (strong, nonatomic) UIBarButtonItem *pBarItem;
@property (strong, nonatomic) UIBarButtonItem *pBarItem3;
-(void) showCamera:(UIViewController *) parentVwCntrl;
@property (nonatomic, retain) id<CameraControlDelegate> delegate;

@end
