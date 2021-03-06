//
//  RideServiceCollectionViewCell.h
//  Privy
//
//  Created by Nathan Pantaleo on 4/2/17.
//  Copyright © 2017 Nathan Pantaleo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RideShareModelsProtocol.h"

@interface RideServiceCollectionViewCell : UICollectionViewCell

- (void)configureCellForRideShareModel:(NSObject<RideShareModelsProtocol> *)model;

@end
