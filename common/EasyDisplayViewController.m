/*
    File: EasyDisplayViewController.m
Abstract: View controller to manaage displaying a photo.
 Version: 1.0

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
Inc. ("Apple") in consideration of your agreement to the following
terms, and your use, installation, modification or redistribution of
this Apple software constitutes acceptance of these terms.  If you do
not agree with these terms, please do not use, install, modify or
redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and
subject to these terms, Apple grants you a personal, non-exclusive
license, under Apple's copyrights in this original Apple software (the
"Apple Software"), to use, reproduce, modify and redistribute the Apple
Software, with or without modifications, in source and/or binary forms;
provided that if you redistribute the Apple Software in its entirety and
without modifications, you must retain this notice and the following
text and disclaimers in all such redistributions of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may
be used to endorse or promote products derived from the Apple Software
without specific prior written permission from Apple.  Except as
expressly stated in this notice, no other rights or licenses, express or
implied, are granted by Apple herein, including but not limited to any
patent rights that may be infringed by your derivative works or by other
works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2011 Apple Inc. All Rights Reserved.

*/

#import "EasyDisplayViewController.h"
#import "EasySlideScrollView.h"
#import "AppCmnUtil.h"
#include <sys/stat.h>
#include <unistd.h>

#define ZOOM_VIEW_TAG 100
#define ZOOM_STEP 1.5

@interface EasyDisplayViewController (UtilityMethods)
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;
@end

@implementation EasyDisplayViewController

//@synthesize asset;
//@synthesize assets;


@synthesize currURL;
@synthesize bPhoto;
@synthesize delconfirm;
@synthesize picName;
@synthesize listName;
//@synthesize imageScrollView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        delconfirm = false;
    }
    return self;
}

- (void)loadView
{
    CGRect fullScreenRect=[[UIScreen mainScreen] applicationFrame];
   EasySlideScrollView * scrollView=[[EasySlideScrollView alloc] initWithFrame:fullScreenRect];
    scrollView.contentSize=CGSizeMake(fullScreenRect.size.width,fullScreenRect.size.height);
    
    // do any further configuration to the scroll view
    // add a view, or views, as a subview of the scroll view.
    
    // release scrollView as self.view retains it
    self.view=scrollView;
    
    NSLog(@"View loaded\n");
}

- (void)viewDidLoad
 {
    
     [super viewDidLoad];
     UIBarButtonItem *pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(photoAction)];
     self.navigationItem.rightBarButtonItem = pBarItem;

    
    self.title = @"List";
     photo_scale = 1.0;
     [self displayPhoto];
    
}

