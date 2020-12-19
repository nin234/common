//
//  ProgressViewController.m
//  common
//
//  Created by Ninan Thomas on 12/12/20.
//  Copyright © 2020 nshare. All rights reserved.
//

#import "ProgressViewController.h"

@interface ProgressViewController ()

@end

@implementation ProgressViewController

@synthesize upload;
@synthesize nTotFileSize;
@synthesize transferredTilNow;
@synthesize progress;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
               
        progress = nil;
    }
    return self;
}

-(void) setTransferredTilNow:(long)transferredTilNow
{
    int percentComplete = (transferredTilNow/(double)nTotFileSize)*100.0;
    progressView.observedProgress.completedUnitCount = transferredTilNow;
    NSLog(@"transferredTilNow=%ld total=%ld", transferredTilNow, nTotFileSize);
    if (upload)
    {
        NSString *labelText = [NSString stringWithFormat:@"Uploading items. Pleast wait\n Don't minimize App until complete\n %d %% Done", percentComplete];
        [progressText setText:labelText];
    }
    else
    {
        NSString *labelText = [NSString stringWithFormat:@"Downloading items. Pleast wait\n Don't minimize App until complete\n %d %% Done", percentComplete];
        [progressText setText:labelText];
    }
}

#pragma mark - View lifecycle

-(void) loadView
{
    //  printf("LOADING main table view %s %d\n" , __FILE__, __LINE__);
    [super loadView];
    CGRect mainScrn = [UIScreen mainScreen].bounds;
   
    CGRect labelRect;
    CGRect progressRect;
    labelRect = CGRectMake(0, mainScrn.origin.y + (mainScrn.size.height)/4.0, mainScrn.size.width, mainScrn.size.height/8.0);
    progressText = [[UILabel alloc] initWithFrame:labelRect];
    progressText.numberOfLines =0;
    progressText.lineBreakMode = NSLineBreakByWordWrapping;
    progressText.textAlignment = NSTextAlignmentCenter;
    if (upload)
    {
        NSString *labelText = [NSString stringWithFormat:@"Uploading items. Pleast wait\nDon't minimize App until complete\n0 %% Done"];
        [progressText setText:labelText];
    }
    else
    {
        NSString *labelText = [NSString stringWithFormat:@"Downloading items. Pleast wait\nDon't minimize App until complete\n0 %% Done"];
        [progressText setText:labelText];
    }
    progressRect = CGRectMake(0, mainScrn.origin.y + mainScrn.size.height/2.0, mainScrn.size.width, mainScrn.size.height/8.0);
    progressView = [[UIProgressView alloc] initWithFrame:progressRect];
    progressView.progressViewStyle = UIProgressViewStyleBar;
    progress = [NSProgress progressWithTotalUnitCount:nTotFileSize];
    progressView.observedProgress = progress;
    progressView.observedProgress.completedUnitCount =0;
    progressView.trackTintColor = [UIColor lightGrayColor];
    progressView.tintColor = [UIColor blueColor];
    progressView.transform = CGAffineTransformScale(progressView.transform, 1, 20);
    [self.view addSubview:progressText];
    
    [self.view addSubview:progressView];
   
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    progressText.backgroundColor = [UIColor orangeColor];
    
    progressView.backgroundColor = [UIColor whiteColor];
    
    self.view.layer.borderWidth = 10;
    self.view.layer.borderColor = UIColor.grayColor.CGColor;
    // Do any additional setup after loading the view.
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
