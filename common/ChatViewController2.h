//
//  ChatViewController2.h
//  common
//
//  Created by Ninan Thomas on 3/26/18.
//  Copyright © 2018 Sinacama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sharing/FriendDetails.h>
#import "ChatInputTextView.h"
#import "CameraControl.h"

@interface ChatViewController2 : UITableViewController<UITextViewDelegate, CameraControlDelegate>
{
    CameraControl *pCameraCntrl;
}

@property (nonatomic, retain) ChatInputTextView *notes;
@property (nonatomic) bool bShowKeyBoard;
@property (nonatomic, retain) FriendDetails *to;
@property (nonatomic) CGFloat notesHeight;
@property (nonatomic, retain ) NSString *initialText;
-(void) saveQAdd:(NSInvocationOperation*) theOp;
-(void) imageFurtherAction:(NSURL *) imgUrl thumbUrl:(NSURL *) turl;
-(void) movieFurtherAction:(NSURL *) movUrl thumbUrl:(NSURL *) turl;
-(void) reloadViews;

@end
