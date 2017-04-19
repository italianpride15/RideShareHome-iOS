//
//  RideShareModelsProtocol.h
//  Privy
//
//  Created by Nathan Pantaleo on 4/2/17.
//  Copyright © 2017 Nathan Pantaleo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UserModel;
@class RideResponseModel;

@protocol RideShareModelsProtocol <NSObject>

@required
- (NSArray<RideResponseModel *> *)availableRidesFromLowestPrice;
- (NSUInteger)numberOfAvailableServices;
+ (NSString *)getRequestStringForUser:(UserModel *)user;
+ (NSString *)authorizationToken;
- (NSString *)deepLinkURL;

@end
