
#import "SALocationManager.h"

@interface SALocationManager()
  - (BOOL)isValidLocation:(CLLocation *)newLocation withOldLocation:(CLLocation *)oldLocation;
@end

@implementation SALocationManager

@synthesize currentLocation;
@synthesize locationManagerStartDate;
@synthesize locationTimer;

static SALocationManager *sharedManager;

+ (SALocationManager *)sharedInstance {
  
  static dispatch_once_t pred;
  
  dispatch_once(&pred, ^{
    sharedManager = [[SALocationManager alloc] init];
  });

  return sharedManager;
}

- (id)init {
  
  self = [super init];
  
  if (self) {
    
    currentLocation = [[CLLocation alloc] init];
    locationManager = [[CLLocationManager alloc] init];

    locationManager.delegate        = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    locationManager.distanceFilter  = 100;
    
    [self start];
    
    locationManagerStartDate = [NSDate date];
  }
  
  return self;
}

#pragma mark - Public Methods

- (void)start {

  [locationManager startUpdatingLocation];
  
  self.locationTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 
                                                        target:self 
                                                      selector:@selector(stop) 
                                                      userInfo:nil 
                                                       repeats:NO];
}

- (void)stop {

  [locationManager stopUpdatingLocation];
  
  [self.locationTimer invalidate];
}

#pragma mark - Private Methods

/**
 * Reference: https://gist.github.com/1653505
 */

- (BOOL)isValidLocation:(CLLocation *)newLocation withOldLocation:(CLLocation *)oldLocation {

  // Filter out nil locations
  if (!newLocation) {
    return NO;
  }
  
  // Filter out points by invalid accuracy
  if (newLocation.horizontalAccuracy < 0) {
    return NO;
  }
  
  // Filter out points that are out of order
  NSTimeInterval secondsSinceLastPoint = [newLocation.timestamp timeIntervalSinceDate:oldLocation.timestamp];
  
  if (secondsSinceLastPoint < 0) {
    return NO;
  }
  
  // Filter out points created before the manager was initialized
  NSTimeInterval secondsSinceManagerStarted = [newLocation.timestamp timeIntervalSinceDate:locationManagerStartDate];
  
  if (secondsSinceManagerStarted < 0) {
    return NO;
  }
  
  // The newLocation is good to use
  return YES;
}

#pragma mark - Delegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
  
  NSInteger locationAge = abs([newLocation.timestamp timeIntervalSinceDate:[NSDate date]]);

  /**
   * if the time interval returned from core location is more than two minutes we ignore it because it might be from an old session
   */

  if (locationAge > 120 || ![self isValidLocation:newLocation withOldLocation:oldLocation]) {     
    return;
  }
  
  self.currentLocation = newLocation;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {

  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                  message:[error description] 
                                                 delegate:nil 
                                        cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                        otherButtonTitles:nil];

  [alert show];
}

@end
