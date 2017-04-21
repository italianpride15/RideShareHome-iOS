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
#import "RideResponseModel.h"

#import <CoreLocation/CoreLocation.h>
//#import <MapKit/MapKit.h>

static NSString * const kRideServiceCollectionViewCellReuseId = @"rideServiceCollectionViewCellReuseId";
static NSString * const kSearchResultsTableViewCellReuseId = @"searchResultsTableViewCellReuseId";

static void * UserModelContext = &UserModelContext;

@interface ViewController () <UISearchBarDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, CLLocationManagerDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) UserModel *user;
@property (strong, nonatomic) NSMutableArray<RideShareModelsProtocol> *models;

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UITableView *searchResultsTableView;
@property (strong, nonatomic) NSArray<CLPlacemark *> *placemarks;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.searchBar.delegate = self;
    self.searchResultsTableView.delegate = self;
    self.searchResultsTableView.dataSource = self;
    self.searchResultsTableView.estimatedRowHeight = 80;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    
//    [self.user addObserver:self forKeyPath:NSStringFromSelector(@selector(currentLatitude)) options:0 context:UserModelContext];
    [self.user addObserver:self forKeyPath:NSStringFromSelector(@selector(currentLongitude)) options:0 context:UserModelContext];
//    [self.user addObserver:self forKeyPath:NSStringFromSelector(@selector(destinationLatitude)) options:0 context:UserModelContext];
    [self.user addObserver:self forKeyPath:NSStringFromSelector(@selector(destinationLongitude)) options:0 context:UserModelContext];
}

- (void)dealloc {
    @try {
        [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(currentLatitude))  context:UserModelContext];
        [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(currentLongitude))  context:UserModelContext];
        [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(destinationLatitude))  context:UserModelContext];
        [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(destinationLongitude))  context:UserModelContext];
    } @catch (NSException * __unused exception){}
}

- (void)makeRideShareDataRequestsForUser {
    
    [self.models removeAllObjects];
    
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
                                              LyftModel *lyftModel = [[LyftModel alloc] initWithResponse:json andUserModel:weakSelf.user];
                                              [weakSelf.models addObject:lyftModel];
                                          }
                                          
                                          if ([weakSelf.models count] > 0) {
                                              
                                              double lowestPriceOne = [[[[weakSelf.models firstObject] availableRidesFromLowestPrice] firstObject].estimatedCost doubleValue];
                                              
                                              double lowestPriceTwo = [[[[weakSelf.models lastObject] availableRidesFromLowestPrice] firstObject].estimatedCost doubleValue];
                                              
                                              if (lowestPriceTwo < lowestPriceOne) {
                                                  [weakSelf.models exchangeObjectAtIndex:0 withObjectAtIndex:1];
                                              }
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  [weakSelf.collectionView reloadData];
                                              });
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
                                                  UberModel *uberModel = [[UberModel alloc] initWithResponse:json andUserModel:weakSelf.user];
                                                  [weakSelf.models addObject:uberModel];
                                              }
                                          
                                              [lyftTask resume];
                                          }];
    [uberTask resume];
}

- (void)handleError:(NSError *)error {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Unable to complete action." preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.models count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RideServiceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kRideServiceCollectionViewCellReuseId forIndexPath:indexPath];
    [cell configureCellForRideShareModel:[self.models objectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.collectionView.frame.size.width, 275);
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context{
    
    if (context == UserModelContext) {
        
        if ([self.user isModelComplete]) {
            [self makeRideShareDataRequestsForUser];
            [self.searchResultsTableView setHidden:YES];
            [self.collectionView setHidden:NO];
        }
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations __OSX_AVAILABLE_STARTING(__MAC_10_9,__IPHONE_6_0) {
    CLLocation *currentLocation = [locations firstObject];
    if (![self.user isModelComplete]) {
        self.user.currentLatitude = [[NSNumber numberWithDouble:currentLocation.coordinate.latitude] stringValue];
        self.user.currentLongitude = [[NSNumber numberWithDouble:currentLocation.coordinate.longitude] stringValue];
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.searchResultsTableView setHidden:NO];
    [self.collectionView setHidden:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self fetchAddressResultsWithString:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self fetchAddressResultsWithString:searchBar.text];
}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar {
    [self fetchAddressResultsWithString:searchBar.text];
}

- (void)fetchAddressResultsWithString:(NSString *)searchText {
//    NSMutableArray<CLPlacemark *> *placemarks = [[NSMutableArray alloc] init];
//    
//    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
//    request.naturalLanguageQuery = searchText;
//    
//    MKLocalSearch *localsearch = [[MKLocalSearch alloc] initWithRequest:request];
//    [localsearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
//        
//        for (MKMapItem *item in response.mapItems) {
//            [placemarks addObject:item.placemark];
//        }
//        
//        if (error && ![searchText isEqualToString:@""]) {
//            [self handleError:error];
//        } else {
//            self.placemarks = placemarks;
//            [self.searchResultsTableView reloadData];
//        }
//    }];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:searchText completionHandler:^(NSArray* placemarks, NSError* error) {
        
        if (error && ![searchText isEqualToString:@""]) {
            [self handleError:error];
        } else {
            self.placemarks = placemarks;
            [self.searchResultsTableView reloadData];
        }
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.placemarks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSearchResultsTableViewCellReuseId forIndexPath:indexPath];
    CLPlacemark * placemark = [self.placemarks objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", placemark.name, placemark.locality];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *address = @"%@1, %@2 %@3, %@4, %@5 %@6";
    
    CLPlacemark *placemark = [self.placemarks objectAtIndex:indexPath.row];
    
    self.user.address = [NSString stringWithFormat:address, placemark.name, placemark.subThoroughfare, placemark.thoroughfare, placemark.locality, placemark.administrativeArea, placemark.postalCode];
    self.user.destinationLatitude = [NSString stringWithFormat:@"%.4f", placemark.location.coordinate.latitude];
    self.user.destinationLongitude = [NSString stringWithFormat:@"%.4f", placemark.location.coordinate.longitude];
    
    [self.searchBar resignFirstResponder];
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
