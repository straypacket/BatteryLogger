//
//  ViewController.m
//  BatteryLogger
//
//  Created by Michael He on 2013/05/22.
//  Copyright (c) 2013年 MichaelHe. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController {
    IBOutlet FUIButton *startButton;
    IBOutlet UILabel *centerLabel;
    IBOutlet UISlider *slider;
    IBOutlet UITextView *logView;

    NSURLRequest *request;
    BOOL isStarted;
    NSTimer *requestTimer;
    NSMutableString *logText;
    float lastBattery;
}

@synthesize locationManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    logText = [NSMutableString string];
    // Label
    centerLabel.font = [UIFont boldFlatFontOfSize:50];

    // Slider
    [slider configureFlatSliderWithTrackColor:[UIColor silverColor]
                                progressColor:[UIColor alizarinColor]
                                   thumbColor:[UIColor pomegranateColor]];

    // Start button
    startButton.buttonColor = [UIColor turquoiseColor];
    startButton.shadowColor = [UIColor greenSeaColor];
    startButton.shadowHeight = 3.0f;
    startButton.cornerRadius = 6.0f;
    startButton.titleLabel.font = [UIFont boldFlatFontOfSize:50];
    [startButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [startButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    requestTimer = nil;
    isStarted = false;
    
    // HTTP
    // http://primebook.skillupjapan.net/m/bookstore.json
    // http://outreach.jach.hawaii.edu/pressroom/2004_wfcam/orion-zoom-large.png
    request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.youtube.com"]];
    
    lastBattery = -2;
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    
    // CoreLocation
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    //Only applies when in foreground otherwise it is very significant changes
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    CLLocationCoordinate2D currentCoordinates = newLocation.coordinate;
    NSLog(@"Entered new Location with the coordinates Latitude: %f Longitude: %f", currentCoordinates.latitude, currentCoordinates.longitude);
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Unable to start location manager. Error:%@", [error description]);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)startOrStop:(id)sender
{
    if (isStarted) {

        [self stopTimer];
        [startButton setTitle:@"Start" forState:UIControlStateNormal];
        [locationManager stopUpdatingLocation];
    } else { // START
        [self startTimer];
        [startButton setTitle:@"Stop" forState:UIControlStateNormal];
        [locationManager startUpdatingLocation];
    }
}

- (void)stopTimer
{
    if (requestTimer) {
        [requestTimer invalidate];
        requestTimer = nil;
    }

    isStarted = NO;
}

- (void)startTimer
{
    [self stopTimer];
    
    if (slider.value > 0) {
        float frequency = 60.0 / slider.value;
        requestTimer = [NSTimer scheduledTimerWithTimeInterval:frequency
                                                        target:self selector:@selector(sendRequest)
                                                      userInfo:nil repeats:YES];
    }

    [self updateFrequencyLabel];
    isStarted = YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)sendRequest
{
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
    [self updateQueueIndicator];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)sliderValueChanged:(id)sender
{
    if (isStarted) [self startTimer];
    [self updateFrequencyLabel];
}

- (void)updateQueueIndicator
{
    if (lastBattery != [[UIDevice currentDevice] batteryLevel]) {
        [logText appendFormat:@"%@, %f\n", [NSDate date], [[UIDevice currentDevice] batteryLevel]];
        [logView setText:logText];
        logView.selectedRange = NSMakeRange(0, logText.length);
        lastBattery = [[UIDevice currentDevice] batteryLevel];
    }
}

- (void)updateFrequencyLabel
{
    [centerLabel setText:[NSString stringWithFormat:@"%3.0f r/m", slider.value]];
}

@end
