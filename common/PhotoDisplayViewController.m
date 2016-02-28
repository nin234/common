/*
    File: PhotoDisplayViewController.m
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

#import "PhotoDisplayViewController.h"
#import "SlideScrollView.h"
#include <sys/stat.h>
#include <unistd.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AlbumContentsViewController.h"

#define ZOOM_VIEW_TAG 100
#define ZOOM_STEP 1.5

@interface PhotoDisplayViewController (UtilityMethods)
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;
@end

@implementation PhotoDisplayViewController

//@synthesize asset;
//@synthesize assets;
@synthesize currIndx;
@synthesize pMovP;
@synthesize audio;
@synthesize currURL;
@synthesize bPhoto;
@synthesize delphoto;
@synthesize delconfirm;
@synthesize pAlbmVw;
@synthesize subject;
@synthesize pAlName;
@synthesize pFlMgr;
@synthesize navViewController;


- (void)viewDidLoad
{
    UIBarButtonItem *pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(photoAction) ];
    self.navigationItem.rightBarButtonItem = pBarItem;
    photo_scale = 1.0;
     audio =  [AVAudioSession sharedInstance];
    [audio setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    self.title = @"Swipe for next";
    SlideScrollView *imageScrollView = (SlideScrollView *)self.view;
    NSLog(@"View dimensions frame x=%f y=%f height=%f width=%f bounds x=%f y=%f height = %f width=%f\n", [imageScrollView frame].origin.x, [imageScrollView frame].origin.y, [imageScrollView frame].size.height, [imageScrollView frame].size.width,
          [imageScrollView bounds].origin.x, [imageScrollView bounds].origin.y, [imageScrollView bounds].size.height, [imageScrollView bounds].size.width);
    [imageScrollView setBackgroundColor:[UIColor blackColor]];
    [imageScrollView setDelegate:self];
    [imageScrollView setBouncesZoom:NO];
    [imageScrollView setScrollEnabled:NO];

  //  ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
    NSString *pFlName = [[pAlbmVw.thumbnails objectAtIndex:currIndx] stringValue];
    NSString *pFlImgName = [pFlName stringByAppendingString:@".MOV"];
    pFlName = [pFlName stringByAppendingString:@".jpg"];
    
    NSError *err;
    NSURL *albumurl = [NSURL URLWithString:pAlName];
    NSURL *imgUrl;
    NSURL *movUrl;
    
    if (albumurl != nil && [albumurl checkResourceIsReachableAndReturnError:&err])
    {
        imgUrl = [albumurl URLByAppendingPathComponent:pFlName isDirectory:NO];
        movUrl = [albumurl URLByAppendingPathComponent:pFlImgName isDirectory:NO];

    }
    
    if ([imgUrl checkResourceIsReachableAndReturnError:&err] == YES)
    {
        //struct stat buf;
       // stat([pFlPath UTF8String], &buf);
        NSLog (@"Loading image in PhotoDisplayViewController %@ \n", imgUrl);
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
        TapDetectingImageView *imageView = [[TapDetectingImageView alloc] initWithImage:fullScreenImage];
        [imageView setDelegate:self];
        [imageView setTag:ZOOM_VIEW_TAG];
        [imageScrollView setContentSize:[imageView frame].size];
        [imageScrollView addSubview:imageView];
            currView = imageView;
    
        // calculate minimum scale to perfectly fit image width, and begin at that scale
        float minimumScale = [imageScrollView frame].size.width  / [imageView frame].size.width;
        [imageScrollView setMinimumZoomScale:minimumScale];
    
        [imageScrollView zoomToRect:CGRectMake(0.0, 0.0, imageView.frame.size.width, imageView.frame.size.height) animated:NO];
    }
    else if ([movUrl checkResourceIsReachableAndReturnError:&err] == YES)
    {
       
        NSLog(@"Loading movie %@ \n", movUrl);
        currURL = movUrl;
        NSLog(@"Loading movie %@ URL %@\n", pFlImgName, currURL);
         pMovP = [[MPMoviePlayerController alloc] initWithContentURL:currURL];
        bPhoto = false;
       
        pMovP.movieSourceType = MPMovieSourceTypeFile;
        NSLog(@"Playable duration %f %@ %f", [pMovP playableDuration], [pMovP contentURL], [pMovP duration]);
       
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(movieLoaded:)
                                                     name:MPMoviePlayerLoadStateDidChangeNotification object:pMovP];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(movieLoadFailed:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification object:pMovP];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(hideNavBar:)
                                                     name:MPMoviePlayerDidEnterFullscreenNotification object:pMovP];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(showNavBar:)
                                                     name:MPMoviePlayerDidExitFullscreenNotification object:pMovP];
        
        // [imageScrollView zoomToRect:CGRectMake(0.0, 0.0, 300, 420) animated:NO];
        [pMovP prepareToPlay];
         NSLog(@"Playable duration %f %f", [pMovP playableDuration], [pMovP duration]);
         if ([[UIScreen mainScreen] bounds].size.height > 500.0)
            [pMovP.view setFrame: CGRectMake(0.0, -35.0, 320, 520)];
        else
            [pMovP.view setFrame: CGRectMake(0.0, 0.0, 320, 408)];
        UISwipeGestureRecognizer * left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftSwipe:)];
        left.direction = UISwipeGestureRecognizerDirectionLeft;
        [pMovP.view addGestureRecognizer:left];
        
        UISwipeGestureRecognizer * right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightSwipe:)];
        right.direction = UISwipeGestureRecognizerDirectionRight;
        [pMovP.view addGestureRecognizer:right];
        
        [imageScrollView addSubview:pMovP.view];
        NSLog(@"Load state %lu %@", (unsigned long)[pMovP loadState], pMovP);
       // [imageScrollView zoomToRect:CGRectMake(0.0, 0.0, pMovP.view.frame.size.width, pMovP.view.frame.size.height) animated:NO];

        if ([pMovP isPreparedToPlay])
        {
             NSLog(@"Playing movie\n");
            [pMovP play];
           
        }
         
    }
    else
    {
        
        NSLog(@"Image or movie file does not exist %@ %@\n", imgUrl , movUrl);
    }
     NSLog(@"View loaded\n");
}

-(void) changePhoto
{
    printf("Changing photo\n");
    if (pMovP != nil)
        [pMovP pause];  
        
    NSString *pFlName = [[pAlbmVw.thumbnails objectAtIndex:currIndx] stringValue];
    NSString *pFlImgName = [pFlName stringByAppendingString:@".MOV"];
    pFlName = [pFlName stringByAppendingString:@".jpg"];
    

    NSError *err;
    NSURL *albumurl = [NSURL URLWithString:pAlName];
    NSURL *imgUrl;
    NSURL *movUrl;
    
    if (albumurl != nil && [albumurl checkResourceIsReachableAndReturnError:&err])
    {
        imgUrl = [albumurl URLByAppendingPathComponent:pFlName isDirectory:NO];
        movUrl = [albumurl URLByAppendingPathComponent:pFlImgName isDirectory:NO];
            
    }
    
    if ([imgUrl checkResourceIsReachableAndReturnError:&err] == YES)
    {
        NSLog (@"Loading image in PhotoDisplayViewController %@ \n", imgUrl);
        UIDevice *dev = [UIDevice currentDevice];
        
        UIImage *fullScreenImage;
        if ([[dev systemVersion] doubleValue] < 6.0)
        {
            NSLog(@"system version %f less than 6.0 using imageWithData", [[dev systemVersion] doubleValue]);
            fullScreenImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:imgUrl]];
        }
        else
        {
            NSLog(@"system version %f greater  than or equal to 6.0 using scaled imageWithData scale=%f", [[dev systemVersion] doubleValue],photo_scale);
           fullScreenImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:imgUrl] scale:photo_scale];
        }

       currURL = imgUrl;
        bPhoto = true;
        TapDetectingImageView *imageView = [[TapDetectingImageView alloc] initWithImage:fullScreenImage];
        [imageView setDelegate:self];
        [imageView setTag:ZOOM_VIEW_TAG];
        [currView  removeFromSuperview];
        [pMovP.view removeFromSuperview];
        currView = imageView;
        SlideScrollView *imageScrollView = (SlideScrollView *)self.view;

        [imageScrollView setContentSize:[imageView frame].size];
        [imageScrollView addSubview:imageView];
        
        // calculate minimum scale to perfectly fit image width, and begin at that scale
        float minimumScale = [imageScrollView frame].size.width  / [imageView frame].size.width;
        [imageScrollView setMinimumZoomScale:minimumScale];
        
        [imageScrollView zoomToRect:CGRectMake(0.0, 0.0, imageView.frame.size.width, imageView.frame.size.height) animated:NO];
    }
    else if ([movUrl checkResourceIsReachableAndReturnError:&err] == YES)
    {
        NSLog(@"Loading movie %@ \n", movUrl);
        currURL = movUrl;
        NSLog(@"Loading movie %@ URL %@\n", pFlImgName, currURL);
        [currView  removeFromSuperview];
        [pMovP.view removeFromSuperview];
        SlideScrollView *imageScrollView = (SlideScrollView *)self.view;
        
        pMovP = [[MPMoviePlayerController alloc] initWithContentURL:currURL];
        bPhoto = false;
        
        pMovP.movieSourceType = MPMovieSourceTypeFile;
        NSLog(@"Playable duration %f %@ %f", [pMovP playableDuration], [pMovP contentURL], [pMovP duration]);
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(movieLoaded:)
                                                     name:MPMoviePlayerLoadStateDidChangeNotification object:pMovP];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(movieLoadFailed:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification object:pMovP];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(hideNavBar:)
                                                     name:MPMoviePlayerDidEnterFullscreenNotification object:pMovP];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(showNavBar:)
                                                     name:MPMoviePlayerDidExitFullscreenNotification object:pMovP];
       
        
        [pMovP prepareToPlay];
        NSLog(@"Playable duration %f %f", [pMovP playableDuration], [pMovP duration]);
        
        if ([[UIScreen mainScreen] bounds].size.height > 500.0)
            [pMovP.view setFrame: CGRectMake(0.0, -35.0, 320, 520)];
        else
            [pMovP.view setFrame: CGRectMake(0.0, 0.0, 320, 408)];
         
       
        [imageScrollView setContentSize:[pMovP.view frame].size];
        // currView = pMovP.view;
        UISwipeGestureRecognizer * left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftSwipe:)];
        left.direction = UISwipeGestureRecognizerDirectionLeft;
        [pMovP.view addGestureRecognizer:left];
        
        UISwipeGestureRecognizer * right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightSwipe:)];
        right.direction = UISwipeGestureRecognizerDirectionRight;
        [pMovP.view addGestureRecognizer:right];
        
        [imageScrollView addSubview:pMovP.view];
        NSLog(@"Load state %lu %@", (unsigned long)[pMovP loadState], pMovP);
        // [imageScrollView zoomToRect:CGRectMake(0.0, 0.0, pMovP.view.frame.size.width, pMovP.view.frame.size.height) animated:NO];
        
        if ([pMovP isPreparedToPlay])
        {
            NSLog(@"Playing movie\n");
            [pMovP play];
            
        }
        
    }
    else
    {
        NSLog(@"Image or movie file does not exist %@ %@\n", imgUrl , movUrl);
    }

    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    photo_scale = photo_scale/2;
    NSLog (@"Received low memory warning showing picture with new scale %f\n", photo_scale);
    [self changePhoto];
    
    // Release any cached data, images, etc that aren't in use.
}


-(void) photoAction
{
    delconfirm = false;
    UIActionSheet *pSh;
    if (delphoto)
        pSh = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email Photo", @"Delete Photo", nil];
    else 
        pSh = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email Photo", nil];
    
    [pSh showInView:self.view];
    [pSh setDelegate:self];
    

    return;
}

-(void) popView
{
    NSLog(@"Popping PhotoDisplayViewController\n");
    return;
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    printf("Clicked button at index %ld\n", (long)buttonIndex);
    if (buttonIndex == 0)
    {
        if (delconfirm)
        {
          
            NSError *err;
            if ([pFlMgr removeItemAtURL:currURL error:&err])
                NSLog(@"Removed item at URL %@\n", currURL);
            else 
                NSLog(@"Failed to remove item at URL %@ reason %@\n", currURL, err);
            NSString *last = [currURL lastPathComponent];
            NSURL *baseurl = [currURL URLByDeletingLastPathComponent];
            NSUInteger len = [last length];
            
            NSString *name = [last substringToIndex:len-4];
            NSLog(@"File name %@ length %lu no extn name %@ \n", last, (unsigned long)len, name);
            NSString *newlast = [name stringByAppendingString:@".jpg"];
            NSURL *thumburl = [baseurl URLByAppendingPathComponent:@"thumbnails" isDirectory:YES];
            thumburl = [thumburl URLByAppendingPathComponent:newlast isDirectory:NO];
            if ([pFlMgr removeItemAtURL:thumburl error:&err])
                NSLog(@"Removed item at URL %@\n", thumburl);
            else 
                NSLog(@"Failed to remove item at URL %@ reason %@\n", thumburl, err);
            
            delconfirm = false;
            [pAlbmVw deletedPhotoAtIndx:currIndx];
              [navViewController popViewControllerAnimated:YES];
            /*
            [pDlg.navViewController popViewControllerAnimated:YES];
            AlbumContentsViewController *albumContentsViewController = [[AlbumContentsViewController alloc] initWithNibName:@"AlbumContentsViewController" bundle:nil];
            NSLog(@"Pushing AlbumContents view controller %s %d\n" , __FILE__, __LINE__);
            //  albumContentsViewController.assetsGroup = group_;
            [albumContentsViewController setDelphoto:true];
            [pDlg.navViewController pushViewController:albumContentsViewController animated:NO];
             */

        }
        else 
        {
            NSLog(@"In email Photo\n");
            if ([MFMailComposeViewController canSendMail])
            {
                MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
                controller.mailComposeDelegate = self;
                [controller setSubject:subject];
                NSString *message = @"Decision making iPhone app";
                [controller setMessageBody:message isHTML:NO];
                if (bPhoto)
                {
                    [controller addAttachmentData:[NSData dataWithContentsOfURL:currURL] mimeType:@"image/jpeg" fileName:@"photo"];
                }
                else 
                {
                    [controller addAttachmentData:[NSData dataWithContentsOfURL:currURL] mimeType:@"video/quicktime" fileName:@"video"];    
                }
                // [controller setMessageBody:[pMainVwCntrl.pAllItms getMessage] isHTML:NO]; 
                if (controller) [self presentViewController:controller animated:YES completion:nil];

            }
        }
    }
    else if (delphoto && buttonIndex == 1)
    {
        if (!delconfirm)
        {
            UIActionSheet   *pSh = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Confirm" otherButtonTitles:nil];
        
            [pSh showInView:self.view];
            [pSh setDelegate:self];
            delconfirm = true;
        }
        

    }

    return;
}

