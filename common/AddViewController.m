//
//  AddViewController.m
//  Shopper
//
//  Created by Ninan Thomas on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AddViewController.h"
#import <MapKit/MapKit.h>
#import "AlbumContentsViewController.h"
#import "MapViewController.h"
#import "NotesViewController.h"

#import <AssetsLibrary/ALAssetsGroup.h>
#include <sys/types.h>
#include <dirent.h>
#include <stdlib.h>
#import "ImageIO/ImageIO.h"
#import "CoreFoundation/CoreFoundation.h"
#include <MobileCoreServices/UTCoreTypes.h>
#include <MobileCoreServices/UTType.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AVFoundation/AVAssetImageGenerator.h"
#import "AVFoundation/AVAsset.h"
#import "AVFoundation/AVTime.h"
#import "CoreMedia/CMTime.h"
#import "textdefs.h"
#import "EasyAddViewController.h"
#import "AppCmnUtil.h"
#import "List1ViewController.h"



@implementation AddViewController

@synthesize delegate;
@synthesize nLargest;
@synthesize imagePickerController;
@synthesize pBarItem;
@synthesize pBarItem3;
@synthesize pSlider;
@synthesize bSliderPic;
//@synthesize mapView;
@synthesize locCnt;
@synthesize pFlMgr;
@synthesize pAlName;
@synthesize navViewController;


CGImageRef MyCreateThumbnailImageFromData (NSData * data, int imageSize);

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
      //  CGRect mapFrame = CGRectMake(90, 12, 200, 25);
        locationManagerStartDate = [NSDate date];
     
        bInShowCam = false;
        //  CGRect mapFrame = CGRectMake(90, 12, 200, 25);
       //  mapView = [[MKMapView alloc] initWithFrame:mapFrame];
        // mapView.showsUserLocation = YES;
        // mapView.delegate = self;
        
        locCnt = 0;
        ingeorevcoding = false;
        locArry = [[NSMutableArray alloc] init];
        self.tableView.delegate = self;
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
        
        [delegate initializeNewItem];
        
        
        bInPicCapture = false;
        bSaveLastPic = false;
        printf("printing album names\n");
       
            
        self.nLargest = 0;
            
            // pDlg.pFlMgr = [[NSFileManager alloc] init];
            NSString *pHdir = NSHomeDirectory();
            NSString *pAlbums = @"/Documents/albums";
            NSString *pAlbumsDir = [pHdir stringByAppendingString:pAlbums];
            NSLog(@"create new album name in directory %@", pAlbumsDir);
            struct timeval tv;
            gettimeofday(&tv, NULL);
            long long sec = ((long long)tv.tv_sec)*1000000;
            long long usec = tv.tv_usec;
             long long alNo =  sec+ usec;
            NSString *intStr = [[NSNumber numberWithLongLong:alNo] stringValue];
            NSLog(@"Album params alNo=%lld tv_sec=%ld tv_usec=%d intStr=%@ sec=%lld usec=%lld", alNo,tv.tv_sec, tv.tv_usec, intStr, sec, usec);
            pAlbumsDir = [pAlbumsDir stringByAppendingString:@"/"];
            NSString *pNewAlbum = [pAlbumsDir stringByAppendingString:intStr];
            NSString *pThumpnail = [pNewAlbum stringByAppendingPathComponent:@"thumbnails"];
            BOOL  bDirCr = [pFlMgr createDirectoryAtPath:pThumpnail withIntermediateDirectories:YES attributes:nil error:nil];
            NSURL *url = [NSURL fileURLWithPath:pNewAlbum isDirectory:YES];
            [delegate setAlbumNames:intStr fullName:[url absoluteString]];
        pAlName = [url absoluteString];
            if(bDirCr == YES)
            {
                NSLog (@"Created new album %s album_name %@\n", [pThumpnail UTF8String], intStr);
            }
        
       
    }
    
    return self;
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
        
        UIToolbar *bar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, barY, 325, barHeight)];
        

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
        
        UIToolbar *bar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, barY, 325, barHeight)];
        

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
   // [self presentModalViewController:imagePickerController animated:YES];
}

