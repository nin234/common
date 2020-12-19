//
//  ProgressViewController.h
//  common
//
//  Created by Ninan Thomas on 12/12/20.
//  Copyright © 2020 nshare. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ProgressViewController : UIViewController
{
     
     UILabel *progressText;
    UIProgressView *progressView;
}

@property (nonatomic) bool upload;
@property (nonatomic) long nTotFileSize;
@property (nonatomic) long transferredTilNow;
@property (nonatomic, retain) NSProgress *progress;


@end

NS_ASSUME_NONNULL_END