-(void) displayPhoto
{
    
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    CGRect mainScrn = [UIScreen mainScreen].applicationFrame;
    CGRect tableRect = CGRectMake(mainScrn.origin.x, mainScrn.origin.y, mainScrn.size.width, mainScrn.size.height);
   //EasySlideScrollView *imageScrollView = [[EasySlideScrollView alloc] initWithFrame:CGRectMake(0.000, 0.00, self.view.frame.size.width*2, self.view.frame.size.height*2)];
    //imageScrollView = [[EasySlideScrollView alloc] initWithFrame:tableRect];
    
    EasySlideScrollView *imageScrollView = (EasySlideScrollView*) self.view;
   // imageScrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height+100);
    
    NSLog(@"View dimensions frame x=%f y=%f height=%f width=%f bounds x=%f y=%f height = %f width=%f\n", [imageScrollView frame].origin.x, [imageScrollView frame].origin.y, [imageScrollView frame].size.height, [imageScrollView frame].size.width,
          [imageScrollView bounds].origin.x, [imageScrollView bounds].origin.y, [imageScrollView bounds].size.height, [imageScrollView bounds].size.width);
    [imageScrollView setBackgroundColor:[UIColor blackColor]];
    [imageScrollView setDelegate:self];
    [imageScrollView setBouncesZoom:NO];
    [imageScrollView setScrollEnabled:NO];
    self.view =imageScrollView;
    
    NSError *err;
    NSURL *albumurl = pAppCmnUtil.pPicsDir;
    NSURL *imgUrl;
    
    if (albumurl != nil && [albumurl checkResourceIsReachableAndReturnError:&err])
    {
        imgUrl = [albumurl URLByAppendingPathComponent:picName isDirectory:NO];
    }
    
    if ([imgUrl checkResourceIsReachableAndReturnError:&err] == YES)
    {
        //struct stat buf;
        // stat([pFlPath UTF8String], &buf);
        NSLog (@"Loading image in EasyDisplayViewController %@ \n", imgUrl);
        UIDevice *dev = [UIDevice currentDevice];
        
        UIImage *fullScreenImage;
        if ([[dev systemVersion] doubleValue] < 6.0)
        {
            NSLog(@"system version %f less than 6.0 using imageWithData", [[dev systemVersion] doubleValue]);
            fullScreenImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:imgUrl]];
        }
        else
        {
            
            NSLog(@"system version %f greater  than or equal to 6.0 using scaled imageWithData scale=%f", [[dev systemVersion] doubleValue], photo_scale);
            fullScreenImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:imgUrl] scale:photo_scale];
        }
        currURL = imgUrl;
        bPhoto = true;
       // EasyTapDetectingImageView *imageView = [[EasyTapDetectingImageView alloc] initWithImage:fullScreenImage];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:fullScreenImage];
       // [imageView setDelegate:self];
        [imageView setTag:ZOOM_VIEW_TAG];
       // [imageScrollView setContentSize:[imageView frame].size];
        [imageScrollView addSubview:imageView];
      //  currView = imageView;
        
        // calculate minimum scale to perfectly fit image width, and begin at that scale
        float minimumScale = [imageScrollView frame].size.width  / [imageView frame].size.width;
        [imageScrollView setMinimumZoomScale:minimumScale];
        [imageScrollView setMaximumZoomScale:minimumScale*15];
        
        [imageScrollView zoomToRect:CGRectMake(0.0, 0.0, imageView.frame.size.width, imageView.frame.size.height) animated:NO];
        NSLog(@"View dimensions frame x=%f y=%f height=%f width=%f bounds x=%f y=%f height = %f width=%f\n", [imageScrollView frame].origin.x, [imageScrollView frame].origin.y, [imageScrollView frame].size.height, [imageScrollView frame].size.width,
              [imageScrollView bounds].origin.x, [imageScrollView bounds].origin.y, [imageScrollView bounds].size.height, [imageScrollView bounds].size.width);
    }
    else
    {
        
        NSLog(@"Image file does not exist %@\n", imgUrl);
    }
   
    return;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    photo_scale = photo_scale/2;
    NSLog (@"Received low memory warning showing picture with new scale %f\n", photo_scale);
    [self displayPhoto];
    
    // Release any cached data, images, etc that aren't in use.
}


-(void) photoAction
{
   
     UIActionSheet *   pSh = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Delete List", nil];
    [pSh showInView:self.view];
    [pSh setDelegate:self];
    return;
}

-(void) popView
{
    NSLog(@"Popping EasyDisplayViewController\n");
    return;
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    printf("Clicked button at index %ld\n", (long)buttonIndex);
    if (buttonIndex == 0)
    {
        if (delconfirm)
        {
            
            NSError *err;
            if ([pAppCmnUtil.pFlMgr removeItemAtURL:currURL error:&err])
                NSLog(@"Removed item at URL %@\n", currURL);
            else 
                NSLog(@"Failed to remove item at URL %@ reason %@\n", currURL, err);
            NSURL *albumurl = pAppCmnUtil.pThumbNailsDir;
            NSURL *thumburl;
            
            if (albumurl != nil && [albumurl checkResourceIsReachableAndReturnError:&err])
            {
                thumburl = [albumurl URLByAppendingPathComponent:picName isDirectory:NO];
            }

                       if ([pAppCmnUtil.pFlMgr removeItemAtURL:thumburl error:&err])
                NSLog(@"Removed item at URL %@\n", thumburl);
            else 
                NSLog(@"Failed to remove item at URL %@ reason %@\n", thumburl, err);
            
            delconfirm = false;
            [pAppCmnUtil.dataSync deletedEasyItem:listName];
            [pAppCmnUtil.navViewController popViewControllerAnimated:YES];
        }
        else 
        {
            if (!delconfirm)
            {
                UIActionSheet   *pSh = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Confirm" otherButtonTitles:nil];
                
                [pSh showInView:self.view];
                [pSh setDelegate:self];
                delconfirm = true;
            }
 
        }
   
    }

    return;
}