- (void) setLocation:(CLLocation *)loc
{
    if (locCnt < 9)
    {
        locCnt++;
        if(ingeorevcoding)
        {
            [locArry addObject:loc];
            return;
        }
        
        ingeorevcoding = true;
        [locArry removeAllObjects];
        NSLog(@"starting reverse geocoder in set location \n");
        if (!geocoder)
            geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:loc completionHandler:
         ^(NSArray* placemarks, NSError* error){
             if (placemarks != nil && [placemarks count] > 0)
             {
                 [self updatePlaceMark:[placemarks objectAtIndex:0]];
             }
             else
             {
                 [self revGeoCodeNextPoint];
             }
                 
                 
         }];
        [delegate setLocation:loc.coordinate.latitude longitude:loc.coordinate.longitude];
    }
    else
    {
        [delegate stopLocUpdate];
    }
}

-(void) revGeoCodeNextPoint
{
    if([locArry count])
    {
        CLLocation *loc = [locArry objectAtIndex:[locArry count]-1];
        NSLog(@"starting reverse geocoder in set location %@  count=%lu\n", loc,(unsigned long)[locArry count]);
        [geocoder reverseGeocodeLocation:loc completionHandler:
         ^(NSArray* placemarks, NSError* error)
         {
             if (placemarks != nil && [placemarks count] > 0)
             {
                 [self updatePlaceMark:[placemarks objectAtIndex:0]];
             }
             else
             {
                 [self revGeoCodeNextPoint];
             }
             
         }];
        [delegate setLocation:loc.coordinate.latitude longitude:loc.coordinate.longitude];
        [locArry removeAllObjects];
    }
    else
        ingeorevcoding = false;

    return;
}

- (BOOL)isValidLocation:(CLLocation *)newLocation
{
    // Filter out nil locations
    if (!newLocation)
    {
        NSLog (@"Empty new location\n");
        return NO;
    }
    
    // Filter out points by invalid accuracy
    if (newLocation.horizontalAccuracy < 0)
    {
         NSLog (@"Invalid horizontal accuracy\n");
        return NO;
    }
    
    if (newLocation.verticalAccuracy < 0)
    {
         NSLog (@"Invalid vertical accuracy\n");
        return NO;
    }

    // Filter out points created before the manager was initialized
    NSTimeInterval secondsSinceManagerStarted =
    [newLocation.timestamp timeIntervalSinceDate:locationManagerStartDate];
    
    if (secondsSinceManagerStarted < 0)
    {
        NSLog (@"Invalid start time\n");
        return NO;
    }
    
    // The newLocation is good to use
    static int i=0;
    if (!i)
    {
        ++i;
        NSLog (@"Not Init\n");
        
        return NO;
    }
     NSLog (@"Valid location\n");
    return YES;
}

- (void)mapView:(MKMapView *)mapViewL didUpdateUserLocation:(MKUserLocation *)userLocation
{
   
    CLLocation *loc = [userLocation location];
    NSLog(@"Got did update user location latitude=%f longitude=%f\n", loc.coordinate.latitude, loc.coordinate.longitude);
    NSLog(@"starting reverse geocoder\n");
    [self setLocation:loc];
    

}

