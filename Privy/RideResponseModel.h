//
//  RideResponseModel.h
//  Privy
//
//  Created by Nathan Pantaleo on 4/7/17.
//  Copyright © 2017 Nathan Pantaleo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RideResponseModel : NSObject

@property (copy, nonatomic) NSString *rideType;
@property (copy, nonatomic) NSString *rideName;
@property (copy, nonatomic) NSNumber *estimatedCost;
@property (copy, nonatomic) NSString *multiplier;

@end
