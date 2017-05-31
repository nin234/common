//
//  SeasonPickerViewController.m
//  common
//
//  Created by Ninan Thomas on 5/29/17.
//  Copyright © 2017 Sinacama. All rights reserved.
//

#import "SeasonPickerViewController.h"
#import "AppCmnUtil.h"

@interface SeasonPickerViewController ()

@end

@implementation SeasonPickerViewController

@synthesize mitem;
@synthesize seasonPicker;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem *pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pickSeasons) ];
    self.navigationItem.rightBarButtonItem = pBarItem;
    
    NSString *title = @"Pick Season";
    self.navigationItem.title = [NSString stringWithString:title];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _pickerData[component][row];
}

-(void) pickSeasons
{
    NSLog(@"Picked seasons %ld %ld", (long)startMonth, (long)endMonth);
    if (mitem != nil)
    {
        mitem.startMonth = (int)startMonth;
        mitem.endMonth = (int)endMonth;
    }
     AppCmnUtil *pAppCmnUtil = [AppCmnUtil sharedInstance];
    [pAppCmnUtil.navViewController popViewControllerAnimated:YES];
    
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 12;
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"SeasonPickerViewController will disappear");
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        CGRect mainScrn = [UIScreen mainScreen].applicationFrame;
        CGRect  viewRect;
        viewRect = CGRectMake(mainScrn.origin.x, mainScrn.origin.y, mainScrn.size.width, mainScrn.size.height-50);
       seasonPicker = [[UIPickerView alloc] initWithFrame:viewRect];
       
        [self.view addSubview:seasonPicker];
        
        _pickerData = @[ @[@"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun", @"Jul", @"Aug", @"Sep", @"Oct", @"Nov", @"Dec"],
                         @[@"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun", @"Jul", @"Aug", @"Sep", @"Oct", @"Nov",@"Dec"]];
        seasonPicker.delegate = self;
        seasonPicker.dataSource = self;
        if (mitem != nil)
        {
            [seasonPicker selectRow:mitem.startMonth-1 inComponent:0 animated:NO];
            [seasonPicker selectRow:mitem.endMonth-1 inComponent:1 animated:NO];
        }
        

    }

    return self;
}

// Catpure the picker view selection
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // This method is triggered whenever the user makes a change to the picker selection.
    // The parameter named row and component represents what was selected.
    if (!component)
        startMonth = (int)row+1;
    else
        endMonth = (int)row+1;
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