- (void)mailComposeController:(MFMailComposeViewController*)controller  
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error;
{
        if (result == MFMailComposeResultSent) {
        NSLog(@"It's away!");
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) handleLeftSwipe : (UISwipeGestureRecognizer *) left
{
 
    NSLog (@"Got left swipe in movie %ld\n", (long)[pMovP playbackState]);
    printf("Curr Index %lu\n", (unsigned long)currIndx);
    if ([pMovP playbackState] == MPMoviePlaybackStatePlaying)
    {
        NSLog(@"Play back state playing ignoring swipe \n");
        [pMovP stop];
        //return;
    }
    
    if (pAlbmVw.gotqueryres == true)
    {
        pAlbmVw.reload = true;
        [pAlbmVw.tableView reloadData];
        pAlbmVw.reload = false;
    }

    if (currIndx < (pAlbmVw.nPicCnt -1))
    {
        ++currIndx;   
        printf("Curr Index %lu\n", (unsigned long)currIndx);
       // [pMovP pause];
        [self changePhoto];
    }
    return;
}

-(void) handleRightSwipe : (UISwipeGestureRecognizer *) right
{
    
    NSLog (@"Got right swipe in movie load state %ld\n", (long)[pMovP playbackState]);
    printf("Curr Index %lu \n", (unsigned long)currIndx);
    
    if ([pMovP playbackState] == MPMoviePlaybackStatePlaying)
    {
        NSLog(@"Load state unknown ignoring swipe \n");
       // return;
        [pMovP stop];
    }
    
    if (pAlbmVw.gotqueryres == true)
    {
        pAlbmVw.reload = true;
        [pAlbmVw.tableView reloadData];
        pAlbmVw.reload = false;
    }
    
    if (currIndx)
    {
        --currIndx;
        printf("Curr Index %lu\n", (unsigned long)currIndx);
        //[pMovP pause];
        [self changePhoto];
    }
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


- (void)movieLoaded:(NSNotification *)notification
{
    NSLog(@"Movie loaded\n");
     // pMovP.useApplicationAudioSession = NO;
    MPMoviePlayerController *movie = [notification object];
    pMovP.controlStyle = MPMovieControlStyleEmbedded;
    NSLog(@"Playable duration %f %f mediatypes %lu", [movie   playableDuration], [movie duration], (unsigned long)[movie movieMediaTypes]);
   [movie pause];
  
    return;
}

- (void)movieLoadFailed:(NSNotification *)notification
{
    NSLog(@"Movie load failed\n");
    MPMoviePlayerController* theMovie = [notification object];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver: self
     name: MPMoviePlayerPlaybackDidFinishNotification
     object: theMovie];
    
    // Release the movie instance created in playMovieAtURL:
  //  [theMovie release];
    return;
}


#pragma mark -
#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
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

- (void)tapDetectingImageView:(TapDetectingImageView *)view gotSingleTapAtPoint:(CGPoint)tapPoint {
    // single tap does nothing for now
    printf("In single tap\n");
}

- (void)tapDetectingImageView:(TapDetectingImageView *)view gotDoubleTapAtPoint:(CGPoint)tapPoint {
    printf("In double tap\n");
    UIScrollView *imageScrollView = (UIScrollView *)self.view;
    // double tap zooms in
    float newScale = [imageScrollView zoomScale] * ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:tapPoint];
    [imageScrollView zoomToRect:zoomRect animated:YES];
}

