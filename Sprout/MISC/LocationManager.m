//
//  LocationManager.m
//  Sprout
//
//  Created by laurentsai on 7/14/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "LocationManager.h"

@implementation LocationManager

@synthesize currentLocation;
@synthesize geoCoder;
@synthesize currentPlacemark;


static LocationManager *sharedManager;

+ (LocationManager *)sharedInstance {
  
  static dispatch_once_t pred;
  
  dispatch_once(&pred, ^{
    sharedManager = [[LocationManager alloc] init];
  });

  return sharedManager;
}

- (id)init {
  
  self = [super init];
  
  if (self) {
    
    currentLocation = [[CLLocation alloc] init];
    geoCoder=[[CLGeocoder alloc] init];
    locationManager = [[CLLocationManager alloc] init];

    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLLocationAccuracyHundredMeters;
    [locationManager requestWhenInUseAuthorization];
    [self start];
  }
  
  return self;
}

#pragma mark - Public Methods

- (void)start {

  [locationManager startUpdatingLocation];

}

- (void)stop {

  [locationManager stopUpdatingLocation];
}

- (void)getLocalPlaces:(NSString*)searchTerm completion:(void(^)(NSArray *mapItems, NSError *error))completion{
    MKLocalSearchRequest *searchRequest = [[MKLocalSearchRequest alloc] init];
    searchRequest.naturalLanguageQuery = searchTerm;

    // Set the region to an associated map view's region.
    searchRequest.region=MKCoordinateRegionMake(self.currentLocation.coordinate, MKCoordinateSpanMake(0.07, 0.07));

    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:searchRequest];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        if (response) {
            completion([response mapItems], nil);
        } else if (error) {
            // Handle the error.
            completion(nil, error);
        }
    }];
}

#pragma mark - Delegate Methods
-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    self.currentLocation=[locations lastObject];

    [self.geoCoder reverseGeocodeLocation:self.currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if(placemarks)
        {
            self.currentPlacemark=[placemarks firstObject];
            //NSLog(@"Current loc %@", self.currentPlacemark.subThoroughfare);
        }
        else
            NSLog(@"Error geting location %@", error.localizedDescription);
    }];
}
@end