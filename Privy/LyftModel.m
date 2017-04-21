//
//  LyftModel.m
//  Privy
//
//  Created by Nathan Pantaleo on 4/2/17.
//  Copyright © 2017 Nathan Pantaleo. All rights reserved.
//

#import "LyftModel.h"
#import "UserModel.h"
#import "RideResponseModel.h"

static NSString * const kLyftBaseUrl = @"https://api.lyft.com/v1/cost?";
static NSString * const kLyftServerToken = @"gAAAAABXvLCSlzBKw2FIZwCKQoddWym8pl4IcJniHCtO2MRAE8Wc9X91Cs5ChDBrClUEiZ8Jbg5bWRl4BwnFuWtd4a6VNGmu9AXjNFiwXx8MZ1JPN1OLhMLx7_n5wR_uPXG4NqThvIl-bj6JLBiGjynxT1_eofVj26KWjnxwyNSS-foXFluHbXc=";
static NSString * const kLyftClientId = @"1-HcRoLe-9Vd";
static NSString * const kDeepLinkQuery = @"lyft://?clientId=1-HcRoLe-9Vd&ridetype?id=%@&pickup[latitude]=%@&pickup[longitude]=%@&destination[latitude]=%@&destination[longitude]=%@";

@interface LyftModel ()

@property (strong, nonatomic) NSArray<RideResponseModel *> *rides;
@property (copy, nonatomic) NSString *deepLinkQuery;

@end

@implementation LyftModel

- (instancetype)initWithResponse:(NSDictionary *)response andUserModel:(UserModel *)user {
    self = [super init];
    
    if (self) {
        NSMutableArray *sortedArray = [[NSMutableArray alloc] init];
        for (NSDictionary *rideResponse in [response objectForKey:@"cost_estimates"]) {
            RideResponseModel * ride = [[RideResponseModel alloc] init];
            ride.rideName = [rideResponse valueForKey:@"display_name"];
            ride.rideType = [rideResponse valueForKey:@"ride_type"];
            ride.multiplier = [[rideResponse valueForKey:@"primetime_percentage"] isEqualToString:@"0%"] ? nil : [rideResponse valueForKey:@"primetime_percentage"];
            ride.serviceName = @"lyft";
            
            NSInteger costInCents = [[rideResponse objectForKey:@"estimated_cost_cents_max"] integerValue];
            NSInteger dollars = costInCents / 100;
            double cents = (costInCents % 100) / 100.0;
            ride.estimatedCost = @(dollars + cents);
            [sortedArray addObject:ride];
        }
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"estimatedCost"
                                                                       ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        _rides = [sortedArray sortedArrayUsingDescriptors:sortDescriptors];
        
        _deepLinkQuery = [NSString stringWithFormat:kDeepLinkQuery, @"%@", user.currentLatitude, user.currentLongitude, user.destinationLatitude, user.destinationLongitude];
    }
    return self;
}

#pragma mark - RideShareModelsProtocol

- (NSArray *)availableRidesFromLowestPrice {
    return self.rides; //sorted in init
}

- (NSUInteger)numberOfAvailableServices {
    return [self.rides count];
}

+ (NSString *)getRequestStringForUser:(UserModel *)user {
    
    NSMutableString *queryString = [[NSMutableString alloc] init];
    [queryString appendString:kLyftBaseUrl];
    [queryString appendString:@"start_lat="];
    [queryString appendString:user.currentLatitude];
    [queryString appendString:@"&start_lng="];
    [queryString appendString:user.currentLongitude];
    [queryString appendString:@"&end_lat="];
    [queryString appendString:user.destinationLatitude];
    [queryString appendString:@"&end_lng="];
    [queryString appendString:user.destinationLongitude];
    
    return [queryString copy];
}

+ (NSString *)authorizationToken {
    return [NSString stringWithFormat:@"%@ %@", @"bearer", kLyftServerToken];
}

- (NSString *)deepLinkURL {
    return self.deepLinkQuery;
}

/*
{
    "cost_estimates": [
                       {
                           "ride_type": "lyft_plus",
                           "estimated_duration_seconds": 913,
                           "estimated_distance_miles": 3.29,
                           "estimated_cost_cents_max": 2355,
                           "primetime_percentage": "25%",
                           "currency": "USD",
                           "estimated_cost_cents_min": 1561,
                           "display_name": "Lyft Plus",
                           "primetime_confirmation_token": null,
                           "is_valid_estimate": true
                       },
                       {
                           "ride_type": "lyft_line",
                           "estimated_duration_seconds": 913,
                           "estimated_distance_miles": 3.29,
                           "estimated_cost_cents_max": 475,
                           "primetime_percentage": "0%",
                           "currency": "USD",
                           "estimated_cost_cents_min": 475,
                           "display_name": "Lyft Line",
                           "primetime_confirmation_token": null,
                           "is_valid_estimate": true
                       },
                       {
                           "ride_type": "lyft",
                           "estimated_duration_seconds": 913,
                           "estimated_distance_miles": 3.29,
                           "estimated_cost_cents_max": 1755,
                           "primetime_percentage": "25%",
                           "currency": "USD",
                           "estimated_cost_cents_min": 1052,
                           "display_name": "Lyft",
                           "primetime_confirmation_token": null,
                           "is_valid_estimate": true
                       }
                       ]
}
*/
@end
