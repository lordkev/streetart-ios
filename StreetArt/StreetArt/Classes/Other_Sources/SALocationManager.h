

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface SALocationManager : NSObject <CLLocationManagerDelegate> {
  CLLocationManager *locationManager;
  CLLocation *currentLocation;
  NSDate *locationManagerStartDate;
  NSTimer *locationTimer;
}

@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) NSDate *locationManagerStartDate;
@property (nonatomic, strong) NSTimer *locationTimer;

+ (SALocationManager *)sharedInstance;
- (void)start;
- (void)stop;

@end
