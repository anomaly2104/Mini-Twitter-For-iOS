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
#import "Tweet.h"
#import "TweetViewController.h"
#import "UserFollowersViewController.h"
#import "UserFollowingViewController.h"
#import "CoreDataTableViewController.h"

@interface UserTweetsViewController : CoreDataTableViewController

@property (nonatomic, strong) User* user;
@end
