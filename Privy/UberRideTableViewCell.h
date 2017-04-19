//
//  UberRideTableViewCell.h
//  Privy
//
//  Created by Nathan Pantaleo on 4/17/17.
//  Copyright © 2017 Nathan Pantaleo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UberRideTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *rideImageView;
@property (weak, nonatomic) IBOutlet UILabel *rideName;
@property (weak, nonatomic) IBOutlet UILabel *ridePrice;

@end
