//
//  ChatViewController2.h
//  common
//
//  Created by Ninan Thomas on 3/26/18.
//  Copyright © 2018 Sinacama. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatViewController2 : UITableViewController<UITextViewDelegate>

@property (nonatomic, retain) UITextView *notes;
@property (nonatomic) bool bShowKeyBoard;

@end
