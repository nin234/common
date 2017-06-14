//
//  AddViewController.h
//  Shopper
//
//  Created by Ninan Thomas on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AssetsLibrary/AssetsLibrary.h>
#import "Foundation/NSOperation.h"
#import <MapKit/MapKit.h>
#import "MySlider.h"
#include <sys/time.h>
#import "AlbumContentsViewController.h"

@protocol AddViewControllerDelegate <NSObject>

-(void) initializeNewItem;
-(void) setAlbumNames:(NSString *)noStr fullName:(NSString *)urlStr;
-(void) setLocation:(double) lat longitude:(double) longtde;
-(void) stopLocUpdate;
-(bool) updateAddress:(NSString *)street city:(NSString *)city state:(NSString *) state country:(NSString * )country zip:(NSString *)zip;
-(void) incrementPicCnt;
-(void) saveQAdd:(NSInvocationOperation*) theOp;
- (void) populateValues:(UITextField *)textField;
-(void) populateTextFields:(UITextField *) textField textField1:(UITextField *) textField1 row:(NSUInteger) row;
-(NSArray *) getFieldNames;
-(NSArray *) getSecondFieldNames;
-(bool) isTwoFieldRow:(NSUInteger) row;
-(CGRect) getTextFrame;
-(UILabel *) getLabel;
-(bool) isSingleFieldRow:(NSUInteger) row;
-(void) itemAddCancel;
-(void) itemAddDone;
-(NSString *) setTitle;
-(NSString *) getAlbumTitle;
-(NSString *) getNotes;
-(double) getLongitude;
-(double) getLatitude;
-(NSString *) getName;
- (BOOL)characterChk:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;


@end

@interface AddViewController : UITableViewController <UIImagePickerControllerDelegate, UITextFieldDelegate, UITableViewDelegate, MKMapViewDelegate, AlbumContentsViewControllerDelegate>
{
 //   ALAssetsLibrary *assetsLibrary;
    
  //   MKReverseGeocoder *reverseGeocoder;
    CLGeocoder *geocoder;
    bool bInPicCapture;
    bool bSaveLastPic;
     NSDate *locationManagerStartDate;
    MKMapView *mapView;
    bool bInShowCam;
    struct timeval last_mode_change;
    bool ingeorevcoding;
    NSMutableArray *locArry;
}


-(void) AddPicture;
- (void)textChanged:(id)sender;
-(void) updatePlaceMark:(CLPlacemark *)placemark;
-(void) revGeoCodeNextPoint;
- (void)sliderUpdate:(id)sender;
- (void) setLocation:(CLLocation *)loc;
-(void) saveImage:(UIImage *)image;
-(void) saveMovie:(NSURL *)movie;

@property int nLargest;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic, retain) NSString *pAlName;
@property (strong, nonatomic) UIBarButtonItem *pBarItem;
@property (strong, nonatomic) UIBarButtonItem *pBarItem3;
@property (nonatomic, retain) MySlider *pSlider;

//@property (nonatomic, retain) MKMapView *mapView;

@property bool bSliderPic;
@property int locCnt;
@property (nonatomic, retain) NSFileManager *pFlMgr;
@property (nonatomic, retain)  UINavigationController *navViewController;
@property (nonatomic, retain) id<AddViewControllerDelegate> delegate;

@end
