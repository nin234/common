//
//  EditViewController.h
//  Shopper
//
//  Created by Ninan Thomas on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MySlider.h"
#import "ItemKey.h"
#import "AlbumContentsViewController.h"

@protocol EditViewControllerDelegate <NSObject>

-(void) itemEditCancel;
-(void) itemEditDone;
-(void) incrementEditPicCnt;
-(void) setEditAlbumNames:(NSString *)noStr fullName:(NSString *)urlStr;
-(void) saveQAdd:(NSInvocationOperation*) theOp;
-(void) deleteEditItem;
- (void) populateEditValues:(UITextField *)textField;
-(NSArray *) getFieldNames;
-(NSArray *) getSecondFieldNames;
-(bool) isTwoFieldRow:(NSUInteger) row;
-(CGRect) getTextFrame;
-(UILabel *) getLabel;
-(void) populateEditTextFields:(UITextField *) textField textField1:(UITextField *) textField1 row:(NSUInteger)row;
-(bool) isSingleFieldEditRow:(NSUInteger) row;
-(NSString *) deleteButtonTitle;
-(NSString *) getEditItemTitle;
-(double) getEditLongitude;
-(double) getEditLatitude;
-(NSString *) getEditNotes;
-(bool) changeCharacters:(NSInteger) tag;
-(bool) rangeFourTag:(NSInteger) tag;
-(bool) ratingsTag:(NSInteger) tag;
-(bool) numbersTag:(NSInteger) tag;
-(ItemKey *) getEditItemKey;
-(NSString *) getAlbumTitle;
-(NSUInteger) getEditItemShareId;
@end

@interface EditViewController : UITableViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, AlbumContentsViewControllerDelegate>
{
    bool bInPicCapture;
    NSMetadataQuery *query;
    bool bSaveLastPic;
    bool bInShowCam;
    struct timeval last_mode_change;
    bool processQuery;
    NSArray *checkListArr;
}
 

@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (strong, nonatomic) UIBarButtonItem *pBarItem;
@property (strong, nonatomic) UIBarButtonItem *pBarItem3;
@property (nonatomic, retain) MySlider *pSlider;
@property int nSmallest;
@property bool bSliderPic;
- (void)sliderUpdate:(id)sender;


-(void) DeleteConfirm;
-(void) AddPicture;
-(void) saveImage:(UIImage *)image;
-(void) saveMovie:(NSURL *)movie;

@property (nonatomic, retain) NSMutableArray *tnailurls;
@property (nonatomic, retain) NSMutableArray *movurls;
@property (nonatomic, retain) NSString *pAlName;
@property (nonatomic, retain) NSFileManager *pFlMgr;
@property (nonatomic, retain) NSMutableDictionary *itemMp;

@property (nonatomic, retain)  UINavigationController *navViewController;

@property (nonatomic, retain) id<EditViewControllerDelegate> delegate;
-(void) populateCheckListArrFromItemMp;


@end
