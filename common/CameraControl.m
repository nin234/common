//
//  CameraControl.m
//  common
//
//  Created by Ninan Thomas on 4/15/18.
//  Copyright © 2018 Sinacama. All rights reserved.
//

#import "CameraControl.h"
#include <sys/time.h>
#include <MobileCoreServices/UTCoreTypes.h>
#include <MobileCoreServices/UTType.h>
#import "AVFoundation/AVAsset.h"
#import "AVFoundation/AVTime.h"
#import "CoreMedia/CMTime.h"
#import "AVFoundation/AVAssetImageGenerator.h"

@implementation CameraControl

@synthesize imagePickerController;
@synthesize bSliderPic;
@synthesize pSlider;
@synthesize pBarItem;
@synthesize pBarItem3;
@synthesize delegate;

-(instancetype) init
{
    self = [super init];
    if (self)
    {
        imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController = [[UIImagePickerController alloc] init];
        pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(takePhoto) ];
        pBarItem.width = 30;
        pSlider = [[MySlider alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        pSlider.continuous = NO;
        bSliderPic = true;
        [pSlider addTarget:self action:@selector(sliderUpdate:) forControlEvents:UIControlEventValueChanged];
        pSlider.minimumValueImage = [UIImage imageNamed:@"camera1.png"];//stretchableImageWithLeftCapWidth: 9 topCapHeight: 0];
        
        pSlider.maximumValueImage = [UIImage imageNamed:@"video.png"];//stretchableImageWithLeftCapWidth: 9 topCapHeight: 0];
        pSlider.thumbTintColor = [UIColor whiteColor];
        pSlider.minimumTrackTintColor = [UIColor redColor];
        pSlider.maximumTrackTintColor = [UIColor redColor];
        pBarItem3 = [[UIBarButtonItem alloc] initWithCustomView:pSlider];
        bInPicCapture = false;
        bSaveLastPic = false;
        bInShowCam = false;
        
        NSString *pHdir = NSHomeDirectory();
        NSString *pImgs = @"/Documents/images";
        pImgsDir = [pHdir stringByAppendingString:pImgs];
        NSString *pThumbNails = @"/Documents/images/thumbnails";
        pThumbNailsDir = [pHdir stringByAppendingString:pThumbNails];
        NSFileManager *pFlMgr = [[NSFileManager alloc] init];
         BOOL  bDirCr = [pFlMgr createDirectoryAtPath:pThumbNailsDir withIntermediateDirectories:YES attributes:nil error:nil];
        if (bDirCr == NO)
        {
            NSLog(@"Failed to created directories to store images");
        }
        return self;
    }
    
    return nil;
    
}

-(void) takePhoto
{
    NSLog(@"Slider value %f\n", pSlider.value);
    struct timeval tv;
    gettimeofday(&tv, 0);
    if (tv.tv_sec - last_mode_change.tv_sec < 2)
    {
        NSLog(@"too near the last mode change ignoring\n");
        return;
    }
    if (pSlider.value < 0.5)
    {
        if (bInPicCapture)
        {
            [imagePickerController stopVideoCapture];
            NSLog(@"Stopping video capture\n");
            //  pBarItem.enabled = NO;
            bInPicCapture = false;
        }
        else
        {
            
            [imagePickerController takePicture];
            // pBarItem.enabled = NO;
            pBarItem.tintColor =  [UIColor redColor];
            NSLog(@"Taking picture\n");
        }
    }
    else
    {
        //Show video camera icon
        if (bInPicCapture)
        {
            
            [imagePickerController stopVideoCapture];
            NSLog(@"Stopping video capture\n");
            pBarItem.tintColor = [UIColor blueColor];
            //  pBarItem.enabled = NO;
            bInPicCapture = false;
        }
        else
        {
            
            
            
            if ([imagePickerController startVideoCapture] == YES)
            {
                NSLog(@"Starting video capture\n");
                // pBarItem.tintColor = [UIColor redColor];
                
                pBarItem.tintColor =  [UIColor redColor];
                pBarItem.enabled = YES;
                bInPicCapture = true;
            }
            else
                NSLog(@"Start video capture failed\n");
        }
        
    }
}

- (void)sliderUpdate:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    float val = slider.value;
    NSLog(@"In slider update value %f\n", val);
    
    if (val < 0.5)
    {
        CGFloat barY, barHeight;
        NSLog(@"Setting camera toolbar bounds %f\n" , imagePickerController.cameraOverlayView.bounds.size.height);
        if (imagePickerController.cameraOverlayView.bounds.size.height > 500.00)
        {
            barY = imagePickerController.cameraOverlayView.bounds.size.height - 95;
            barHeight = 95;
        }
        else
        {
            barY = imagePickerController.cameraOverlayView.bounds.size.height - 55;
            barHeight = 55;
        }
        
        CGRect mainScrn = [UIScreen mainScreen].bounds;
        UIToolbar *bar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, barY, mainScrn.size.width, barHeight)];
        
        
        if (bInPicCapture)
        {
            [slider setValue:1.0 animated:YES];
            return;
        }
        if (pBarItem.enabled == NO)
        {
            if (!bSliderPic)
            {
                [slider setValue:1.0 animated:YES];
                return;
            }
        }
        // [imagePickerController dismissModalViewControllerAnimated:NO];
        pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(takePhoto) ];
        
        
        
        UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(photosDone) ];
        UIBarButtonItem *pBarItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil ];
        // pBarItem2.width = 100;
        UIBarButtonItem *pBarItem4 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil ];
        NSArray *baritems = [NSArray arrayWithObjects:pBarItem1, pBarItem2, pBarItem, pBarItem4, pBarItem3, nil];
        [bar setItems:baritems];
        [imagePickerController.cameraOverlayView addSubview:bar];
        imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        gettimeofday(&last_mode_change, 0);
    }
    else
    {
        CGFloat barY, barHeight;
        NSLog(@"Setting camera toolbar bounds %f\n" , imagePickerController.cameraOverlayView.bounds.size.height);
        barY = imagePickerController.cameraOverlayView.bounds.size.height - 55;
        barHeight = 55;
        
        CGRect mainScrn = [UIScreen mainScreen].bounds;
        UIToolbar *bar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, barY, mainScrn.size.width, barHeight)];
        
        
        if (pBarItem.enabled == NO)
        {
            if (bSliderPic)
            {
                [slider setValue:0.0 animated:YES];
                return;
            }
        }
        //   [imagePickerController dismissModalViewControllerAnimated:NO];
        pBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Record-Button-off.png"] style:UIBarButtonItemStylePlain target:self action:@selector(takePhoto)];
        
        
        
        UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(photosDone) ];
        UIBarButtonItem *pBarItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil ];
        // pBarItem2.width = 100;
        UIBarButtonItem *pBarItem4 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil ];
        NSArray *baritems = [NSArray arrayWithObjects:pBarItem1, pBarItem2, pBarItem, pBarItem4, pBarItem3, nil];
        [bar setItems:baritems];
        NSArray *pVws = [imagePickerController.cameraOverlayView subviews];
        NSUInteger cnt = [pVws count];
        for (NSUInteger i=0; i < cnt; ++i)
        {
            [[pVws objectAtIndex:i] removeFromSuperview];
        }
        [imagePickerController.cameraOverlayView addSubview:bar];
        imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
        gettimeofday(&last_mode_change, 0);
        
    }
}

