//
//  ChatViewController1.m
//  common
//
//  Created by Ninan Thomas on 3/24/18.
//  Copyright © 2018 Sinacama. All rights reserved.
//

#import "ChatViewController1.h"
#import "ChatsSharingDelegate.h"
#import "Chats.h"
#import "AlbumContentsTableViewCell.h"


@interface ChatViewController1 ()

@end

@implementation ChatViewController1

@synthesize to;
@synthesize tmpCell;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        lastPicIndx = -1;
        photoIndexToChatItem = [[NSMutableDictionary alloc] init];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.tableView setSeparatorColor:[UIColor clearColor]];
        nRows = 0;
        ChatsSharingDelegate *pShrDelegate = [ChatsSharingDelegate sharedInstance];
        //100 limit will be enough for now, biggest phone iPhoneX
        chatItems = [pShrDelegate.dbIntf getChatItems:500 with:to];
        CGRect mainScrn= [[UIScreen mainScreen] bounds];
        int maxRows = 75;
        int maxCharsPerRow = 35;
        if (mainScrn.size.height == 667)
        {
            maxRows = 75;
            maxCharsPerRow = 35;
            fromLeftInset = 63;
            fromRightInset = 5;
            toLeftInset = 5;
            toRightInset = 63;
            preferredMaxWidth = 307;
        }
        else if (mainScrn.size.height == 812)
        {
            maxRows = 100;
              maxCharsPerRow = 35;
            fromLeftInset = 63;
            fromRightInset = 5;
            toLeftInset = 5;
            toRightInset = 63;
            preferredMaxWidth = 307;
        }
        else if (mainScrn.size.height == 736)
        {
            maxRows = 85;
            maxCharsPerRow = 38;
            fromLeftInset = 63;
            fromRightInset = 5;
            toLeftInset = 5;
            toRightInset = 63;
            preferredMaxWidth = 346;
        }
        else if (mainScrn.size.height == 568)
        {
            maxRows = 60;
            maxCharsPerRow = 30;
            fromLeftInset = 53;
            fromRightInset = 5;
            toLeftInset = 5;
            toRightInset = 53;
            preferredMaxWidth = 262;
        }
        else
        {
            maxRows = 75;
            maxCharsPerRow = 35;
            fromLeftInset = 63;
            fromRightInset = 5;
            toLeftInset = 5;
            toRightInset = 63;
            preferredMaxWidth = 307;
        }
        
        
        
        int picCnt =0;
        int nImaginaryRows = 0;
        NSUInteger arryIndex = 0;
        NSMutableArray *rowIndexesTmp = [[NSMutableArray alloc] init];
         NSMutableArray *rowHeightsTmp = [[NSMutableArray alloc] init];
        for (Chats *pChat in chatItems)
        {
            
            switch (pChat.type)
            {
                case eMsgTypeText:
                {
                    if (![pChat.text length])
                    {
                        break;
                    }
                     nImaginaryRows += ceil((float)[pChat.text length]/maxCharsPerRow);
                    NSUInteger numberOfLines, index, stringLength = [pChat.text length];
                    
                    for (index = 0, numberOfLines = 0; index < stringLength; numberOfLines++)
                        index = NSMaxRange([pChat.text lineRangeForRange:NSMakeRange(index, 0)]);
                    nImaginaryRows += numberOfLines;
                    [rowIndexesTmp addObject:[NSNumber numberWithUnsignedInteger:arryIndex]];
                    [rowHeightsTmp addObject:[NSNumber numberWithFloat:numberOfLines*TEXTCELL_HEIGHT_PER_ROW]]; 
                     nRows += 1;
                    picCnt =0;
                }
                break;
                    
                case eMsgTypeVideo:
                case eMsgTypePicture:
                {
                    
                    if (!picCnt)
                    {
                        nRows += 1;
                        nImaginaryRows += 3;
                        [rowIndexesTmp addObject:[NSNumber numberWithUnsignedInteger:arryIndex]];
                        [rowHeightsTmp addObject:[NSNumber numberWithFloat:PHOTOCELL_HEIGHT]];
                        NSLog(@"Adding picture at arryIndex=%lu", (unsigned long)arryIndex);
                    }
                    ++picCnt;
                    if (picCnt >= 4)
                    {
                        picCnt =0;
                    }
                }
                    break;
                    
                default:
                {
                    picCnt = 0;
                }
                break;
            }
            if (nImaginaryRows > maxRows)
            {
                break;
            }
            ++arryIndex;
        }
        NSLog(@"Array index END=%lu", (unsigned long)arryIndex);
        rowHeights = [[rowHeightsTmp reverseObjectEnumerator] allObjects];
        rowIndexes = [[rowIndexesTmp reverseObjectEnumerator] allObjects];
        NSLog(@"Initialized rowIndexes array size=%ld", (unsigned long)[rowIndexes count]);
        //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    
    return self;
}

