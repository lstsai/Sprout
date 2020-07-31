
//
//  EventDetailsViewController.m
//  Sprout
//
//  Created by laurentsai on 7/15/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "EventDetailsViewController.h"
#import "CreatePostViewController.h"
#import "Helper.h"
#import "MapViewController.h"
#import "Constants.h"
#import "EventGroupViewController.h"
@interface EventDetailsViewController ()

@end

@implementation EventDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadEventDetails];
}
/**
Loads the view controller's views to reflect the event it is representing
*/
-(void) loadEventDetails{
    self.eventNameLabel.text=self.event.name;
    [self.event.author fetchIfNeeded];
    self.eventAuthorLabel.text= self.event.author.username;
    self.eventLocationLabel.text=self.event.streetAddress;
    
    self.eventDetailsLabel.text= self.event.details;
    NSString *sdateString, *edateString;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    //display the start time and end time differently depending on if start and end are on same day
    if([[NSCalendar currentCalendar] isDate:self.event.startTime inSameDayAsDate:self.event.endTime])
    {
        [dateFormat setDateFormat:@"E, d MMM yyyy\nh:mm a"];
        sdateString = [dateFormat stringFromDate:self.event.startTime];
        [dateFormat setDateFormat:@" - h:mm a"];
        edateString=[dateFormat stringFromDate:self.event.endTime];
        self.eventTimeLabel.text=[sdateString stringByAppendingString:edateString];
    }
    else{
        [dateFormat setDateFormat:@"E, d MMM yyyy h:mm a"];
        sdateString = [dateFormat stringFromDate:self.event.startTime];
        edateString =[dateFormat stringFromDate:self.event.endTime];
        self.eventTimeLabel.text=[sdateString stringByAppendingFormat:@"\nTo %@", edateString];
    }
    
    if(self.event.image)
    {
        self.eventImageView.file=self.event.image;
        [self.eventImageView loadInBackground];
    }
    if([PFUser.currentUser[@"likedEvents"] containsObject:self.event.objectId])
    {
        self.likeButton.selected=YES;
        self.groupButton.alpha=SHOW_ALPHA;
    }
    [self performSelectorInBackground:@selector(getLikes) withObject:nil];

}
/**
 calculates the number of friends that have liked this specific event
 only shows the label if at least one friend has liked it
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
                self.numLikesLabel.text=[NSString stringWithFormat:@"%lu friends liked this", self.event.numFriendsLike];
                self.numLikesLabel.alpha=SHOW_ALPHA;
            }
        }
        else
        {
            self.numLikesLabel.alpha=HIDE_ALPHA;
        }
    }];
}
/**
Triggered when the user (un)likes this event. Calls the Helper method didLikeEvent or
 didUnlikeEvent to update user fields on parse.
 @param[in] sender the UIButton that was tapped
*/
- (IBAction)didTapLike:(id)sender {
    if(!self.likeButton.selected)
    {
        self.likeButton.selected=YES;
        self.groupButton.alpha=SHOW_ALPHA;
        [Helper didLikeEvent:self.event senderVC:self];
    }
    else{
        self.likeButton.selected=NO;
        self.groupButton.alpha=HIDE_ALPHA;
        [Helper didUnlikeEvent:self.event];
    }
}
/**
Triggered when the user taps the address of the event and presents the MapViewController
@param[in] sender the address that was tapped
*/
- (IBAction)didTapAddress:(id)sender {
    [self performSegueWithIdentifier:@"mapSegue" sender:nil];
}

/**
Triggered when the user taps the time of the event and creates a calander event
@param[in] sender the time that was tapped
*/
- (IBAction)didTapTime:(id)sender {
    UIAlertController* alert= [UIAlertController alertControllerWithTitle:@"Add Event to Calendar" message:@"Would you like to add this event to your calender?" preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        EKEventStore *store = [EKEventStore new];
        [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (!granted) { return; }
            EKEvent *event = [EKEvent eventWithEventStore:store];
            event.title = self.event.name;
            event.startDate = self.event.startTime; //today
            event.endDate = self.event.endTime;
            event.calendar = [store defaultCalendarForNewEvents];
            NSError *err = nil;
            [store saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
        }];
    }];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:noAction];
    [alert addAction:okAction];

    [self presentViewController:alert animated:YES completion:nil];
}
/**
 Triggered when the user pinches to zoom on the image. Will animate back to original
 state when the user stops pinching.
 @param[in] sender the pinch gesture that was triggered
 */
- (IBAction)didPinchImage:(id)sender {

    UIPinchGestureRecognizer* pinch= sender;
    //end pinching, go back to original
    if(UIGestureRecognizerStateEnded == [pinch state]){
        [UIView animateWithDuration:ANIMATION_DURATION/3 animations:^{
            self.eventImageView.transform=CGAffineTransformIdentity;
        }];
    }
    UIView *pinchView = pinch.view;
    CGRect bounds = pinchView.bounds;
    CGPoint pinchCenter = [pinch locationInView:pinchView];
    pinchCenter.x -= CGRectGetMidX(bounds);
    pinchCenter.y -= CGRectGetMidY(bounds);
    CGAffineTransform transform = pinchView.transform;
    transform = CGAffineTransformTranslate(transform, pinchCenter.x, pinchCenter.y);
    CGFloat scale = pinch.scale;
    transform = CGAffineTransformScale(transform, scale, scale);
    transform = CGAffineTransformTranslate(transform, -pinchCenter.x, -pinchCenter.y);
    pinchView.transform = transform;
    pinch.scale = PINCH_SCALE;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"eventPostSegue"])//takes the user to the page to create post about this event
    {
        CreatePostViewController *createPostVC=segue.destinationViewController;
        createPostVC.event=self.event;
        createPostVC.org=nil;
        createPostVC.isGroupPost=NO;
    }
    else if([segue.identifier isEqualToString:@"mapSegue"])//shows the user the map view of the event location
    {
        MapViewController *mapVC=segue.destinationViewController;
        mapVC.objects=@[self.event];
    }
    else if([segue.identifier isEqualToString:@"eventGroupSegue"])//shows the user the map view of the event location
    {
        EventGroupViewController *eventgroupVC=segue.destinationViewController;
        eventgroupVC.event=self.event;
    }
}


@end