-(void) saveImage:(UIImage *)image
{
    struct timeval tv;
    gettimeofday(&tv, 0);
    long filno = tv.tv_sec/2;
    NSString *pFlName = [[NSNumber numberWithLong:filno] stringValue];
    
    pFlName = [pFlName stringByAppendingString:@".jpg"];
    
    NSString *pFlPath = [pImgsDir stringByAppendingString:@"/"];
    pFlPath = [pFlPath stringByAppendingString:pFlName];
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    NSURL *imgurl = [NSURL URLWithString:pFlPath];
    if ([data writeToURL:imgurl atomically:YES] == NO)
    {
        printf("Failed to write to file %ld\n", filno);
        // --nAlNo;
        
    }
    else
    {
        NSLog(@"Save file %ld in album %s file %@\n", filno, [pImgsDir UTF8String], imgurl);
    }
    CGSize oImgSize;
    oImgSize.height = 71;
    oImgSize.width = 71;
    UIGraphicsBeginImageContext(oImgSize);
    [image drawInRect:CGRectMake(0, 0, oImgSize.width, oImgSize.height)];
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //  CGImageRef thumbnailImageRef = MyCreateThumbnailImageFromData (data, 5);
    // UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
    CGSize pImgSiz = [thumbnail size];
    NSLog(@"Added thumbnail Image height = %f width=%f \n", pImgSiz.height, pImgSiz.width);
    
    NSData *thumbnaildata = UIImageJPEGRepresentation(thumbnail, 0.3);
    NSString *pTmpNlFlPath = [pThumbNailsDir stringByAppendingString:@"/"];
    pTmpNlFlPath = [pTmpNlFlPath stringByAppendingString:pFlName];
    NSURL *thumburl = [NSURL URLWithString:pTmpNlFlPath];
    if ([thumbnaildata writeToURL:thumburl atomically:YES] == NO)
    {
        printf("Failed to write to thumbnail file %ld\n", filno);
        // --nAlNo;
        
    }
    else
    {
        NSLog(@"Save thumbnail file %ld in album %s file %@\n", filno, [pThumbNailsDir UTF8String], thumburl);
    }
    
    [delegate imageFurtherAction:imgurl thumbUrl:thumburl];
}

