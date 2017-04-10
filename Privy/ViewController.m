//
//  ViewController.m
//  Privy
//
//  Created by Nathan Pantaleo on 4/2/17.
//  Copyright © 2017 Nathan Pantaleo. All rights reserved.
//

#import "ViewController.h"
#import "RideShareModelsProtocol.h"
#import "UberModel.h"
#import "LyftModel.h"
#import "UserModel.h"
#import "RideServiceCollectionViewCell.h"
#import <CoreLocation/CoreLocation.h>

static NSString * const kRideServiceCollectionViewCellReuseId = @"rideServiceCollectionViewCellReuseId";

@interface ViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) UserModel *user;
@property (strong, nonatomic) NSMutableArray<RideShareModelsProtocol> *models;

@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.delegate = self;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
}

- (void)refreshData {
    [self updateUserDestinationAddress];
//    [self makeRideShareDataRequestsForUser];
}

- (void)updateUserDestinationAddress {
//    self.user.destinationLatitude = @"37.7816977";
//    self.user.destinationLongitude = @"-122.410014";
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:@"28 6th St, San Francisco, CA 94103" completionHandler:^(NSArray* placemarks, NSError* error) {
        for (CLPlacemark* placemark in placemarks) {
            self.user.destinationLatitude = [NSString stringWithFormat:@"%.4f", placemark.location.coordinate.latitude];
            self.user.destinationLongitude = [NSString stringWithFormat:@"%.4f", placemark.location.coordinate.longitude];
        }
    }];
}

- (void)makeRideShareDataRequestsForUser {
    
    __weak typeof(self) weakSelf = self;
    
    // Create Lyft Request
    NSString *lyftDataUrl = [LyftModel getRequestStringForUser:self.user];
    NSURL *lyftUrl = [NSURL URLWithString:lyftDataUrl];
    
    NSMutableURLRequest *lyftRequest = [[NSMutableURLRequest alloc] initWithURL:lyftUrl];
    [lyftRequest setValue:[LyftModel authorizationToken] forHTTPHeaderField:@"Authorization"];
    [lyftRequest setHTTPMethod:@"GET"];
    
    NSURLSessionDataTask *lyftTask = [[NSURLSession sharedSession]
                                      dataTaskWithRequest:lyftRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                          
                                          if (error) {
                                              [weakSelf handleError:error];
                                          } else {
                                              NSDictionary * json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                              LyftModel *lyftModel = [[LyftModel alloc] initWithResponse:json];
                                              [weakSelf.models addObject:lyftModel];
                                          }
                                          
                                          if ([weakSelf.models count] > 0) {
                                              [self.collectionView reloadData];
                                          }
                                      }];
    
    // Create Uber Request
    NSString *uberDataUrl = [UberModel getRequestStringForUser:self.user];
    NSURL *uberUrl = [NSURL URLWithString:uberDataUrl];
    
    NSMutableURLRequest *uberRequest = [[NSMutableURLRequest alloc] initWithURL:uberUrl];
    [uberRequest setValue:[UberModel authorizationToken] forHTTPHeaderField:@"Authorization"];
    [uberRequest setHTTPMethod:@"GET"];

    NSURLSessionDataTask *uberTask = [[NSURLSession sharedSession]
                                      dataTaskWithRequest:uberRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                          
                                              if (error) {
                                                  [weakSelf handleError:error];
                                              } else {
                                                  NSDictionary * json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                                  UberModel *uberModel = [[UberModel alloc] initWithResponse:json];
                                                  [weakSelf.models addObject:uberModel];
                                              }
                                          
                                              [lyftTask resume];
                                          }];
    [uberTask resume];
}

- (void)handleError:(NSError *)error {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Unable to complete action." preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.models count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RideServiceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kRideServiceCollectionViewCellReuseId forIndexPath:indexPath];
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    
//}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations __OSX_AVAILABLE_STARTING(__MAC_10_9,__IPHONE_6_0) {
    CLLocation *currentLocation = [locations firstObject];
    self.user.currentLatitude = [[NSNumber numberWithDouble:currentLocation.coordinate.latitude] stringValue];
    self.user.currentLongitude = [[NSNumber numberWithDouble:currentLocation.coordinate.longitude] stringValue];
    [self refreshData];
}

#pragma mark - Lazy Loaded Properties

- (NSMutableArray<RideShareModelsProtocol> *)models {
    if (!_models) {
        _models = [[NSMutableArray<RideShareModelsProtocol> alloc] init];
    }
    return _models;
}

- (UserModel *)user {
    if (!_user) {
        _user = [[UserModel alloc] init];
    }
    return _user;
}


@end