- (void)tapDetectingImageView:(TapDetectingImageView *)view gotTwoFingerTapAtPoint:(CGPoint)tapPoint {
    printf("In two finger tap tap\n");
    UIScrollView *imageScrollView = (UIScrollView *)self.view;
    // two-finger tap zooms out
    float newScale = [imageScrollView zoomScale] / ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:tapPoint];
    [imageScrollView zoomToRect:zoomRect animated:YES];
}
- (void)tapDetectingImageView:(TapDetectingImageView *)view gotSwipe:(BOOL)left
{
    if (pAlbmVw.gotqueryres == true)
    {
        pAlbmVw.reload = true;
        [pAlbmVw.tableView reloadData];
        pAlbmVw.reload = false;
    }

    if (!left)
    {
        printf("Show the left picture\n");
        printf("Curr Index %lu\n", (unsigned long)currIndx);
        if (currIndx)
        {
            --currIndx;
            printf("Curr Index %lu\n", (unsigned long)currIndx);
//            [self setAsset:[assets objectAtIndex:currIndx]];
            //[self viewDidUnload];
            //[self viewDidLoad];
            [self changePhoto];
        }
    }
    else
    {
        printf("Show the right picture\n");
         printf("Curr Index %lu\n", (unsigned long)currIndx);
        if (currIndx < (pAlbmVw.nPicCnt -1))
        {
            ++currIndx;   
            printf("Curr Index %lu\n", (unsigned long)currIndx);
           // [self setAsset:[assets objectAtIndex:currIndx]];
           // [self viewDidUnload];
           // [self viewDidLoad];
            [self changePhoto];
        }
    }
}

#pragma mark -
#pragma mark Utility methods

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    UIScrollView *imageScrollView = (UIScrollView *)self.view;

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


- (void)dealloc {
   
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"Photodisplay view controller, view will unload\n");
   // [super viewWillDisappear:YES];
    if (pMovP != nil)
        [pMovP pause];
    pAlbmVw.reload = true;
    if (pAlbmVw.gotqueryres == true)
        [pAlbmVw.tableView reloadData];
   
}

@end
