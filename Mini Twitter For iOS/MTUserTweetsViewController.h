//
//  UserTweetsViewController.h
//  Mini Twitter For iOS
//
//  Created by udit.ag on 04/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TweeterFetcher.h"
#import "TweetCell.h"
#import "Utils.h"
#import "MTTweet.h"
#import "MTTweetViewController.h"
#import "MTUserFollowersViewController.h"
#import "MTUserFollowingViewController.h"
#import "MTCoreDataTableViewController.h"

@interface MTUserTweetsViewController : MTCoreDataTableViewController

@property (nonatomic, strong) MTUser* user;
@end