- (void)updatePlaceMark:(CLPlacemark *)placemark
{
    NSLog(@"Got placemark in update placemark %@ %s %s\n", placemark, [[placemark locality] UTF8String], [[placemark thoroughfare] UTF8String]);
    NSString* street = @"";
    if ([placemark subThoroughfare] != nil)
    {
        NSLog(@"Appending street no\n");
        street = [NSString stringWithUTF8String:[[placemark subThoroughfare] UTF8String]];
        street = [street stringByAppendingString:@" "];
    }
    
    if ([placemark thoroughfare] != nil)
    {
        
        
        if (street != nil)
        {
            NSString *streetname = [NSString stringWithUTF8String:[[placemark thoroughfare] UTF8String]];
            street = [street stringByAppendingString:streetname];
        }
        else
        {
            street = [NSString stringWithUTF8String:[[placemark thoroughfare] UTF8String]];
        }
        
        //street = [street stringByAppendingString:placemark.thoroughfare];
    }
    
    NSString *city = @"";
    
    if ([placemark subLocality] != nil)
    {
        NSLog(@"Appending sublocality \n");
        city = [NSString stringWithUTF8String:[[placemark subLocality] UTF8String]];
        city = [city stringByAppendingString:@" "];
        
    }
    
    if ([placemark locality] != nil)
    {
        
        if (city == nil)
        {
            city = [NSString stringWithUTF8String:[[placemark locality] UTF8String]];
        }
        else 
        {
            NSString *cityname = [NSString stringWithUTF8String:[[placemark locality] UTF8String]];
            if (cityname != nil)
            {
                NSUInteger loclen = [cityname length];
                NSUInteger subloclen = [city length];
                NSUInteger len = subloclen + loclen;
                if (len < 24)
                    city = [city stringByAppendingString:cityname];
                else
                    city = [NSString stringWithUTF8String:[cityname UTF8String]];
            }
           

        }
    }
    
    /*   
     if ([placemark subAdministrativeArea] != nil)
     {
     state = [NSString stringWithUTF8String:[[placemark subAdministrativeArea] UTF8String]];
     state = [state stringByAppendingString:@" "];
     }
     */
    NSString *state = @"";
    
    if ([placemark administrativeArea] != nil)
    {
        if (state != nil)
        {
            NSString *statename = [NSString stringWithUTF8String:[[placemark administrativeArea] UTF8String]];
            state = [state stringByAppendingString:statename];
        }
        else
        {
            state = [NSString stringWithUTF8String:[[placemark administrativeArea] UTF8String]];
        }
        
    }
    
    NSString *country;
    if ([placemark country] != nil)
    {
        country = [NSString stringWithUTF8String:[[placemark country] UTF8String]];
    }
    
    NSString *zip;
    
    if ([placemark postalCode] != nil)
    {
        zip = [NSString stringWithUTF8String:[[placemark postalCode] UTF8String]];
        
    }
    NSLog(@"Address %@ %@ %@ %@ %@\n", street, city, state, country, zip);
    if ([delegate updateAddress:street city:city state:state country:country zip:zip])
    {
        [self.tableView reloadData];

    }
    else
    {
        NSLog (@"Addres did not change in updatePlaceMark not updating\n");
    }
   
    if([locArry count])
    {
        CLLocation *loc = [locArry objectAtIndex:[locArry count]-1];
       NSLog(@"starting reverse geocoder in set location %@  count=%lu\n", loc,(unsigned long)[locArry count]);
        [geocoder reverseGeocodeLocation:loc completionHandler:
         ^(NSArray* placemarks, NSError* error)
        {
            if ([placemarks count] > 0)
            {
                [self updatePlaceMark:[placemarks objectAtIndex:0]];
            }
         }];
        [delegate setLocation:loc.coordinate.latitude longitude:loc.coordinate.longitude];
       
         [locArry removeAllObjects];
    }
    else
        ingeorevcoding = false;
    

}



-(void) loadView
{
    [super loadView];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    NSLog(@"13 rows in section %ld of AddViewController\n" , (long)section);
    return 14;
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
    
    UIToolbar *bar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, barY, 325, barHeight)];
   

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

