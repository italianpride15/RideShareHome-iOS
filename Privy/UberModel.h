//
//  UberModel.h
//  Privy
//
//  Created by Nathan Pantaleo on 4/2/17.
//  Copyright © 2017 Nathan Pantaleo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RideShareModelsProtocol.h"

@class UserModel;

@interface UberModel : NSObject <RideShareModelsProtocol>

- (instancetype)initWithResponse:(NSDictionary *)response;

@end
