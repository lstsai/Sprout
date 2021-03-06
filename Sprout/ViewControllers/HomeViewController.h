//
//  HomeViewController.h
//  Sprout
//
//  Created by laurentsai on 7/14/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//
/*
 View controller that displays the posts for the user
 */
#import <UIKit/UIKit.h>
#import "InfiniteScrollActivityView.h"
NS_ASSUME_NONNULL_BEGIN

@interface HomeViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *posts;
@property (nonatomic) int pageNum;
@property (strong, nonatomic) InfiniteScrollActivityView* loadingMoreView;
@property (nonatomic) BOOL isMoreDataLoading;
@property (weak, nonatomic) IBOutlet UIButton *requestsButton;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;
-(void) getPosts:( UIRefreshControl * _Nullable )refreshControl;
-(void) setupLoadingIndicators;
-(void) getRequestAndMessages;
@end

NS_ASSUME_NONNULL_END