CGImageRef MyCreateThumbnailImageFromData (NSData * data, int imageSize)
{
    CGImageRef        myThumbnailImage = NULL;
    CGImageSourceRef  myImageSource;
    CFDictionaryRef   myOptions = NULL;
    CFStringRef       myKeys[3];
    CFTypeRef         myValues[3];
    CFNumberRef       thumbnailSize;
    
    // Create an image source from NSData; no options.
    myImageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data,
                                                NULL);
    // Make sure the image source exists before continuing.
    if (myImageSource == NULL){
        fprintf(stderr, "Image source is NULL.");
        return  NULL;
    }
    
    // Package the integer as a  CFNumber object. Using CFTypes allows you
    // to more easily create the options dictionary later.
    thumbnailSize = CFNumberCreate(NULL, kCFNumberIntType, &imageSize);
    
    // Set up the thumbnail options.
    myKeys[0] = kCGImageSourceCreateThumbnailWithTransform;
    myValues[0] = (CFTypeRef)kCFBooleanTrue;
    myKeys[1] = kCGImageSourceCreateThumbnailFromImageIfAbsent;
    myValues[1] = (CFTypeRef)kCFBooleanTrue;
    myKeys[2] = kCGImageSourceThumbnailMaxPixelSize;
    myValues[2] = (CFTypeRef)thumbnailSize;
    int size;
    if (CFNumberGetValue(thumbnailSize, kCFNumberIntType, &size))
        {
            NSLog(@"thumbnailsize %d \n", size);
        }
    
    myOptions = CFDictionaryCreate(NULL, (const void **) myKeys,
                                   (const void **) myValues, 2,
                                   &kCFTypeDictionaryKeyCallBacks,
                                   & kCFTypeDictionaryValueCallBacks);
    
    // Create the thumbnail image using the specified options.
    myThumbnailImage = CGImageSourceCreateThumbnailAtIndex(myImageSource,
                                                           0,
                                                           myOptions);
    // Release the options dictionary and the image source
    // when you no longer need them.
    CFRelease(thumbnailSize);
    CFRelease(myOptions);
    CFRelease(myImageSource);
    
    // Make sure the thumbnail image exists before continuing.
    if (myThumbnailImage == NULL){
        fprintf(stderr, "Thumbnail image not created from image source.");
        return NULL;
    }
    
    return myThumbnailImage;
}

-(void) saveMovie:(NSURL *)movie
{
    [delegate incrementPicCnt];
    struct timeval tv;
    gettimeofday(&tv, 0);
    long filno = tv.tv_sec/2;
    NSString *pFlName = [[NSNumber numberWithLong:filno] stringValue];
    NSString *pImgFlName = [pFlName stringByAppendingString:@".jpg"];
    
    pFlName = [pFlName stringByAppendingString:@".MOV"];
    NSString *pFlPath = [pAlName stringByAppendingString:@"/"];
    pFlPath = [pFlPath stringByAppendingString:pFlName];
    NSURL *movurl = [NSURL URLWithString:pFlPath];
    NSData *data = [NSData dataWithContentsOfURL:movie];
    if ([data writeToURL:movurl atomically:YES] == NO)
    {
        printf("Failed to write to file %ld\n", filno);
        // --nAlNo;
        
    }
    else
    {
        NSLog(@"Save file %ld in album %@ filename %@ URL %@\n", filno, movurl, pFlPath, movie);
    }
    
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
        NSString *pTmpNlFlPath = [pAlName stringByAppendingString:@"/thumbnails/"];
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
            NSLog(@"Save thumbnail file %ld in album %s file %@\n", filno, [pAlName UTF8String], thumburl);
        }

       return;
}

