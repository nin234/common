//
//  EditViewController.m
//  Shopper
//
//  Created by Ninan Thomas on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EditViewController.h"
#include <sys/types.h>
#include <dirent.h>
#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "NotesViewController.h"
#import "ImageIO/ImageIO.h"
#import "CoreFoundation/CoreFoundation.h"
#include <MobileCoreServices/UTCoreTypes.h>
#include <MobileCoreServices/UTType.h>
#import <MediaPlayer/MediaPlayer.h>
#include <sys/time.h>
#import "AVFoundation/AVAssetImageGenerator.h"
#import "AVFoundation/AVAsset.h"
#import "AVFoundation/AVTime.h"
#import "CoreMedia/CMTime.h"
#import "textdefs.h"
#import "List1ViewController.h"
#import "EasyAddViewController.h"
#import "AppCmnUtil.h"
#import "List.h"

#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

@implementation EditViewController

@synthesize imagePickerController;
@synthesize pBarItem;
@synthesize pBarItem3;
@synthesize pSlider;
@synthesize nSmallest;
@synthesize bSliderPic;
@synthesize tnailurls;
@synthesize movurls;
@synthesize pAlName;
@synthesize pFlMgr;
@synthesize delegate;
@synthesize navViewController;
@synthesize itemMp;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        imagePickerController = [[UIImagePickerController alloc] init];
       // tnailurls = [NSMutableArray arrayWithCapacity:100];
       // movurls = [NSMutableArray arrayWithCapacity:100];
        bInShowCam = false;
        processQuery = true;
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
        nSmallest = 0;
         checkListArr= nil;
        itemMp = nil;
        
	     NSString *pAlMoc = pAlName;
	    printf("In DisplayViewController edit album name %s\n", [pAlMoc UTF8String]);
	    if (pAlMoc == nil)
            return self;
	    NSURL *albumurl = [NSURL URLWithString:pAlMoc];
	    [self findSmallest:albumurl];
    }
    return self;
}

-(void) findSmallest: (NSURL * ) albumurl
{
    char szFileNo[64];
   // NSError *err;
	NSArray *keys = [NSArray arrayWithObject:NSURLIsRegularFileKey];
        NSArray *files = [pFlMgr contentsOfDirectoryAtURL:albumurl includingPropertiesForKeys:keys options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
        NSUInteger cnt = [files count];
        for (NSUInteger i = 0; i < cnt; ++i)
        {
            NSURL *fileurl = [files objectAtIndex:i];
            NSError *error;
            NSNumber *isReg;
            if ([fileurl getResourceValue:&isReg forKey:NSURLIsRegularFileKey error:&error] == YES)
            {
                if ([isReg boolValue] == YES)
                {
                    NSString *pFil = [fileurl lastPathComponent];
                    int size = (int)strcspn([pFil UTF8String], ".");
                    if (size)
                    {
                        strncpy(szFileNo, [pFil UTF8String], size);
                        szFileNo[size] = '\0';
                        int val = strtod(szFileNo, NULL);
                        if (val < nSmallest)
                            nSmallest = val;
                        if (nSmallest == 0)
                            nSmallest = val;
                    }
                    
                }
            }
            else
            {
                NSLog(@"Failed to get resource value %@\n", error);
            }
            
        }
        

	return;
}

- (void)sliderUpdate:(id)sender 
{
    UISlider *slider = (UISlider *)sender;
    float val = slider.value;
    NSLog(@"In slider update value %f\n", val);
    if (val < 0.5)
    {
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
        
        pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(takePhoto) ];
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
        
        if (pBarItem.enabled == NO)
        {
            if (bSliderPic)
            {
                [slider setValue:0.0 animated:YES];
                return;
            }
        }
        pBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Record-Button-off.png"] style:UIBarButtonItemStylePlain target:self action:@selector(takePhoto)];
        CGFloat barY, barHeight;
        NSLog(@"Setting camera toolbar bounds %f\n" , imagePickerController.cameraOverlayView.bounds.size.height);
        barY = imagePickerController.cameraOverlayView.bounds.size.height - 55;
        barHeight = 55;
        CGRect mainScrn = [UIScreen mainScreen].bounds;
        UIToolbar *bar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, barY, mainScrn.size.width, barHeight)];
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

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(void) loadView
{
    [super loadView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"EditViewController will appear\n");
    if (query != nil)
    {
        
        if (![query isStarted])
        {
            NSLog(@"Start query in EditViewController\n");
            [query startQuery];
            processQuery = true;
        }
    }

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"EditViewController will disappear\n");
    if (query != nil)
    {
        
        if (![query isStopped])
        {
            NSLog(@"Stop query in EditViewController\n");
            [query stopQuery];
            processQuery = false;
        }
    }

}

