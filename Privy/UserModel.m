//
//  UserModel.m
//  Privy
//
//  Created by Nathan Pantaleo on 4/3/17.
//  Copyright © 2017 Nathan Pantaleo. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

- (BOOL)isModelComplete {
    return (_currentLatitude && _currentLongitude && _destinationLatitude && _destinationLongitude);
}

@end
