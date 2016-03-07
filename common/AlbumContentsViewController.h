/*
    File: AlbumContentsViewController.h
Abstract: View controller to manaage displaying the contents of an album.
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

#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>

#import "AlbumContentsTableViewCell.h"

#define   PHOTOREQSOURCE_FB_1 1

@protocol AlbumContentsViewControllerDelegate <NSObject>

@optional

-(void) photoSelDone;
-(void) photoSelCancel;
-(void) saveImage:(UIImage *)image;
-(void) saveMovie:(NSURL *)movie;

@end

@interface AlbumContentsViewController : UITableViewController <AlbumContentsTableViewCellSelectionDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
//    ALAssetsGroup *assetsGroup;
//    NSMutableArray *assets;
 //   IBOutlet AlbumContentsTableViewCell *tmpCell;
    NSUInteger lastSelectedRow;
    NSMetadataQuery *query;
    bool bIniCloud;

}

-(void) deletedPhotoAtIndx : (NSUInteger) nIndx;
-(void) getAttchmentsUrls;

-(void) camerarollAction;
//@property (nonatomic, retain) ALAssetsGroup *assetsGroup;
@property (nonatomic, assign) IBOutlet AlbumContentsTableViewCell *tmpCell;
@property  NSUInteger nPicCnt;
@property (nonatomic, retain) NSArray *thumbnails;
@property (nonatomic, retain) NSArray *tnailsquery;
//@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *street;
@property bool delphoto;
@property bool gotqueryres;
@property bool reload;
@property bool processQuery;
@property bool emailphoto;
@property int photoreqsource;
@property (nonatomic, retain) NSMutableArray *photoSel;
@property (nonatomic, retain) NSMutableArray *attchments;
@property (nonatomic, retain) NSMutableArray *movOrImg;

@property (nonatomic, retain) NSString *pAlName;
@property (nonatomic, retain) NSFileManager *pFlMgr;
@property (nonatomic, retain)  UINavigationController *navViewController;

@property(nonatomic, weak) id<AlbumContentsViewControllerDelegate> delegate;

@end
