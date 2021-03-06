//
//  EventPostCell.m
//  Sprout
//
//  Created by laurentsai on 7/21/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "EventPostCell.h"
#import "DateTools.h"
#import "Constants.h"
#import "Helper.h"
@import Parse;
@implementation EventPostCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
/**
Loads the views of the cell to represent the post
*/
-(void) loadData{
    UIGestureRecognizer *profileTapGesture= [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapUserProfile:)];
    [self.profileImage setUserInteractionEnabled:YES];
    [self.profileImage addGestureRecognizer:profileTapGesture];
    
    self.nameLabel.text=self.post.author.username;
    
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.profileImage.clipsToBounds = YES;
    self.profileImage.layer.masksToBounds=YES;
    self.profileImage.file=self.post.author[@"profilePic"];
    [self.profileImage loadInBackground];
    self.postDescriptionLabel.text=self.post.postDescription;
    self.timeLabel.text=[self.post.createdAt shortTimeAgoSinceNow];
    
    self.likeButton.selected=[PFUser.currentUser[@"likedEvents"] containsObject:self.event.objectId];
    
    self.event=self.post.event;
    self.eventImage.file=self.event.image;
    [self.eventImage loadInBackground];
    
    self.eventNameLabel.text=self.event.name;
    [self setShadow];

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yy h:mm a"];
    self.eventDateTime.text = [dateFormat stringFromDate:self.event.startTime];
    [self performSelectorInBackground:@selector(getLikes) withObject:nil];

}
/**
setup the shadoes and rounded cell corners
*/
-(void) setShadow{
    self.eventContainer.layer.cornerRadius = CELL_CORNER_RADIUS*2;
    self.eventContainer.layer.borderColor = [UIColor clearColor].CGColor;
    self.eventContainer.layer.masksToBounds = YES;
    self.eventContainer.clipsToBounds = YES;
    self.eventContainer.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.eventContainer.layer.shadowOffset = CGSizeMake(0, SHADOW_OFFSET/2);
    self.eventContainer.layer.shadowRadius = SHADOW_RADIUS;
    self.eventContainer.layer.shadowOpacity = SHADOW_OPACITY;
    self.eventContainer.layer.masksToBounds = NO;
}
/**
Calculates the number of friends that have liked the event the post is about
 */
-(void) getLikes{
    PFQuery * friendAccessQ=[PFQuery queryWithClassName:@"UserAccessible"];
    [friendAccessQ whereKey:@"username" equalTo:PFUser.currentUser.username];
    [friendAccessQ getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        PFObject* userAccess=object;
        if(userAccess[@"friendEvents"][self.event.objectId])
        {
            self.event.numFriendsLike=((NSArray*)userAccess[@"friendEvents"][self.event.objectId]).count;
            if(self.event.numFriendsLike>0){
                if(self.event.numFriendsLike==1)
                    self.numLikeLabel.text=[NSString stringWithFormat:@"%lu friend has liked this", self.event.numFriendsLike];
                else
                    self.numLikeLabel.text=[NSString stringWithFormat:@"%lu friend has liked this", self.event.numFriendsLike];
                self.numLikeLabel.alpha=SHOW_ALPHA;
            }
        }
        else
        {
            self.numLikeLabel.alpha=HIDE_ALPHA;
        }
    }];
}
/**
Triggered when the user taps the like button and updates the user profiles accordingly by
calling a helper method
@param[in] sender the UIbutton that was pressed

*/
- (IBAction)didTapLike:(id)sender {
    
    if(!self.likeButton.selected)
    {
        self.likeButton.selected=YES;
        [Helper didLikeEvent:self.event senderVC:nil];

    }
    else{
        self.likeButton.selected=NO;
        [Helper didUnlikeEvent:self.event];

    }
}
- (IBAction)didTapComment:(id)sender {
    [self.delegate didTapComment:self.post];
}
/**
Triggered when the user taps on the user profile image
@param[in] sender the gesture recognizer that was triggered
call the delegate method to segue to the profile page
*/
- (void) didTapUserProfile:(UITapGestureRecognizer *)sender{
    [self.delegate didTapUser:self.post.author];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
