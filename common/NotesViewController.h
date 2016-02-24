//
//  NotesViewController.h
//  Shopper
//
//  Created by Ninan Thomas on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotesViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, retain) UITextView *notes;
@property (strong, nonatomic) NSString *notesTxt;;

@end
