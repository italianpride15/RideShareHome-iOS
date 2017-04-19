//
//  RideServiceCollectionViewCell.m
//  Privy
//
//  Created by Nathan Pantaleo on 4/2/17.
//  Copyright © 2017 Nathan Pantaleo. All rights reserved.
//

#import "RideServiceCollectionViewCell.h"
#import "RideResponseModel.h"
#import "UberRideTableViewCell.h"

static NSString * kRideShareModelTableViewCellReuseId = @"rideShareModelTableViewCellReuseId";

@interface RideServiceCollectionViewCell () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSObject<RideShareModelsProtocol> *model;

@end

@implementation RideServiceCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.estimatedRowHeight = 100;
    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([UberRideTableViewCell class])  bundle:nil] forCellReuseIdentifier:kRideShareModelTableViewCellReuseId];
}

- (void)configureCellForRideShareModel:(NSObject<RideShareModelsProtocol> *)model {
    self.model = model;
    
    RideResponseModel *ride = [self.model.availableRidesFromLowestPrice firstObject];
    if ([ride.serviceName containsString:@"uber"]) {
        [self.imageView setImage:[UIImage imageNamed:@"uber_icon"]];
    } else {
        [self.imageView setImage:[UIImage imageNamed:@"lyft_icon"]];
    }
    [self.tableView reloadData];
    [self.tableView layoutIfNeeded];
    [self.tableView sizeToFit];
    
    if ([[self.tableView visibleCells] count] == [[self.model availableRidesFromLowestPrice] count]) {
        self.tableView.scrollEnabled = NO;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.model numberOfAvailableServices];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UberRideTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRideShareModelTableViewCellReuseId forIndexPath:indexPath];
    RideResponseModel *ride = [self.model.availableRidesFromLowestPrice objectAtIndex:indexPath.row];
    cell.rideName.text = ride.rideName;
    cell.ridePrice.text = [@"$" stringByAppendingString:[ride.estimatedCost stringValue]];
    
    if ([ride.serviceName containsString:@"uber"]) {
        
        if ([ride.rideType containsString:@"BLACK"]) {
            [cell.rideImageView setImage:[UIImage imageNamed:@"uber_car_black"]];
        } else if ([ride.rideType containsString:@"XL"]) {
            [cell.rideImageView setImage:[UIImage imageNamed:@"uber_car_xl"]];
        } else if ([ride.rideType containsString:@"SUV"]) {
            [cell.rideImageView setImage:[UIImage imageNamed:@"uber_car_suv"]];
        } else {
            [cell.rideImageView setImage:[UIImage imageNamed:@"uber_car_x_and_pool"]];
        }
    } else {
        if ([ride.rideType containsString:@"plus"]) {
            [cell.rideImageView setImage:[UIImage imageNamed:@"lyft_car_plus"]];
        } else {
            [cell.rideImageView setImage:[UIImage imageNamed:@"lyft_car_standard"]];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RideResponseModel *ride = [self.model.availableRidesFromLowestPrice objectAtIndex:indexPath.row];
    
    NSString *deepLinkService = nil;
    if ([ride.serviceName containsString:@"uber"]) {
        deepLinkService = @"uber://";
    } else {
        deepLinkService = @"lyft://";
    }
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:deepLinkService]]) {
        [self open:[self.model deepLinkURL]];
    } else {
        // do nothing
    }
}

- (void)open:(NSString *)scheme {
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *URL = [NSURL URLWithString:scheme];
    
    if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        [application openURL:URL options:@{} completionHandler:nil];
    } else {
        [application openURL:URL];
    }
}

@end