-(void) itemEditCancel
{
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    [delegate itemEditCancel];
    pAppCmnUtil.itemsMp = nil;
    return;
}

-(void) itemEditDone
{
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    [delegate itemEditDone];
    ItemKey *itk = [delegate getEditItemKey];
    
    

    if (pAppCmnUtil.itemsMp != nil &&  itk.name != nil)
    {
        NSLog(@"Persisting checklist in itemAddDone %s %d", __FILE__, __LINE__);
        
        [pAppCmnUtil.dataSync editItem:itk itemsDic:pAppCmnUtil.itemsMp];
        pAppCmnUtil.itemsMp = nil;
        
    }
    

    return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(itemEditCancel)];
    self.navigationItem.leftBarButtonItem = pBarItem1;
    NSString *title = @"Edit Info";
    self.navigationItem.title = [NSString stringWithString:title];
    UIBarButtonItem *pBarItemEditDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(itemEditDone)];
    self.navigationItem.rightBarButtonItem = pBarItemEditDone;
    

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    if (query != nil)
    {
        NSLog(@"Stop query in EditViewController\n");
        [query stopQuery];
    }
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
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
       //     pBarItem.enabled = NO;
            bInPicCapture = false;
        }
        else
        {
            
            [imagePickerController takePicture];
   //         pBarItem.enabled = NO;
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
            pBarItem.enabled = NO;
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

-(void) saveThumbNails:(UIImage *) img
{
    NSUInteger tcnt = [tnailurls count];
    NSUInteger mcnt = [movurls count];
    NSLog(@"Saving thumbnails tcnt %lu mcnt %lu\n", (unsigned long)tcnt, (unsigned long)mcnt);
    
    if (tcnt != mcnt || !tcnt)
        return;
    
    
     
    for (NSUInteger i =0; i < mcnt; ++i)
    {
        NSLog(@"Trying to save thumbnail %@ for movie %@\n", [tnailurls objectAtIndex:i], [movurls objectAtIndex:i]);
            AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:[movurls objectAtIndex:i] options:nil];
        AVAssetImageGenerator *generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
        generate1.appliesPreferredTrackTransform = YES;
        NSError *err = NULL;
        CMTime time = CMTimeMakeWithSeconds(0.0, 600);
        CGImageRef oneRef = [generate1 copyCGImageAtTime:time actualTime:NULL error:&err];
        UIImage *thumbnail = [[UIImage alloc] initWithCGImage:oneRef];
    
            NSData *thumbnaildata = UIImageJPEGRepresentation(thumbnail, 0.3);

        if ([thumbnaildata writeToURL:[tnailurls objectAtIndex:i] atomically:YES] == NO)
        {
            NSLog(@"Failed to write to thumbnail file %@\n", [tnailurls objectAtIndex:i]);
        }
        else
        {
            NSLog(@"Save thumbnail file %@\n", [tnailurls objectAtIndex:i]);
        }
     
    }    
    [movurls removeAllObjects];
    [tnailurls removeAllObjects];
    [self.tableView reloadData];
    if (bInShowCam)
    {
        [imagePickerController dismissViewControllerAnimated:NO completion:nil];
          
        NSLog(@"Dismissed  imagePickerController about to show it again in Save thumbnails\n");
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
    return;
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
   /* 
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIImage *img;
    NSInvocationOperation* theOp = [[NSInvocationOperation alloc] initWithTarget:self
                                                                        selector:@selector(saveThumbNails:) object:img];
    NSLog(@"Add save thumbnail to queue\n");
    [pDlg.saveQ addOperation:theOp];
*/
    [imagePickerController dismissViewControllerAnimated:NO completion:nil];
    [self.tableView reloadData];
    bInShowCam = false;
}

-(void) AddPicture
{
    
    printf ("Show Camera\n");
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
    [self presentViewController:imagePickerController animated:YES completion:nil];
    bInShowCam = true;
}

-(void) saveMovie:(NSURL *)movie
{
    
    struct timeval tv;
    gettimeofday(&tv, 0);
    long filno = tv.tv_sec/2;

    NSString *pFlName = [[NSNumber numberWithLong:filno] stringValue];
    NSString *pImgFlName = [pFlName stringByAppendingString:@".jpg"];
    
    pFlName = [pFlName stringByAppendingString:@".MOV"];
    
    NSData *data = [NSData dataWithContentsOfURL:movie];
    
    NSURL *pFlUrl;
    NSError *err;
    NSURL *albumurl = [NSURL URLWithString:pAlName];
    if (albumurl != nil && [albumurl checkResourceIsReachableAndReturnError:&err])
    {
        
        pFlUrl = [albumurl URLByAppendingPathComponent:pFlName isDirectory:NO];
    }
    
    NSDictionary *dict = [pFlMgr attributesOfItemAtPath:[pFlUrl path] error:&err];
    if (dict != nil)
        NSLog (@"Loading image in DisplayViewController %@ file size %lld\n", pFlUrl, [dict fileSize]);
    else 
        NSLog (@"Loading image in DisplayViewController %@ file size not obtained\n", pFlUrl);
    
    
    if ([data writeToURL:pFlUrl atomically:YES] == NO)
    {
        printf("Failed to write to file %ld\n", filno);
        // --nAlNo;
        
    }
    else
    {
        printf("Save file %ld in album %s\n", filno, [pAlName UTF8String]);
        [delegate incrementEditPicCnt];
    }

    //[movurls addObject:pFlUrl];
    
    
    
    
    
   NSURL *movurl = pFlUrl; 
    pFlUrl = [pFlUrl URLByDeletingLastPathComponent];
    pFlUrl = [pFlUrl URLByAppendingPathComponent:@"thumbnails" isDirectory:YES];
    pFlUrl = [pFlUrl URLByAppendingPathComponent:pImgFlName isDirectory:NO];
//    [tnailurls addObject:pFlUrl];
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
        
        if ([thumbnaildata writeToURL:pFlUrl atomically:YES] == NO)
        {
            NSLog(@"Failed to write to thumbnail file %ld thumburl %@\n", filno, pFlUrl);
            // --nAlNo;
            
        }
        else
        {
            NSLog(@"Save thumbnail file %@\n", pFlUrl);
        }

     
    return;
}

-(void) saveImage:(UIImage *)image
{
    
    struct timeval tv;
    gettimeofday(&tv, 0);
    long filno = tv.tv_sec/2;
    NSString *pFlName = [[NSNumber numberWithLong:filno] stringValue];
    
    pFlName = [pFlName stringByAppendingString:@".jpg"];
    
    
    NSURL *pFlUrl;
    NSError *err;
    NSURL *albumurl = [NSURL URLWithString:pAlName];
    if (albumurl != nil && [albumurl checkResourceIsReachableAndReturnError:&err])
    {

        pFlUrl = [albumurl URLByAppendingPathComponent:pFlName isDirectory:NO];
    }
    
    NSDictionary *dict = [pFlMgr attributesOfItemAtPath:[pFlUrl path] error:&err];
    if (dict != nil)
        NSLog (@"Loading image in DisplayViewController %@ file size %lld\n", pFlUrl, [dict fileSize]);
    else 
        NSLog (@"Loading image in DisplayViewController %@ file size not obtained\n", pFlUrl);
    
    
    
    
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    if ([data writeToURL:pFlUrl atomically:YES] == NO)
    {
        NSLog(@"Failed to write to file %ld %@\n", filno, pFlUrl);
        // --nAlNo;
        
    }
    else
    {
        printf("Save file %ld in album %s\n", filno, [pAlName UTF8String]);
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
    pFlUrl = [pFlUrl URLByDeletingLastPathComponent];
    pFlUrl = [pFlUrl URLByAppendingPathComponent:@"thumbnails" isDirectory:YES];
    pFlUrl = [pFlUrl URLByAppendingPathComponent:pFlName isDirectory:NO];
    if ([thumbnaildata writeToURL:pFlUrl atomically:YES] == NO)
    {
        NSLog (@"Failed to write to thumbnail file %ld %@\n", filno, pFlUrl);
        // --nAlNo;
        
    }
    else
    {
        printf("Save thumbnail file %ld in album %s\n", filno, [pAlName UTF8String]);
        [delegate incrementEditPicCnt];

    }
    
    
    
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    printf("printing album names\n");
    int nLargest;
    if (pAlName == nil)
    {
        
        nLargest = 0;
        
        // pDlg.pFlMgr = [[NSFileManager alloc] init];
        NSString *pHdir = NSHomeDirectory();
        NSString *pAlbums = @"/Documents/albums";
        NSString *pAlbumsDir = [pHdir stringByAppendingString:pAlbums];
        printf("create new album name %d in directory %s\n", nLargest, [pAlbumsDir UTF8String]);
        DIR *dirp = opendir([pAlbumsDir UTF8String]);
        struct dirent *dp;
        if (dirp)
        {
            while ((dp = readdir(dirp)) != NULL) 
            {
                if (dp->d_namlen)
                {
                    printf ("file name= %s\n", dp->d_name);
                    int val = strtod(dp->d_name, NULL);
                    if (nLargest < val)
                        nLargest = val;
                }
            }
        }
        ++nLargest;
        printf("Incremented nLargest to %d\n", nLargest);
        NSString *intStr = [[NSNumber numberWithInt:nLargest] stringValue];
        pAlbumsDir = [pAlbumsDir stringByAppendingString:@"/"];
        NSString *pNewAlbum = [pAlbumsDir stringByAppendingString:intStr];
        [delegate setEditAlbumNames:intStr fullName:pNewAlbum];
        pAlName = pNewAlbum;
        NSString *pThumpnail = [pNewAlbum stringByAppendingPathComponent:@"thumbnails"];
        BOOL  bDirCr = [pFlMgr createDirectoryAtPath:pThumpnail withIntermediateDirectories:YES attributes:nil error:nil];
        if(bDirCr == YES)
        {
            printf ("Created new album %s\n", [pThumpnail UTF8String]);
        }
        else
        {
            return;
        }
    }
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
         
         NSInvocationOperation* theOp = [[NSInvocationOperation alloc] initWithTarget:self
                                                                             selector:@selector(saveMovie:) object:[info objectForKey:UIImagePickerControllerMediaURL]];
         [delegate saveQAdd:theOp];

         pBarItem.enabled = YES;
         pBarItem.tintColor =  [UIColor blueColor];
         //[imagePickerController dismissModalViewControllerAnimated:NO];
         if (bSaveLastPic)
         {
             bSaveLastPic = false;
             bInShowCam = false;
             [imagePickerController dismissViewControllerAnimated:NO completion:nil];
             return;
             
         }
         //[self presentModalViewController:imagePickerController animated:YES];
     }
    return;
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    printf("Clicked button at index %ld\n", (long)buttonIndex);
    if (buttonIndex == 0)
    {
        NSError *err;
        NSURL *albumurl = [NSURL URLWithString:pAlName];
    	if (albumurl != nil && [albumurl checkResourceIsReachableAndReturnError:&err])
    	{
            if ([pFlMgr removeItemAtURL:albumurl error:&err])
                NSLog(@"Removed album %@\n", albumurl);
            else 
                NSLog(@"Failed to remove album %@\n", albumurl);
        }
        
        [navViewController popViewControllerAnimated:NO];
        [navViewController popViewControllerAnimated:NO];
        
        [delegate deleteEditItem];
         AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
        ItemKey *itk = [delegate getEditItemKey];
        [pAppCmnUtil.dataSync deletedEasyItem:itk];
        
        [self.navViewController popViewControllerAnimated:YES];
        [self.navViewController popViewControllerAnimated:YES];
        
    }
    
    
    
}

-(void) DeleteConfirm
{
    
    //printf("Launch UIActionSheet");
    UIActionSheet *pSh = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:[delegate deleteButtonTitle] otherButtonTitles:nil];
    [pSh showInView:self.tableView];
    [pSh setDelegate:self];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return 17;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSLog(@"Text field should change character %s %ld\n", [textField.text UTF8String], (long)textField.tag);
    
    if ([delegate changeCharacters:textField.tag])
        return YES;
    
    
    static NSString *numbers = @"0123456789";
    static NSString *numbersPeriod = @"01234567890.";
    
    
    //NSLog(@"%d %d %@", range.location, range.length, string);
    if (range.length > 0 && [string length] == 0) {
        // enable delete
        return YES;
    }
    
    // NSString *symbol = [[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator];
    NSString *symbol = @".";
    if (range.location == 0 && [string isEqualToString:symbol]) {
        // decimalseparator should not be first
        return NO;
    }
    NSCharacterSet *characterSet;
    
    if ([delegate rangeFourTag:textField.tag])
    {
        if ([string rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet].invertedSet].location != NSNotFound)
        {
            return NO;
        }
        NSString *proposedText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if (proposedText.length > 4)        {
            return NO;
        }

    }
    if ([delegate ratingsTag:textField.tag])
    {
        if ([string rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet].invertedSet].location != NSNotFound)
        {
            return NO;
        }
        NSString *proposedText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if (proposedText.length > 1)
        {
            return NO;
        }
        
        if ([proposedText intValue] < 0 || [proposedText intValue] >10)
            return NO;
        characterSet = [[NSCharacterSet characterSetWithCharactersInString:numbers] invertedSet];
    }
    else if ([delegate numbersTag:textField.tag])
    {
        
        characterSet = [[NSCharacterSet characterSetWithCharactersInString:numbers] invertedSet];   
    }
    else
    {
        
        NSRange separatorRange = [textField.text rangeOfString:symbol];
        if (separatorRange.location == NSNotFound)
        {
            //  if ([symbol isEqualToString:@"."]) {
            characterSet = [[NSCharacterSet characterSetWithCharactersInString:numbersPeriod] invertedSet];
            //}
            // else {
            //  characterSet = [[NSCharacterSet characterSetWithCharactersInString:numbersComma] invertedSet];              
            //}
        }
        else 
        {
            // allow 2 characters after the decimal separator
            if (range.location > (separatorRange.location + 2)) 
            {
                return NO;
            }
            characterSet = [[NSCharacterSet characterSetWithCharactersInString:numbers] invertedSet];               
        }
    }
    return ([[string stringByTrimmingCharactersInSet:characterSet] length] > 0);
    //  return NO;
}

