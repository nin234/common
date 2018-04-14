//
//  ChatsViewController.m
//  smartmsg
//
//  Created by Ninan Thomas on 2/19/18.
//  Copyright © 2018 Nshare. All rights reserved.
//

#import "ChatsViewController.h"
#import "ChatsSharingDelegate.h"
#import "sharing/SHKeychainItemWrapper.h"
#import "ChatsHeader.h"

@interface ChatsViewController ()

@end

@implementation ChatsViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        ChatsSharingDelegate *pShrDelegate = [ChatsSharingDelegate sharedInstance];
        //100 limit will be enough for now, biggest phone iPhoneX
        chatHeaders = [pShrDelegate.dbIntf getChatHeaders:100];
        [self populateContacts];
    }
    return self;
}
-(void) populateContacts
{
    
   SHKeychainItemWrapper * kchain = [[SHKeychainItemWrapper alloc] initWithIdentifier:@"SharingData" accessGroup:@"3JEQ693MKL.com.rekhaninan.frndlst"];
    frndDic = [[NSMutableDictionary alloc] init];
   NSString * friendList = [kchain objectForKey:(__bridge id)kSecAttrComment];
    if (friendList != nil  && [friendList length] > 0)
    {
        NSLog(@"Friendlist %@", friendList);
        NSArray *friends = [friendList componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@";"]];
        NSUInteger cnt = [friends count];
        if(cnt >1)
        {
            for (NSUInteger i=1; i < cnt-1; ++i)
            {
                NSString *frndStr = [friends objectAtIndex:i];
                if (frndStr != nil && [frndStr length] > 0)
                {
                    FriendDetails *frnd = [[FriendDetails alloc] initWithString:frndStr];
                    [frndDic setObject:frnd forKey:frnd.name];
                }
                
            }
        }
        
    }
    
    return;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"ChatsViewController viewWillAppear %s %d", __FILE__, __LINE__);
    NSString *title = @"Messages";
    self.navigationItem.title = [NSString stringWithString:title];
        UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeNewMsg) ];
        self.navigationItem.rightBarButtonItem = pBarItem1;
    ChatsSharingDelegate *pShrDelegate = [ChatsSharingDelegate sharedInstance];
    [pShrDelegate showTabBar];
    
}

#pragma mark - Call back functions

-(void) composeNewMsg
{
    NSLog(@"Composing new message");
    
    [delegate showContactsSelectViewForNewChats];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [chatHeaders count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 95.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    
    // Configure the cell...
 static NSString *CellIdentifier = @"ChatsVwCell";
 
  
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
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
     CGRect mainScrn= [[UIScreen mainScreen] bounds];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, mainScrn.size.width-15, 30)];
    ChatsHeader *pItem = [chatHeaders objectAtIndex:indexPath.row];
    long long frnd_shr_id =0;
    ChatsSharingDelegate *pShrDelegate = [ChatsSharingDelegate sharedInstance];
    if (pShrDelegate.pShrMgr.share_id == pItem.from)
    {
        frnd_shr_id = pItem.to;
    }
    else
    {
        frnd_shr_id = pItem.from;
    }
    NSString *frndName = [[NSNumber numberWithLongLong:frnd_shr_id] stringValue];
    FriendDetails *frndDetails = [frndDic objectForKey:frndName];
    if (frndDetails != nil && frndDetails.nickName != nil)
    {
        [nameLabel setText:frndDetails.nickName];
    }
    else
    {
        [nameLabel setText:frndName];
    }
    [nameLabel setFont:[UIFont boldSystemFontOfSize:20]];
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 40, mainScrn.size.width-15, 55)];
    [contentLabel setText:pItem.text];
    [cell.contentView addSubview:nameLabel];
    [cell.contentView addSubview:contentLabel];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatsHeader *pItem = [chatHeaders objectAtIndex:indexPath.row];
    long long frnd_shr_id =0;
    ChatsSharingDelegate *pShrDelegate = [ChatsSharingDelegate sharedInstance];
    if (pShrDelegate.pShrMgr.share_id == pItem.from)
    {
        frnd_shr_id = pItem.to;
    }
    else
    {
        frnd_shr_id = pItem.from;
    }
    NSString *frndName = [[NSNumber numberWithLongLong:frnd_shr_id] stringValue];
    FriendDetails *frndDetails = [frndDic objectForKey:frndName];
    if (frndDetails != nil)
    {
        [pShrDelegate launchChat:frndDetails];
    }
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