-(void) saveImage:(UIImage *)image
{
    [delegate incrementPicCnt];
    struct timeval tv;
    gettimeofday(&tv, 0);
    long filno = tv.tv_sec/2;
    NSString *pFlName = [[NSNumber numberWithLong:filno] stringValue];
     
    pFlName = [pFlName stringByAppendingString:@".jpg"];
   
    NSString *pFlPath = [pAlName stringByAppendingString:@"/"];
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
        NSLog(@"Save file %ld in album %s file %@\n", filno, [pAlName UTF8String], imgurl);
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
    NSString *pTmpNlFlPath = [pAlName stringByAppendingString:@"/thumbnails/"];
    pTmpNlFlPath = [pTmpNlFlPath stringByAppendingString:pFlName];
    NSURL *thumburl = [NSURL URLWithString:pTmpNlFlPath];
    if ([thumbnaildata writeToURL:thumburl atomically:YES] == NO)
    {
        printf("Failed to write to thumbnail file %ld\n", filno);
       // --nAlNo;
        
    }
    else
    {
         NSLog(@"Save thumbnail file %ld in album %s file %@\n", filno, [pAlName UTF8String], thumburl);
    }
    
    

}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    
        [theTextField resignFirstResponder];
  
    return YES;
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

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Editing ended at row at IndexPath %ld in AddViewController\n", (long)indexPath.row);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSLog(@"Text field should change character %s %ld %lu %lu\n", [textField.text UTF8String], (long)textField.tag, (unsigned long)range.location , (unsigned long)range.length);
    switch (textField.tag)
    {
        case HOUSE_PRICE:
        case HOUSE_AREA:
        case HOUSE_BATHS:
        case HOUSE_BEDS:
        case HOUSE_YEAR:
        break;
            
        default:
            return YES;
            break;
    }
    
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
    if (textField.tag == HOUSE_YEAR)
    {
        if (range.location >= 4)
            return NO;
        characterSet = [[NSCharacterSet characterSetWithCharactersInString:numbers] invertedSet];   
    }
    else
    {
    
        NSRange separatorRange = [textField.text rangeOfString:symbol];
        if (separatorRange.location == NSNotFound)
        {
            //  if ([symbol isEqualToString:@"."]) {
            characterSet = [[NSCharacterSet characterSetWithCharactersInString:numbersPeriod] invertedSet];
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
    [delegate populateValues:textField];
        return;
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    
     NSLog(@"Text field did end editing %s %ld\n", [textField.text UTF8String], (long)textField.tag);
    return YES;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{ 
    if (indexPath.row == 0)
        cell.backgroundColor = [UIColor yellowColor];
    return;
}

- (UITableViewCell *)
tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"acctdetail";
    static NSArray* fieldNames = nil;
    if (!fieldNames)
    {
        fieldNames = [delegate getFieldNames];
    }
    
   // NSLog(@"Showing row in AddViewController row %d in section %d\n",indexPath.row, indexPath.section);
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
                [cell.contentView addSubview:textField1];
                textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                
                [delegate populateTextFields:textField textField1:textField1 row:row];
            }
            else if ([delegate isSingleFieldRow:row])
            {
                CGRect textFrame;
			
                // put a label and text field in the cell
                if (row == 0)
                    cell.backgroundColor = [UIColor yellowColor];
                UILabel *label;
                if (row != 12)
                    label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 75, 25)];
                else
                     label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 105, 25)];
                label.textAlignment = NSTextAlignmentLeft;
                label.font = [UIFont boldSystemFontOfSize:14];
                if (row == 0)
                    label.backgroundColor = [UIColor yellowColor];
                [cell.contentView addSubview:label];
                if (row != 13)
                    textFrame = CGRectMake(75, 12, 200, 25);
                else
                    textFrame = CGRectMake(110, 12, 170, 25);
                UITextField *textField = [[UITextField alloc] initWithFrame:textFrame];
                [delegate populateTextFields:textField textField1:nil row:row];
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
                
                NSString *pAlMoc = pAlName;
                printf("Selected album name %s\n", [pAlMoc UTF8String]);
                int nSmallest = 0;
             //   DIR *dirp = opendir([pAlMoc UTF8String]);
             //   struct dirent *dp;
                char szFileNo[64];
                               
                NSURL *albumurl = [NSURL URLWithString:pAlMoc];
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
                            unsigned long size = strcspn([pFil UTF8String], ".");
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
                
                if (nSmallest)
                {
                    NSString *pFlName = [[NSNumber numberWithInt:nSmallest] stringValue];
                    pFlName = [pFlName stringByAppendingString:@".jpg"];
                    NSString *pFlPath = [pAlMoc stringByAppendingString:@"/thumbnails/"];
                    pFlPath = [pFlPath stringByAppendingString:pFlName];
                    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:pFlPath]]];
                    NSLog(@"Set icon image %@ in AddViewController\n", pFlPath);
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
            
                       
    }
    else
    {
        
        return nil;
    }
    
    return cell;   
}



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void) itemAddCancel
{
    [delegate itemAddDone];
    return;
}

