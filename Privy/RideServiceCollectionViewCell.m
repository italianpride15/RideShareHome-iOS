//
//  RideServiceCollectionViewCell.m
//  Privy
//
//  Created by Nathan Pantaleo on 4/2/17.
//  Copyright © 2017 Nathan Pantaleo. All rights reserved.
//

#import "RideServiceCollectionViewCell.h"
#import "RideShareModelsProtocol.h"

static NSString * kRideShareModelTableViewCellReuseId = @"rideShareModelTableViewCellReuseId";

@interface RideServiceCollectionViewCell () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSObject<RideShareModelsProtocol> *model;

@end

@implementation RideServiceCollectionViewCell

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _tableView.delegate = self;
        _tableView.estimatedRowHeight = 100;
    }
    return self;
}

- (void)configureCellWithModel:(NSObject<RideShareModelsProtocol> *)model {
    self.model = model;
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.model numberOfAvailableServices];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRideShareModelTableViewCellReuseId forIndexPath:indexPath];
    return cell;
}

@end
