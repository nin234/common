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


@interface ChatViewController1 ()

@end

@implementation ChatViewController1



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.tableView setSeparatorColor:[UIColor clearColor]];
        nRows = 0;
        ChatsSharingDelegate *pShrDelegate = [ChatsSharingDelegate sharedInstance];
        //100 limit will be enough for now, biggest phone iPhoneX
        chatItems = [pShrDelegate.dbIntf getChatItems:100];
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
        rowIndexes = [[rowIndexesTmp reverseObjectEnumerator] allObjects];
        NSLog(@"Initialized rowIndexes array size=%ld", (unsigned long)[rowIndexes count]);
        //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    
    return self;
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



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"Number of ChatViewController1 rows=%d", nRows);
    return nRows;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 1;
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