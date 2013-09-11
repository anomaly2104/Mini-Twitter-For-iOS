//
//  HomeTimelineViewController.h
//  Mini Twitter For iOS
//
//  Created by udit.ag on 04/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TweeterFetcher.h"
#import "HomeTimelineTweetCell.h"
#import "Utils.h"
#import "Tweet.h"
#import "TweetViewController.h"

@interface HomeTimelineViewController : UITableViewController
@property (nonatomic, strong) NSArray* homeTimelineTweets;
@end