-(void) scrollToBottom
{
    if (nRows < 1)
    {
        return;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:nRows-1];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
   
    NSLog(@"ChatViewController1 viewWillAppear");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"ChatViewController1 viewDidLoad");
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
     [self.tableView setSeparatorColor:[UIColor clearColor]];
   
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) deletedPhotoAtIndx:(NSUInteger)nIndx
{
    [ChatsSharingDelegate  sharedInstance].bRedrawViewsOnPhotoDelete = true;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"Number of ChatViewController1 rows=%d", nRows);
    return nRows;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 1;
}

- (void)albumContentsTableViewCell:(AlbumContentsTableViewCell *)cell selectedPhotoAtIndex:(NSUInteger)index
{
    
    
    NSUInteger photoIndx = cell.rowNumber*4 + index;
    
    NSString *pImgsDir = nil;
    
    NSNumber *chatIndx = [photoIndexToChatItem objectForKey:[NSNumber numberWithUnsignedInteger:photoIndx]];
    NSInteger i=[chatIndx integerValue];
    NSUInteger arryIndx = i;
    Chats *pChatItem = [chatItems objectAtIndex:i];
    long long from = pChatItem.from;
    for (; i >=0; --i)
    {
        Chats *pChatItem = [chatItems objectAtIndex:i];
        if ((pChatItem.type != eMsgTypePicture && pChatItem.type != eMsgTypeVideo) || pChatItem.from != from)
            break;
    }
    NSUInteger startIndx = ++i;
    NSMutableArray *thumbnailsTmp = [[NSMutableArray alloc] init];
    for (NSUInteger j=startIndx; j < [chatItems count]; ++j)
    {
        Chats *pChatItem = [chatItems objectAtIndex:j];
        if ((pChatItem.type != eMsgTypePicture && pChatItem.type != eMsgTypeVideo) || pChatItem.from != from)
            break;
        NSString *pImgFlName = pChatItem.text;
        [thumbnailsTmp addObject:[pImgFlName stringByDeletingPathExtension]];
        if (pImgsDir == nil)
        {
            NSString *pHdir = NSHomeDirectory();
            NSString *pImgsDirSfx = @"/Documents/images/";
            if (pChatItem.from != [ChatsSharingDelegate  sharedInstance].pShrMgr.share_id)
            {
                pImgsDirSfx = @"/Documents/";
                pImgsDirSfx = [pImgsDirSfx stringByAppendingString:[[NSNumber numberWithLongLong:pChatItem.from] stringValue]];
                pImgsDirSfx = [pImgsDirSfx stringByAppendingString:@"/images/"];
                
            }
            pImgsDir = [pHdir stringByAppendingString:pImgsDirSfx];
        }
    }
    if (pImgsDir == nil)
    {
        NSLog(@"Invalid picture selected at index %lu", (unsigned long)index);
        return;
    }
    
     NSArray *thumbnails = [[thumbnailsTmp reverseObjectEnumerator] allObjects];
    
    NSUInteger revIndx =arryIndx-startIndx;
    NSUInteger indxCnt = [thumbnails count] - 1;
    NSUInteger currIndx = indxCnt - revIndx;
    NSLog(@"Selected photo at index=%lu currIndx=%lu indxCnt=%lu revIndx=%lu arryIndx=%lu startIndx=%lu photoIndx=%lu", (unsigned long)index, (unsigned long)currIndx, (unsigned long)indxCnt,(unsigned long)revIndx,(unsigned long)arryIndx,(unsigned long)startIndx, (unsigned long)photoIndx);
    PhotoDisplayViewController *photoViewController = [PhotoDisplayViewController alloc];
    photoViewController = [photoViewController initWithNibName:nil bundle:nil];
    [photoViewController setCurrIndx:currIndx];
    [photoViewController setDelphoto:true];
    [photoViewController setDelegate:self];
    [photoViewController setThumbnails:thumbnails];
    [photoViewController setSubject:@"Pictures"];
    [photoViewController setNavViewController:[self navigationController]];
    [photoViewController setPAlName:[[NSURL fileURLWithPath:pImgsDir] absoluteString]];
    [photoViewController setPFlMgr:[ChatsSharingDelegate  sharedInstance].pFlMgr];
    [[ChatsSharingDelegate sharedInstance].pChatsNavCntrl pushViewController:photoViewController animated:YES];
    
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *arryIndexNum = [rowIndexes objectAtIndex:indexPath.section];
    NSUInteger arryIndx = [arryIndexNum unsignedIntegerValue];
    Chats *pChatItem = [chatItems objectAtIndex:arryIndx];
    switch (pChatItem.type)
    {
        case eMsgTypeText:
        {
          
            if (pChatItem.to == [ChatsSharingDelegate  sharedInstance].pShrMgr.share_id)
            {
                [[cell.textLabel layer] setBackgroundColor:[[UIColor colorWithRed: 180.0/255.0 green: 238.0/255.0 blue:180.0/255.0 alpha: 1.0] CGColor]];
            }
            else
            {
               
                cell.textLabel.layer.backgroundColor  =  [[UIColor colorWithRed: 180.0/255.0 green: 238.0/255.0 blue:238.0/255.0 alpha: 1.0] CGColor];
            }
           
        }
        break;
            
            
      
        default:
            break;
    }
    [[cell.textLabel layer] setBorderColor:[[UIColor clearColor] CGColor]];
    [[cell.textLabel layer] setBorderWidth:2.3];
    [[cell.textLabel layer] setCornerRadius:15];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return 20.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *v = [UIView new];
    [v setBackgroundColor:[UIColor clearColor]];
    return v;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   CGFloat height = [[rowHeights objectAtIndex:indexPath.section] floatValue];
    NSLog(@"height=%lf for row=%ld is ",  height, (long)indexPath.section);
    return height;
}
 

