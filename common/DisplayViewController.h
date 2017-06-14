//
//  DisplayViewController.h
//  Shopper
//
//  Created by Ninan Thomas on 1/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@protocol DisplayViewControllerDelegate <NSObject>

-(void) itemEdit;
-(NSArray *) getFieldDispNames;
-(NSArray *) getSecondFieldNames;
-(bool) isTwoFieldRow:(NSUInteger) row;
-(void) populateDispTextFields:(UILabel *) textField textField1:(UILabel *) textField1 row:(NSUInteger)row;
-(bool) isSingleFieldDispRow:(NSUInteger) row;
-(NSString *) getDispItemTitle;
-(double) getDispLatitude;
-(double) getDispLongitude;
-(NSString *) getDispNotes;
-(NSString *) getDispName;
-(NSString*) setTitle;

@end

@interface DisplayViewController : UITableViewController
{

//ALAssetsLibrary *assetsLibrary;
   // ALAssetsGroup *group_;
    NSMetadataQuery *query;
    NSArray *checkListArr;
}

@property int nSmallest;
@property bool processQuery;

@property (nonatomic, retain) NSString *pAlName;
@property (nonatomic, retain) NSFileManager *pFlMgr;
@property (nonatomic, retain)  UINavigationController *navViewController;
@property (nonatomic, retain) id<DisplayViewControllerDelegate> delegate;

@end
