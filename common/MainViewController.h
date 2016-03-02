//
//  MainViewController.h
//  Shopper
//
//  Created by Ninan Thomas on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainListViewController.h"
#import <MapKit/MapKit.h>

@protocol MainViewControllerDelegate <NSObject>

-(void) initRefresh;
-(void) searchStrSet:(NSString *)text;
-(void)searchStrReset;
-(void) itemAdd;
-(void) iCloudOrEmail;

@end

@interface MainViewController : UIViewController <UISearchBarDelegate, MKMapViewDelegate>
{
     MKMapView *mapView;
}
@property (strong, nonatomic) MainListViewController *pAllItms;
@property (strong, nonatomic) UISearchBar *pSearchBar;
- (void)enableCancelButton:(UISearchBar *)aSearchBar;

@property bool emailAction;
@property bool fbAction;

@property (nonatomic, weak) id<MainViewControllerDelegate> delegate;

@end