-(void) saveMovie:(NSURL *)movie
{
    struct timeval tv;
    gettimeofday(&tv, 0);
    long filno = tv.tv_sec/2;
    NSString *pFlName = [[NSNumber numberWithLong:filno] stringValue];
    NSString *pImgFlName = [pFlName stringByAppendingString:@".jpg"];
    
    pFlName = [pFlName stringByAppendingString:@".MOV"];
    NSString *pFlPath = [pImgsDir stringByAppendingString:@"/"];
    
    pFlPath = [pFlPath stringByAppendingString:pFlName];
    NSURL *movurl = [NSURL URLWithString:pFlPath];
    NSData *data = [NSData dataWithContentsOfURL:movie];
    if ([data writeToURL:movurl atomically:YES] == NO)
    {
        printf("Failed to write to file %ld\n", filno);
        // --nAlNo;
        return;
    }
    else
    {
        NSLog(@"Save file %ld in album %@ filename %@ URL %@\n", filno, movurl, pFlPath, movie);
        
    }
    
    // [self saveAsMp4:movurl mp4VideoPath:pMP4VideoPath];
    
    //__block UIImage *thumbnail;
    // AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:movurl options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:[AVAsset assetWithURL:movurl]];
    
    
    
    CMTime thumbTime = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    
    CGImageRef startImage = [generator copyCGImageAtTime:thumbTime actualTime:&actualTime error:&error];
    UIImage *image = [UIImage imageWithCGImage:startImage];
    
    CGSize oImgSize;
    oImgSize.height = 71;
    oImgSize.width = 71;
    UIGraphicsBeginImageContext(oImgSize);
    [image drawInRect:CGRectMake(0, 0, oImgSize.width, oImgSize.height)];
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //  CGImageRef thumbnailImageRef = MyCreateThumbnailImageFromData (data, 5);
    // UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
    CGSize pImgSiz = [thumbnail size];
    NSLog(@"Added thumbnail Image height = %f width=%f \n", pImgSiz.height, pImgSiz.width);
    
    NSData *thumbnaildata = UIImageJPEGRepresentation(thumbnail, 0.3);
    NSString *pTmpNlFlPath = [pThumbNailsDir stringByAppendingString:@"/"];
    pTmpNlFlPath = [pTmpNlFlPath stringByAppendingString:pImgFlName];
    NSURL *thumburl = [NSURL URLWithString:pTmpNlFlPath];
    // [tnailurls addObject:thumburl];
    // [movurls addObject:movurl];
    /*
     if (bSaveLastPic)
     {
     bSaveLastPic = false;
     UIImage *img;
     [self saveThumbNails:img];
     }
     */
    
    if ([thumbnaildata writeToURL:thumburl atomically:YES] == NO)
    {
        NSLog(@"Failed to write to thumbnail file %ld thumburl %@\n", filno, thumburl);
        // --nAlNo;
        
    }
    else
    {
        NSLog(@"Save thumbnail file %ld in album %s file %@\n", filno, [pThumbNailsDir UTF8String], thumburl);
    }
    [delegate movieFurtherAction:movurl thumbUrl:thumburl];
    return;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //if (!assetsLibrary)
    // {
    //    assetsLibrary = [[ALAssetsLibrary alloc] init];
    // }
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    // Handle a still image capture
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo)
    {
        
        UIImage* image = (UIImage *) [info objectForKey:
                                      UIImagePickerControllerOriginalImage];
        
        NSInvocationOperation* theOp = [[NSInvocationOperation alloc] initWithTarget:self
                                                                            selector:@selector(saveImage:) object:image];
        [delegate saveQAdd:theOp];
        
        pBarItem.enabled = YES;
        pBarItem.tintColor =  [UIColor blueColor];
    }
    else if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0)
             == kCFCompareEqualTo)
    {
        NSLog(@"Saving movie \n");
        NSURL *movie = [info objectForKey:UIImagePickerControllerMediaURL];
        
        NSInvocationOperation* theOp = [[NSInvocationOperation alloc] initWithTarget:self
                                                                            selector:@selector(saveMovie:) object:movie];
        [delegate saveQAdd:theOp];
        
        pBarItem.enabled = YES;
        pBarItem.tintColor =  [UIColor blueColor];
        // [imagePickerController dismissModalViewControllerAnimated:NO];
        
        
        if (bSaveLastPic)
        {
            bSaveLastPic = false;
            bInShowCam = false;
            [imagePickerController dismissViewControllerAnimated:NO completion:nil];
            //   [self saveThumbNails];
            return;
            
        }
        
    }
    
    
    
}

