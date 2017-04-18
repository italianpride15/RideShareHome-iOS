//
//  RideServiceCollectionViewCell.m
//  Privy
//
//  Created by Nathan Pantaleo on 4/2/17.
//  Copyright © 2017 Nathan Pantaleo. All rights reserved.
//

#import "RideServiceCollectionViewCell.h"
#import "RideResponseModel.h"

static NSString * kRideShareModelTableViewCellReuseId = @"rideShareModelTableViewCellReuseId";

@interface RideServiceCollectionViewCell () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSObject<RideShareModelsProtocol> *model;

@end

@implementation RideServiceCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.estimatedRowHeight = 100;
}

- (void)configureCellForRideShareModel:(NSObject<RideShareModelsProtocol> *)model {
    self.model = model;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.model numberOfAvailableServices];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRideShareModelTableViewCellReuseId forIndexPath:indexPath];
    RideResponseModel *ride = [self.model.availableRidesFromLowestPrice objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor blueColor];
    cell.textLabel.text = ride.rideName;
    cell.detailTextLabel.text = [ride.estimatedCost stringValue];
    return cell;
}

@end