-(void) handleLeftSwipe : (UISwipeGestureRecognizer *) left
{
 
        return;
}

-(void) handleRightSwipe : (UISwipeGestureRecognizer *) right
{
    
        return;
}

- (void)hideNavBar:(NSNotification *)notification
{
    NSLog(@"entered full screen mode\n");
    return;
}

- (void)showNavBar:(NSNotification *)notification
{
    NSLog(@"exited full screen mode\n");
    return;
}


#pragma mark -
#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    for (UIView *vw in self.view.subviews)
    {
            if ([vw isKindOfClass:[EasySlideScrollView class]])
            {
                NSLog(@"View for zooming in Scroll view\n");
              return [vw viewWithTag:ZOOM_VIEW_TAG];
            }
    }
    return [(UIScrollView *)self.view viewWithTag:ZOOM_VIEW_TAG];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    NSLog(@"Begin zooming\n");
    [scrollView setScrollEnabled:YES];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    NSLog(@"Scroll view end zooming %f\n", scale);
    if (scale < 0.14)
    {
        NSLog(@"Disabling scroll \n");
         [scrollView setScrollEnabled:NO];
    }
    
}

#pragma mark -
#pragma mark TapDetectingImageViewDelegate methods

- (void)tapDetectingImageView:(EasyTapDetectingImageView *)view gotSingleTapAtPoint:(CGPoint)tapPoint {
    // single tap does nothing for now
    printf("In single tap\n");
}

- (void)tapDetectingImageView:(EasyTapDetectingImageView *)view gotDoubleTapAtPoint:(CGPoint)tapPoint {
    printf("In double tap\n");
    for (UIView *vw in self.view.subviews)
    {
        if ([vw isKindOfClass:[EasySlideScrollView class]])
        {
            EasySlideScrollView *imageScrollView = (EasySlideScrollView *)vw;
            // double tap zooms in
            float newScale = [imageScrollView zoomScale] * ZOOM_STEP;
            CGRect zoomRect = [self zoomRectForScale:newScale withCenter:tapPoint];
            [imageScrollView zoomToRect:zoomRect animated:YES];
 
        }
    }
    }

- (void)tapDetectingImageView:(EasyTapDetectingImageView *)view gotTwoFingerTapAtPoint:(CGPoint)tapPoint {
    printf("In two finger tap tap\n");
    for (UIView *vw in self.view.subviews)
    {
        if ([vw isKindOfClass:[EasySlideScrollView class]])
        {
            EasySlideScrollView *imageScrollView = (EasySlideScrollView *)vw;

            float newScale = [imageScrollView zoomScale] / ZOOM_STEP;
            CGRect zoomRect = [self zoomRectForScale:newScale withCenter:tapPoint];
            [imageScrollView zoomToRect:zoomRect animated:YES];
        }
    }

}

- (void)tapDetectingImageView:(EasyTapDetectingImageView *)view gotSwipe:(BOOL)left
{
    return;
}

#pragma mark -
#pragma mark Utility methods

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    
    for (UIView *vw in self.view.subviews)
    {
        if ([vw isKindOfClass:[EasySlideScrollView class]])
        {
            CGRect zoomRect;
            EasySlideScrollView *imageScrollView = (EasySlideScrollView *)vw;
    
    // the zoom rect is in the content view's coordinates. 
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
            zoomRect.size.height = [imageScrollView frame].size.height / scale;
            zoomRect.size.width  = [imageScrollView frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
            zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
            zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
            return zoomRect;
        }
    }
    
    return CGRectMake(0.00, 0.00, 0.00, 0.00);
    
}


- (void)dealloc
{
   
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"Photodisplay view controller, view will unload\n");
   // [super viewWillDisappear:YES];
   
}

@end