-(void) itemAddDone
{
    AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    [pAppCmnUtil.dataSync addItem:[delegate getName] itemsDic:pAppCmnUtil.itemsMp];
    pAppCmnUtil.itemsMp = nil;
  

    [delegate itemAddCancel];
    return;
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.navigationItem.title = [NSString stringWithString:[delegate setTitle]];
    
    UIBarButtonItem *pBarItemAddDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(itemAddDone) ];
    self.navigationItem.rightBarButtonItem = pBarItemAddDone;
    UIBarButtonItem *pBarItemAddCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(itemAddCancel) ];
    self.navigationItem.leftBarButtonItem = pBarItemAddCancel;

    
}

-(void) viewDidAppear:(BOOL)animated    
{
    [super viewDidAppear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
   
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
     // ...  // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    if (indexPath.row == 7)
    {
        AlbumContentsViewController *albumContentsViewController = [[AlbumContentsViewController alloc] initWithNibName:@"AlbumContentsViewController" bundle:nil];
        NSLog(@"Pushing AlbumContents view controller %s %d\n" , __FILE__, __LINE__);
        //  albumContentsViewController.assetsGroup = group_;
        [albumContentsViewController setDelphoto:true];
        [albumContentsViewController setPFlMgr:pFlMgr];
        [albumContentsViewController setPAlName:pAlName];
        [albumContentsViewController setNavViewController:navViewController];
        [albumContentsViewController setDelegate:self];
        [self.navigationController pushViewController:albumContentsViewController animated:NO];
     
        [albumContentsViewController  setTitle:[delegate getAlbumTitle]];
        navViewController.navigationBar.topItem.title = [NSString stringWithString:[delegate getAlbumTitle]];
        UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:albumContentsViewController action:@selector(camerarollAction) ];
        navViewController.navigationBar.topItem.rightBarButtonItem = pBarItem1;
        
    }
    else if (indexPath.row == 8)
    {
        MKCoordinateSpan span;
        span.latitudeDelta = 0.001;
        span.longitudeDelta = 0.001;
        CLLocationCoordinate2D loc;
        loc.longitude = [delegate getLongitude];
        loc.latitude = [delegate getLatitude];
        if (fabs(loc.latitude) > 50.0)
            span.longitudeDelta = 0.002;
        MKCoordinateRegion reg = MKCoordinateRegionMake(loc, span);
        MapViewController *mapViewController = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
        NSLog(@"Setting region to %f %f %f %f\n", reg.center.latitude, reg.center.longitude, reg.span.longitudeDelta, reg.span.latitudeDelta);
        mapViewController.reg = reg;
        mapViewController.title = [delegate getAlbumTitle];
        [self.navigationController pushViewController:mapViewController animated:NO];
    }
    else if (indexPath.row == 6)
    {
        NotesViewController *notesViewController = [NotesViewController alloc];
        notesViewController.notesTxt = [delegate getNotes];
        notesViewController = [notesViewController initWithNibName:@"NotesViewController" bundle:nil];
        NSLog(@"Pushing Notes view controller %s %d\n" , __FILE__, __LINE__);
        //  albumContentsViewController.assetsGroup = group_;
        notesViewController.title = [delegate getAlbumTitle];
        [self.navigationController pushViewController:notesViewController animated:NO];   
    }
    else if (indexPath.row == 5)
    {
        AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
        if (pAppCmnUtil.itemsMp == nil)
        {
                EasyAddViewController *aViewController = [[EasyAddViewController alloc]
                                                  initWithNibName:nil bundle:nil];
        
                pAppCmnUtil.listName = [delegate getAlbumTitle];

            [self.navigationController pushViewController:aViewController animated:YES];
        }
        else
        {
            
            List1ViewController *aViewController = [List1ViewController alloc];
            aViewController.editMode = eListModeAdd;
            aViewController.bEasyGroc = false;
            aViewController.mlistName = nil;
            aViewController.bDoubleParent = false;
            aViewController = [aViewController initWithNibName:nil bundle:nil];
            
            [pAppCmnUtil.navViewController pushViewController:aViewController animated:NO];

            
        }
    }
    else if (indexPath.row == 4)
    {
        NSLog(@"Show camera selection\n");
        [self AddPicture ];
    }
}


@end
