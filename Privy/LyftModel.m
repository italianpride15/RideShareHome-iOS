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

@interface LyftModel ()

@property (strong, nonatomic) NSArray<RideResponseModel *> *rides;

@end

@implementation LyftModel

- (instancetype)initWithResponse:(NSURLResponse *)response {
    self = [super init];
    
    if (self) {
        NSMutableOrderedSet *sortedRides = [[NSMutableOrderedSet alloc] initWithArray:self.rides];
        //sort array
        self.rides = [sortedRides array];
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