-(void) showCamera:(UIViewController *) parentVwCntrl
{
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear] == NO)
        return;
    
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.editing = YES;
    imagePickerController.delegate = (id)self;
    imagePickerController.showsCameraControls = NO;
    imagePickerController.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeCamera];
    CGFloat barY, barHeight;
    NSLog(@"Setting camera toolbar bounds %f\n" , imagePickerController.cameraOverlayView.bounds.size.height);
    if (imagePickerController.cameraOverlayView.bounds.size.height > 500.00 && pSlider.value < 0.5)
    {
        barY = imagePickerController.cameraOverlayView.bounds.size.height - 95;
        barHeight = 95;
    }
    else
    {
        barY = imagePickerController.cameraOverlayView.bounds.size.height - 55;
        barHeight = 55;
    }
    
    CGRect mainScrn = [UIScreen mainScreen].bounds;
    
    UIToolbar *bar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, barY, mainScrn.size.width, barHeight)];
    
    
    UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(photosDone) ];
    UIBarButtonItem *pBarItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil ];
    // pBarItem2.width = 100;
    UIBarButtonItem *pBarItem4 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil ];
    NSArray *baritems = [NSArray arrayWithObjects:pBarItem1, pBarItem2, pBarItem, pBarItem4, pBarItem3, nil];
    [bar setItems:baritems];
    
    [imagePickerController.cameraOverlayView addSubview:bar];
    if(pSlider.value < 0.5)
        imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    else
        imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
    
    [parentVwCntrl presentViewController:imagePickerController animated:YES completion:nil];
    bInShowCam = true;
}

-(void) photosDone
{
    if (bInPicCapture)
    {
        
        [imagePickerController stopVideoCapture];
        NSLog(@"Stopping video capture\n");
        pBarItem.enabled = YES;
        bInPicCapture = false;
        pBarItem.tintColor =  [UIColor blueColor];
        bSaveLastPic = true;
        return;
    }
    
    
    [imagePickerController dismissViewControllerAnimated:NO completion:nil];
    [delegate reloadViews];
    bInShowCam = false;
}

@end
