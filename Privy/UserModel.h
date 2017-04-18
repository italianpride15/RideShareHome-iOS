//
//  UserModel.h
//  Privy
//
//  Created by Nathan Pantaleo on 4/3/17.
//  Copyright © 2017 Nathan Pantaleo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject

@property (copy, nonatomic) NSString *currentLatitude;
@property (copy, nonatomic) NSString *currentLongitude;
@property (copy, nonatomic) NSString *destinationLatitude;
@property (copy, nonatomic) NSString *destinationLongitude;

- (BOOL)isModelComplete;

@end