-(AlbumContentsTableViewCell  *) cellForThumbNails:(NSUInteger) row
{
    static NSString *CellIdentifier = @"ChatVwImgsCell";
    
    AlbumContentsTableViewCell *cell = (AlbumContentsTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle bundleForClass:[AlbumContentsTableViewCell class]] loadNibNamed:@"AlbumContentsTableViewCell" owner:self options:nil];
        cell = tmpCell;
        tmpCell = nil;
    }
    cell.selectionDelegate = self;
    NSNumber *arryIndexNum = [rowIndexes objectAtIndex:row];
    NSUInteger arryIndx = [arryIndexNum unsignedIntegerValue];
    NSLog(@"Picture arryIndx = %lu row = %lu", (unsigned long) arryIndx, (unsigned long)row);
    cell.rowNumber = row;
    int noPics = 0;
    NSUInteger startIndx = arryIndx;
    for (NSUInteger i=0; i < 4; ++i)
    {
        if (arryIndx + i >= [chatItems count] || arryIndx + i >= lastPicIndx)
        {
            break;
        }
        Chats *pChatItem = [chatItems objectAtIndex:arryIndx+i];
        if (pChatItem.type == eMsgTypeVideo || pChatItem.type == eMsgTypePicture)
        {
            ++noPics;
            startIndx = arryIndx + i;
        }
        else
        {
            break;
        }
    }
    
    NSInteger indx = startIndx;
    for (NSUInteger i=0; i < 4; ++i)
    {
        if (indx >= [chatItems count] || indx < 0 )
        {
            break;
        }
        Chats *pChatItem = [chatItems objectAtIndex:indx];
        if (pChatItem.type == eMsgTypeVideo || pChatItem.type == eMsgTypePicture)
        {
            lastPicIndx = indx;
            NSString *pHdir = NSHomeDirectory();
            NSString *pThumbNails = @"/Documents/images/thumbnails/";
            NSNumber *chatIndxNum = [NSNumber numberWithInteger:indx];
            NSNumber  *photoIndxNum = [NSNumber numberWithUnsignedInteger:cell.rowNumber*4 +i];
            [photoIndexToChatItem setObject:chatIndxNum forKey:photoIndxNum];
            
            
            if (pChatItem.from != [ChatsSharingDelegate  sharedInstance].pShrMgr.share_id)
            {
                pThumbNails = @"/Documents/";
                pThumbNails = [pThumbNails stringByAppendingString:[[NSNumber numberWithLongLong:pChatItem.from] stringValue]];
                pThumbNails = [pThumbNails stringByAppendingString:@"/images/thumbnails"];
            }
            NSString *pThumbNailsDir = [pHdir stringByAppendingString:pThumbNails];
            NSString *pThumbNailFileName = [pChatItem.text stringByDeletingPathExtension];
            pThumbNailFileName = [pThumbNailFileName stringByAppendingPathExtension:@"jpg"];
            NSString *pThumbNailsFile = [pThumbNailsDir stringByAppendingString:pThumbNailFileName];
            NSURL *pThumbNailUrl = [NSURL fileURLWithPath:pThumbNailsFile];
            UIImage *thumbnail = [UIImage imageWithData:[NSData dataWithContentsOfURL:pThumbNailUrl]];
             NSLog(@"Displaying thumbnail url=%@ chatIndxNum=%@ photoIndxNum=%@",  pThumbNailUrl, chatIndxNum, photoIndxNum);
            if (![[[ChatsSharingDelegate sharedInstance] pFlMgr] fileExistsAtPath:[pThumbNailUrl path]])
            {
                NSLog(@"File does not exist at thumbnail path url=%@", pThumbNailUrl);
            }
            
            switch ( i) {
                case 0:
                    [cell photo1].image = thumbnail;
                break;
                case 1:
                    [cell photo2].image = thumbnail;
                break;
                case 2:
                    [cell photo3].image = thumbnail;
                break;
                case 3:
                    [cell photo4].image = thumbnail;
                break;
                default:
                    break;
            }
        }
        else
        {
            break;
        }
        --indx;
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    // Configure the cell...
    static NSString *CellIdentifier = @"ChatVwCell";
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
        [cell setBackgroundColor:[UIColor clearColor]];
    }
    
    CGRect mainScrn= [[UIScreen mainScreen] bounds];
    CGRect  viewRect;
    viewRect = CGRectMake(0, 0, mainScrn.size.width, 50);
    NSNumber *arryIndexNum = [rowIndexes objectAtIndex:indexPath.section];
    NSUInteger arryIndx = [arryIndexNum unsignedIntegerValue];
    Chats *pChatItem = [chatItems objectAtIndex:arryIndx];
    switch (pChatItem.type)
    {
        case eMsgTypeText:
        {
           // UILabel *pLabel = [[UILabel alloc] init];
            cell.textLabel.text = pChatItem.text;
           // NSLog(@"Adding label text=%@", pLabel.text);
            if (pChatItem.to == [ChatsSharingDelegate  sharedInstance].pShrMgr.share_id)
            {
                [cell setLayoutMargins:UIEdgeInsetsMake(20, toLeftInset, 20, toRightInset)];
               
            }
            else
            {
                [cell setLayoutMargins:UIEdgeInsetsMake(20, fromLeftInset, 20, fromRightInset)];
                
            }
            [cell.textLabel setPreferredMaxLayoutWidth:preferredMaxWidth];
            cell.textLabel.numberOfLines = 0;
          
           // [cell.contentView addSubview:pLabel];
        }
        break;
       
        case eMsgTypePicture:
        case eMsgTypeVideo:
        {
            return [self cellForThumbNails:indexPath.section];
        }
            break;
           
        default:
            break;
    }
   // UITextField* notes = [[UITextField alloc] initWithFrame:viewRect];
   // [cell.contentView addSubview:notes];
   
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


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    NSLog(@"Touched output chat view, hiding keyboard");
    [[ChatsSharingDelegate sharedInstance] showViewWithoutKeyBoard];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
