//
//  NotesViewController.h
//  Shopper
//
//  Created by Ninan Thomas on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

enum eNotesMode
{
    eNotesModeDisplay,
    eNotesModeEdit,
    eNotesModeAdd
};

@protocol NotesViewControllerDelegate <NSObject>

-(void ) setAddNotes:(NSString *)notes;
-(void) setEditNotes: (NSString *)notes;

@end

@interface NotesViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, retain) UITextView *notes;
@property (strong, nonatomic) NSString *notesTxt;
@property enum eNotesMode mode;

@property (nonatomic, weak) id<NotesViewControllerDelegate> delegate;

@end
