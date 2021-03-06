//
//  OrgCell.h
//  Sprout
//
//  Created by laurentsai on 7/13/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//
/**
 Table view cell to represent organizations in the search page
 */
#import <UIKit/UIKit.h>
#import "Organization.h"
#import "ClaimedOrganization.h"
@import Parse;
NS_ASSUME_NONNULL_BEGIN

@interface OrgCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tagLineLabel;
@property (weak, nonatomic) IBOutlet PFImageView *orgImage;
@property (strong, nonatomic) Organization *org;
@property (strong, nonatomic) ClaimedOrganization *_Nullable claimedOrg;
@property (weak, nonatomic) IBOutlet UILabel *numLikesLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;

-(void) checkClaimed;
-(void) loadData;
-(void) getLikes;
@end

NS_ASSUME_NONNULL_END