- (void)textChanged:(id)sender 
{
    UITextField *textField = (UITextField *)sender;
    NSLog(@"Text field changed editing %s %ld\n", [textField.text UTF8String], (long)textField.tag);
    [delegate populateEditValues:textField];
    return;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    
    [theTextField resignFirstResponder];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
     [textField resignFirstResponder];
      return YES;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{ 
    if (indexPath.row == 0)
        cell.backgroundColor = [UIColor yellowColor];
    return;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"editdetail";
    static NSArray* fieldNames = nil;
   
    if (!fieldNames)
    {
        fieldNames = [delegate getFieldNames];
    }
    
    static NSArray *secondFieldNames = nil;
    
    if(!secondFieldNames)
    {
        secondFieldNames = [delegate getSecondFieldNames];
        
    }
    
    UITableViewCell *cell;
    NSUInteger row = indexPath.row;
	if(indexPath.section == 0) 
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]; 
        }
        else
        {
            NSArray *pVws = [cell.contentView subviews];
            NSUInteger cnt = [pVws count];
            for (NSUInteger i=0; i < cnt; ++i)
            {
                [[pVws objectAtIndex:i] removeFromSuperview];
            }
            cell.imageView.image = nil;
            cell.textLabel.text = nil;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        if ([delegate isTwoFieldRow:row])
        {
            
            UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 75, 25)];
            CGRect textFrame;
            label.textAlignment = NSTextAlignmentLeft;
            label.font = [UIFont boldSystemFontOfSize:14];
            [cell.contentView addSubview:label];
            textFrame = [delegate getTextFrame];
            UITextField *textField = [[UITextField alloc] initWithFrame:textFrame];
            NSString* fieldName = [fieldNames objectAtIndex:row];
            label.text = fieldName;
            textField.delegate = self;
            [textField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
            textField.tag = 0;
            [cell.contentView addSubview:textField];
            UILabel* label1 = [delegate getLabel];
            NSString *secName = [secondFieldNames objectAtIndex:row];
            label1.text = secName;
            label1.textAlignment = NSTextAlignmentLeft;
            label1.font = [UIFont boldSystemFontOfSize:14];
            [cell.contentView addSubview:label1];
            textFrame = CGRectMake(235, 12, 85, 25);
            UITextField *textField1 = [[UITextField alloc] initWithFrame:textFrame];
            textField1.delegate = self;
            [textField1 addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
            textField1.tag =1;
            [cell.contentView addSubview:textField1];
            [delegate populateEditTextFields:textField textField1:textField1 row:row];
        }
        else if ([delegate isSingleFieldEditRow:row])
        {
            CGRect textFrame;
			
            // put a label and text field in the cell
            UILabel *label;
            if (row != 13)
                label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 75, 25)];
            else
                label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 105, 25)];
            label.textAlignment = NSTextAlignmentLeft;
            label.font = [UIFont boldSystemFontOfSize:14];
            if (row == 0)
            {
                cell.backgroundColor = [UIColor yellowColor];
                label.backgroundColor = [UIColor yellowColor];
            }
            [cell.contentView addSubview:label];
            if (row != 13)
                textFrame = CGRectMake(75, 12, 200, 25);
            else
                textFrame = CGRectMake(110, 12, 170, 25);
            UITextField *textField = [[UITextField alloc] initWithFrame:textFrame];
            [delegate populateEditTextFields:textField textField1:nil row:row];
            textField.delegate = self;
            [textField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
            [cell.contentView addSubview:textField];
            
            NSString* fieldName = [fieldNames objectAtIndex:row];
            label.text = fieldName;
        }
        else if (row == 4)
        {
            
            cell.imageView.image = [UIImage imageNamed:@"camera.png"];
            cell.textLabel.text = @"Camera";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }
        else if (row == 5)
        {
            cell.textLabel.text = @"Check List";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if (row == 6)
        {
            cell.imageView.image = [UIImage imageNamed:@"note.png"];
            cell.textLabel.text = @"Notes";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; 
        }
        else if (row == 7)
        {
            
            printf("Selected album name %s\n", [pAlName UTF8String]);
            NSError *err;
	    if (!nSmallest)
	    {
		NSURL *albumurl = [NSURL URLWithString:pAlName];
		if (albumurl != nil && [albumurl checkResourceIsReachableAndReturnError:&err])
			[self findSmallest:albumurl];

	    }

            if (nSmallest)
            {
                NSString *pFlName = [[NSNumber numberWithInt:nSmallest] stringValue];
                pFlName = [pFlName stringByAppendingString:@".jpg"];
		NSURL *pFlUrl;
		NSError *err;
		NSURL *albumurl = [NSURL URLWithString:pAlName];
		if (albumurl != nil && [albumurl checkResourceIsReachableAndReturnError:&err])
		{
		    pFlUrl = [albumurl URLByAppendingPathComponent:@"thumbnails" isDirectory:YES];
		    pFlUrl = [pFlUrl URLByAppendingPathComponent:pFlName isDirectory:NO];
		}
        NSDictionary *dict = [pFlMgr attributesOfItemAtPath:[pFlUrl path] error:&err];
		if (dict != nil)
		    NSLog (@"Loading image in DisplayViewController %@ file size %lld\n", pFlUrl, [dict fileSize]);
		else 
		    NSLog (@"Loading image in DisplayViewController %@ file size not obtained\n", pFlUrl);
		UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:pFlUrl]];
                NSLog(@"Set icon image %@ in DisplayViewController\n", pFlUrl);
                cell.imageView.image = image;

            }
            cell.textLabel.text = @"Pictures";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; 
        }
        else if (row == 8)
        {
            
            cell.imageView.image = [UIImage imageNamed:@"map.png"];
            cell.textLabel.text = @"Map";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }
        if (row == 16)
        {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 325, 44)];
            [button setBackgroundImage:[[UIImage imageNamed:@"delete_button.png"]
                                        stretchableImageWithLeftCapWidth:8.0f
                                        topCapHeight:0.0f]
                              forState:UIControlStateNormal];
            
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont boldSystemFontOfSize:20];
            button.titleLabel.shadowColor = [UIColor lightGrayColor];
            button.titleLabel.shadowOffset = CGSizeMake(0, -1);
            
            //button.titleLabel.text = @"Delete Item";
            // button.titleLabel.font = [UIFont systemFontOfSize: 35];
            // printf("Current title = %s", [button.currentTitle  UTF8String]);
            // button.currentTitle = @"Delete Item";
            // UIColor *pClr = [UIColor clearColor];
            //   button.backgroundColor = pClr;
            //UIColor *pTitClr = [UIColor whiteColor];
            [button setTitle:[delegate deleteButtonTitle] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(DeleteConfirm) forControlEvents:UIControlEventTouchDown];
            [cell.contentView addSubview:button];
        }

        
        
    }
    else
    {
        
        return nil;
    }
    
    return cell;   
}




- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    if (indexPath.row == 7)
    {
        AlbumContentsViewController *albumContentsViewController = [AlbumContentsViewController alloc];
        NSLog(@"Pushing AlbumContents view controller %s %d\n" , __FILE__, __LINE__);
        //  albumContentsViewController.assetsGroup = group_;
        [albumContentsViewController setDelphoto:true];
        [albumContentsViewController setPFlMgr:pFlMgr];
        [albumContentsViewController setPAlName:pAlName];
        [albumContentsViewController setNavViewController:navViewController];
        [albumContentsViewController setDelegate:self];
        albumContentsViewController = [albumContentsViewController initWithNibName:@"AlbumContentsViewController" bundle:nil];
        [self.navigationController pushViewController:albumContentsViewController animated:NO];
        [albumContentsViewController  setTitle:[delegate getEditItemTitle]];
        
    }
    else if (indexPath.row == 8)
    {
        MKCoordinateSpan span;
        CLLocationCoordinate2D loc;
        loc.longitude = [delegate getEditLongitude];
        loc.latitude = [delegate getEditLatitude];
        span.latitudeDelta = 0.001;
        span.longitudeDelta = 0.001;
        if (fabs(loc.latitude) > 50.0)
            span.longitudeDelta = 0.002;
        MKCoordinateRegion reg = MKCoordinateRegionMake(loc, span);
        MapViewController *mapViewController = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
        NSLog(@"Setting region to %f %f %f %f\n", reg.center.latitude, reg.center.longitude, reg.span.longitudeDelta, reg.span.latitudeDelta);
        mapViewController.reg = reg;
        mapViewController.title = [delegate getEditItemTitle];
        [self.navigationController pushViewController:mapViewController animated:NO];
    }
    else if (indexPath.row == 6)
    {
        NotesViewController *notesViewController = [NotesViewController alloc];
        NSLog(@"Pushing Notes view controller %s %d\n" , __FILE__, __LINE__);
        notesViewController.delegate =  (id<NotesViewControllerDelegate>)delegate;
        notesViewController.mode = eNotesModeEdit;
        notesViewController.title = [delegate getEditItemTitle];
        notesViewController.notesTxt = [delegate getEditNotes];
        notesViewController = [notesViewController initWithNibName:@"NotesViewController" bundle:nil];
        [self.navigationController pushViewController:notesViewController animated:NO];   
    }
    else if (indexPath.row == 5)
    {
        AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
        if (itemMp != nil)
        {
            [self populateCheckListArrFromItemMp];
        }
        
        if (checkListArr == nil)
        {
            
             checkListArr = [pAppCmnUtil.dataSync getList:[delegate getEditItemKey]];
            if (checkListArr == nil)
            {
            
                EasyAddViewController *aViewController = [EasyAddViewController alloc];
                aViewController.listMode = eListModeEdit;
                
                aViewController = [aViewController initWithNibName:nil bundle:nil];
                pAppCmnUtil.listName = [delegate getAlbumTitle];
            
                [self.navigationController pushViewController:aViewController animated:YES];
            }
            else
            {
                 [self checkListViewDisp];
            }
        }
        else
        {
            [self checkListViewDisp];
        }
    }
    else if (indexPath.row == 4)
    {
            NSLog(@"Show camera selection\n");
            [self AddPicture ];
    }



   
}

-(void) populateCheckListArrFromItemMp
{
    NSMutableArray *arry = [[NSMutableArray alloc] init];
    for (id key in itemMp)
    {
        List *item = [itemMp objectForKey:key];
        [arry addObject:item];
        
    }
    checkListArr = [arry copy];
    
}

-(void) checkListViewDisp
{
     AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    
    List1ViewController *aViewController = [List1ViewController alloc];
    aViewController.editMode = eListModeEdit;
    aViewController.bEasyGroc = false;
    aViewController.mlistName = nil;
    aViewController.bDoubleParent = false;
    aViewController.list = checkListArr;
    ItemKey *itk = [delegate getEditItemKey];
    pAppCmnUtil.listName = itk.name;
    aViewController.name = itk.name;
    aViewController.share_id = itk.share_id;
    aViewController = [aViewController initWithNibName:nil bundle:nil];
    
    [pAppCmnUtil.navViewController pushViewController:aViewController animated:NO];
}

@end
