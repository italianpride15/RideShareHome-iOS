//
//  UberModel.m
//  Privy
//
//  Created by Nathan Pantaleo on 4/2/17.
//  Copyright © 2017 Nathan Pantaleo. All rights reserved.
//

#import "UberModel.h"
#import "UserModel.h"
#import "RideResponseModel.h"

static NSString * const kUberClientId = @"XikKX8YmAoiTaE4PxmvKK2xImKtMFKIG";
static NSString * const kUberServerToken = @"p4xGiso2Lt5slHGTHSg9fHRgJMT0OUmsn5ksrJw3";
static NSString * const kUberBaseUrl = @"https://api.uber.com/v1.2/estimates/price?";
static NSString * const kDeepLinkQuery = @"uber://?client_id=XikKX8YmAoiTaE4PxmvKK2xImKtMFKIG&action=setPickup&pickup[latitude]=%@1&pickup[longitude]=%@2&dropoff[latitude]=%@3&dropoff[longitude]=%@4&dropoff[formatted_address]=%@5";

@interface UberModel ()

@property (strong, nonatomic) NSArray<RideResponseModel *> *rides;
@property (copy, nonatomic) NSString *deepLinkQuery;

@end

@implementation UberModel

- (instancetype)initWithResponse:(NSDictionary *)response andUserModel:(UserModel *)user {
    self = [super init];
    
    if (self) {
        NSMutableArray *sortedArray = [[NSMutableArray alloc] init];
        for (NSDictionary *rideResponse in [response objectForKey:@"prices"]) {
            if (![[rideResponse valueForKey:@"estimate"] isEqualToString:@"Metered"]) {
                RideResponseModel * ride = [[RideResponseModel alloc] init];
                ride.rideName = [rideResponse valueForKey:@"display_name"];
                ride.rideType = [rideResponse valueForKey:@"display_name"];
                ride.multiplier = [rideResponse valueForKey:@"surge_multiplier"];
                ride.serviceName = @"uber";
                
                NSArray *estimateRange = [[rideResponse valueForKey:@"estimate"] componentsSeparatedByString:@"-"];
                ride.estimatedCost = @(([[[estimateRange objectAtIndex:0] substringFromIndex:1] doubleValue] + [[estimateRange objectAtIndex:1] doubleValue]) / 2);
                [sortedArray addObject:ride];
            }
        }
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"estimatedCost"
                                                     ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        _rides = [sortedArray sortedArrayUsingDescriptors:sortDescriptors];
        
        _deepLinkQuery = [NSString stringWithFormat:kDeepLinkQuery, user.currentLatitude, user.currentLongitude, user.destinationLatitude, user.destinationLongitude, user.address];
    }
    return self;
}

#pragma mark - RideShareModelsProtocol

- (NSArray *)availableRidesFromLowestPrice {
    return self.rides;
}

- (NSUInteger)numberOfAvailableServices {
    return [self.rides count];
}

+ (NSString *)getRequestStringForUser:(UserModel *)user {
    
    NSMutableString *queryString = [[NSMutableString alloc] init];
    [queryString appendString:kUberBaseUrl];
    [queryString appendString:@"start_latitude="];
    [queryString appendString:user.currentLatitude];
    [queryString appendString:@"&start_longitude="];
    [queryString appendString:user.currentLongitude];
    [queryString appendString:@"&end_latitude="];
    [queryString appendString:user.destinationLatitude];
    [queryString appendString:@"&end_longitude="];
    [queryString appendString:user.destinationLongitude];
    
    return [queryString copy];
}

+ (NSString *)authorizationToken {
    return [NSString stringWithFormat:@"%@ %@", @"Token", kUberServerToken];
}

- (NSString *)deepLinkURL {
    return self.deepLinkQuery;
}

//+ (NSString *)getDeeplinkRequestString {
//    [queryString appendString:@"&dropoff[latitude]="];
//    [queryString appendString:@"&dropoff[longitude]="];
//    [queryString appendString:@"&dropoff[formatted_address]="];
//
//    NSMutableString *mutableAddress = [address mutableCopy];
//    [mutableAddress replaceOccurrencesOfString:@"+" withString:@"%20" options:0 range:NSMakeRange(0, address.length)];
//    [queryString appendString:mutableAddress];
//}
/*
{
    "prices": [
               {
                   "localized_display_name": "POOL",
                   "distance": 6.17,
                   "display_name": "POOL",
                   "product_id": "26546650-e557-4a7b-86e7-6a3942445247",
                   "high_estimate": 15,
                   "low_estimate": 13,
                   "surge_multiplier": 2,
                   "duration": 1080,
                   "estimate": "$13-14",
                   "currency_code": "USD"
               },
               {
                   "localized_display_name": "uberX",
                   "distance": 6.17,
                   "display_name": "uberX",
                   "product_id": "a1111c8c-c720-46c3-8534-2fcdd730040d",
                   "high_estimate": 17,
                   "low_estimate": 13,
                   "duration": 1080,
                   "estimate": "$13-17",
                   "currency_code": "USD"
               },
               {
                   "localized_display_name": "uberXL",
                   "distance": 6.17,
                   "display_name": "uberXL",
                   "product_id": "821415d8-3bd5-4e27-9604-194e4359a449",
                   "high_estimate": 26,
                   "low_estimate": 20,
                   "duration": 1080,
                   "estimate": "$20-26",
                   "currency_code": "USD"
               },
               {
                   "localized_display_name": "SELECT",
                   "distance": 6.17,
                   "display_name": "SELECT",
                   "product_id": "57c0ff4e-1493-4ef9-a4df-6b961525cf92",
                   "high_estimate": 38,
                   "low_estimate": 30,
                   "duration": 1080,
                   "estimate": "$30-38",
                   "currency_code": "USD"
               },
               {
                   "localized_display_name": "BLACK",
                   "distance": 6.17,
                   "display_name": "BLACK",
                   "product_id": "d4abaae7-f4d6-4152-91cc-77523e8165a4",
                   "high_estimate": 43,
                   "low_estimate": 43,
                   "duration": 1080,
                   "estimate": "$43.10",
                   "currency_code": "USD"
               },
               {
                   "localized_display_name": "SUV",
                   "distance": 6.17,
                   "display_name": "SUV",
                   "product_id": "8920cb5e-51a4-4fa4-acdf-dd86c5e18ae0",
                   "high_estimate": 63,
                   "low_estimate": 50,
                   "duration": 1080,
                   "estimate": "$50-63",
                   "currency_code": "USD"
               },
               {
                   "localized_display_name": "ASSIST",
                   "distance": 6.17,
                   "display_name": "ASSIST",
                   "product_id": "ff5ed8fe-6585-4803-be13-3ca541235de3",
                   "high_estimate": 17,
                   "low_estimate": 13,
                   "duration": 1080,
                   "estimate": "$13-17",
                   "currency_code": "USD"
               },
               {
                   "localized_display_name": "WAV",
                   "distance": 6.17,
                   "display_name": "WAV",
                   "product_id": "2832a1f5-cfc0-48bb-ab76-7ea7a62060e7",
                   "high_estimate": 33,
                   "low_estimate": 25,
                   "duration": 1080,
                   "estimate": "$25-33",
                   "currency_code": "USD"
               },
               {
                   "localized_display_name": "TAXI",
                   "distance": 6.17,
                   "display_name": "TAXI",
                   "product_id": "3ab64887-4842-4c8e-9780-ccecd3a0391d",
                   "high_estimate": null,
                   "low_estimate": null,
                   "duration": 1080,
                   "estimate": "Metered",
                   "currency_code": null
               }
               ]
}
*/

@end
