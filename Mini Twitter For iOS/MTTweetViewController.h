//
//  TweetViewController.h
//  Mini Twitter For iOS
//
//  Created by udit.ag on 05/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTTweet.h"
#import "Utils.h"
#import "MTUserTweetsViewController.h"

@interface MTTweetViewController : UITableViewController
@property (nonatomic, strong) MTTweet* tweet;
@end
