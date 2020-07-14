//
//  CreateViewController.h
//  Sprout
//
//  Created by laurentsai on 7/14/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationManager.h"
NS_ASSUME_NONNULL_BEGIN

@protocol CreateViewControllerDelegate

- (void)didCreateEvent;

@end

@interface CreateViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *eventImage;
@property (weak, nonatomic) IBOutlet UITextField *eventNameField;
@property (weak, nonatomic) IBOutlet UITextField *dateField;
@property (weak, nonatomic) IBOutlet UITextField *locationField;
@property (weak, nonatomic) IBOutlet UITextView *detailsTextView;
@property (weak, nonatomic) id<CreateViewControllerDelegate> delegate;

-(void) setupDatePicker;
-(void) dateTextField:(id)sender;

@end

NS_ASSUME_NONNULL_END