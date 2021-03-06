//
//  NotesViewController.m
//  Shopper
//
//  Created by Ninan Thomas on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppCmnUtil.h"
#import "NotesViewController.h"


@implementation NotesViewController

@synthesize notes;
@synthesize notesTxt;
@synthesize mode;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        CGRect mainScrn = [UIScreen mainScreen].bounds;
        AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
        
        if (pAppCmnUtil.bEasyGroc)
        {
            CGRect tableRect = CGRectMake(0, mainScrn.origin.y + self.navigationController.navigationBar.frame.size.height, mainScrn.size.width, mainScrn.size.height - self.navigationController.navigationBar.frame.size.height - self.navigationController.tabBarController.tabBar.frame.size.height);
            notes = [[UITextView alloc] initWithFrame:tableRect];
        }
        else
        {
            notes = [[UITextView alloc] initWithFrame:CGRectMake(0, 20, 320, 420)];
        }
        if (notesTxt != nil && [notesTxt length] > 0)
        {
            notes.text = notesTxt;
            NSLog(@"Notes set to %@", notes.text);
        }
        
        if (mode == eNotesModeDisplay)
        {
            notes.editable = NO;
           // notes.selectable =NO;
        }

        
             notes.delegate = self;
        [self.view addSubview:notes];
        
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)textViewDidChange:(UITextView *)textView
{
    notesTxt = textView.text;
    NSLog(@"Notes changed to %@", textView.text);
    if (mode == eNotesModeAdd)
        [delegate setAddNotes:textView.text];
    else if (mode == eNotesModeEdit)
        [delegate setEditNotes:textView.text];
    else
        NSLog(@"Invalid notes mode");
    return;
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Observe keyboard hide and show notifications to resize the text view appropriately.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Responding to keyboard events

- (void)keyboardWillShow:(NSNotification *)notification
{
    
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardTop = keyboardRect.origin.y;
    CGRect newTextViewFrame = self.view.bounds;
    newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y;
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    notes.frame = newTextViewFrame;
    
    [UIView commitAnimations];
}


- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    notes.frame = self.view.bounds;
    
    [UIView commitAnimations];
}



@end
