//
//  AddressAnnotation.h
//  Shopper
//
//  Created by Ninan Thomas on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface AddressAnnotation : NSObject<MKAnnotation> {
	CLLocationCoordinate2D coordinate;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D) c;
@end
