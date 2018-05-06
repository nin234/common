//
//  ChatViewController2.m
//  common
//
//  Created by Ninan Thomas on 3/26/18.
//  Copyright © 2018 Sinacama. All rights reserved.
//

#import "ChatViewController2.h"
#import "ChatsSharingDelegate.h"
 #import <QuartzCore/QuartzCore.h>


@interface ChatViewController2 ()

@end

@implementation ChatViewController2

@synthesize notes;
@synthesize bShowKeyBoard;
@synthesize to;
@synthesize notesHeight;
@synthesize initialText;

-(void) saveQAdd:(NSInvocationOperation*) theOp
{
    ChatsSharingDelegate *pShrDelegate = [ChatsSharingDelegate sharedInstance];
    [pShrDelegate.saveQ addOperation:theOp];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        //self.tableView.estimatedRowHeight = notesHeight;
        //self.tableView.rowHeight = UITableViewAutomaticDimension;
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.tableView setSeparatorColor:[UIColor clearColor]];
        pCameraCntrl = [[CameraControl alloc] init];
        pCameraCntrl.delegate = self;
        if (bShowKeyBoard)
        {
            self.tableView.scrollEnabled = NO;
        }
        self.tableView.allowsSelection = NO;
    }
    
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    return notesHeight + 20;
}

-(void) sendMsg
{
    NSLog (@"Sending message %@", notes.text);
    ChatsSharingDelegate *pShrDelegate = [ChatsSharingDelegate sharedInstance];
    [pShrDelegate sendMsg:to Msg:notes.text];
}

-(void) showCamera
{
    NSLog(@"Showing camera");
    [pCameraCntrl showCamera:self];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return 10.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *v = [UIView new];
    [v setBackgroundColor:[UIColor clearColor]];
    return v;
}

-(void) imageFurtherAction:(NSURL *) imgUrl thumbUrl:(NSURL *) turl
{
    NSLog (@"Sending picture %@", imgUrl);
    ChatsSharingDelegate *pShrDelegate = [ChatsSharingDelegate sharedInstance];
    [pShrDelegate sendPicture:to Msg:imgUrl];
}

-(void) movieFurtherAction:(NSURL *) movUrl thumbUrl:(NSURL *) turl
{
    NSLog (@"Sending movie %@", movUrl);
    ChatsSharingDelegate *pShrDelegate = [ChatsSharingDelegate sharedInstance];
    [pShrDelegate sendMovie:to Msg:movUrl];
}


- (void)textViewDidChange:(UITextView *)textView
{
    
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    NSLog(@"Old frame height=%lf width=%lf new frame height =%lf width=%lf", newFrame.size.height, newFrame.size.width, textView.frame.size.height, textView.frame.size.width);
    if (fabs(textView.frame.size.height - newFrame.size.height) > 10.0)
    {
        ChatsSharingDelegate *pShrDelegate = [ChatsSharingDelegate sharedInstance];
        NSLog(@"redrawViews with initial text=%@", textView.text);
        [pShrDelegate    redrawViews:newFrame.size.height+10 text:textView.text];
    }
    
}

-(void) reloadViews
{
    ChatsSharingDelegate *pShrDelegate = [ChatsSharingDelegate sharedInstance];
    NSLog(@"redrawViews with text=%@", notes.text);
    [pShrDelegate    redrawViews:notes.frame.size.height text:notes.text];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *CellIdentifier = @"ChatVwCell2";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    else
    {
        NSArray *pVws = [cell.contentView subviews];
        int cnt = (int)[pVws count];
        for (NSUInteger i=0; i < cnt; ++i)
        {
            [[pVws objectAtIndex:i] removeFromSuperview];
        }
        cell.imageView.image = nil;
        cell.textLabel.text = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    // Configure the cell...
    CGRect mainScrn= [[UIScreen mainScreen] bounds];
    CGRect  notesRect;
    CGFloat notesX = 10.0;
    if (!bShowKeyBoard)
    {
        
        
        CGRect buttonRect;
        buttonRect = CGRectMake(notesX, 0, notesHeight, notesHeight);
        UIButton *button = [[UIButton alloc] initWithFrame:buttonRect];
        [button setBackgroundImage:[[UIImage imageNamed:@"camera.png"]
                                    stretchableImageWithLeftCapWidth:0.0f
                                    topCapHeight:0.0f]
                          forState:UIControlStateNormal];
        
        [button addTarget:self action:@selector(showCamera) forControlEvents:UIControlEventTouchDown];
        [cell.contentView addSubview:button];
        notesX += notesHeight + 10;
    }
    notesRect = CGRectMake(notesX, 0, mainScrn.size.width-30- notesX, notesHeight);
    notes = [[ChatInputTextView alloc] initWithFrame:notesRect];
    notes.scrollEnabled = YES;
    
    [notes setFont:[UIFont fontWithName:@"ArialMT" size:16]];
    NSLog(@"Setting initial notes text %@", initialText);
    [notes setText:initialText];
    notes.bShowKeyBoard = bShowKeyBoard;
    [[notes layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[notes layer] setBorderWidth:2.3];
    [[notes layer] setCornerRadius:15];
    notes.delegate = self;
    
    NSLog (@"Notes initialized screen bounds height=%f width=%lf", mainScrn.size.height, mainScrn.size.width);
    [cell.contentView addSubview:notes];
    CGRect buttonRect;
    buttonRect = CGRectMake(mainScrn.size.width-25, 0, 20, 20);
    UIButton *button = [[UIButton alloc] initWithFrame:buttonRect];
    [button setBackgroundImage:[[UIImage imageNamed:@"ic_share_48pt.png"]
                                stretchableImageWithLeftCapWidth:0.0f
                                topCapHeight:0.0f]
                      forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor greenColor]];
    [button addTarget:self action:@selector(sendMsg) forControlEvents:UIControlEventTouchDown];
    [cell.contentView addSubview:button];
    if (bShowKeyBoard)
    {
        [notes becomeFirstResponder];
        NSLog (@"Keyboard becomes first responder");
    }
    
    ChatsSharingDelegate *pShrDelegate = [ChatsSharingDelegate sharedInstance];
    [pShrDelegate   setBInRedrawViews:false];
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
