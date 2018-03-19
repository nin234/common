//
//  ChatViewController.m
//  smartmsg
//
//  Created by Ninan Thomas on 2/28/18.
//  Copyright © 2018 Nshare. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController ()

@end

@implementation ChatViewController

@synthesize pShrDelegate;
@synthesize to;
@synthesize notes;

static NSString * const reuseIdentifier = @"ChatVwCell";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    return self;
}

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self)
    {
        NSLog(@"Initializing ChatViewController");
        
        
        CGRect fullScreenRect= [[UIScreen mainScreen] bounds];
        self.collectionView = [[UICollectionView alloc] initWithFrame:fullScreenRect collectionViewLayout:layout];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    }
    return self;
}

#pragma mark helper functions
-(void) showCamera
{
    
}

-(void) sendMsg
{
    NSLog(@"Sending message");
    
    [pShrDelegate sendMsg:to Msg:notes.text];
}

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
   
    
    
    
    // Do any additional setup after loading the view.
}

-(void) loadView
{
    [super loadView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize itemSize;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    if (!indexPath.section)
    {
        itemSize.width = screenRect.size.width;
        itemSize.height = screenRect.size.height*0.2;
        NSLog(@"itemsize indexPath.section=%ld indexPath.item=%ld width=%f height=%f", indexPath.section, indexPath.item , itemSize.width, itemSize.height);
        return itemSize;
    }
    if (indexPath.item == 1)
    {
        itemSize.width = screenRect.size.width*0.8;
        itemSize.height = screenRect.size.height*0.1;
    }
    else
    {
        itemSize.width = screenRect.size.width*0.1;
        itemSize.height = screenRect.size.height*0.1;
    }
    NSLog(@"itemsize indexPath.section=%d indexPath.item=%d width=%f height=%f", indexPath.section, indexPath.item , itemSize.width, itemSize.height);
    
    return itemSize;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 2;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (!section)
    {
        return 1;
    }

    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    CGRect screenRect = [cell bounds];
    cell.backgroundColor = [UIColor whiteColor];
    if (!indexPath.section)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:screenRect];
        [label setText:@"Hello "];
        NSLog(@"Adding subview label Hello x=%f y=%f width=%f height=%f", screenRect.origin.x, screenRect.origin.y, screenRect.size.width, screenRect.size.height);
        [cell.contentView addSubview:label];
    }
    else if (indexPath.section == 1)
    {
        if (!indexPath.item)
        {
            UIToolbar *bar = [[UIToolbar alloc] initWithFrame:screenRect];
            UIBarButtonItem *pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(showCamera) ];
            NSArray *baritems = [NSArray arrayWithObjects:pBarItem, nil];
            [bar setItems:baritems];
            NSLog(@"Adding subview camera");
            [cell.contentView addSubview:bar];
        }
        else if (indexPath.item ==1)
        {
            notes = [[UITextView alloc] initWithFrame:screenRect];
            NSLog(@"Adding subview Textview for message entry");
            [cell.contentView addSubview:notes];
        }
        else
        {
        
            UIButton *button = [[UIButton alloc] initWithFrame:screenRect];
        
            [button setTitle:@"Send" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(sendMsg) forControlEvents:UIControlEventTouchDown];
            NSLog(@"Adding subview button to send");
            [cell.contentView addSubview:button];
        }
    }
    
    // Configure the cell
    NSLog(@"Returning cell section=%ld item=%ld", (long)indexPath.section, (long)indexPath.item);
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
