//
//  ViewController.h
//  BatteryLogger
//
//  Created by Michael He on 2013/05/22.
//  Copyright (c) 2013年 MichaelHe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Reachability.h"

@interface ViewController : UIViewController <CLLocationManagerDelegate, NSURLConnectionDelegate> {
    CLLocationManager *locationManager;
    NSMutableData *_responseData;
}
@property(nonatomic, retain) CLLocationManager *locationManager;
@end
