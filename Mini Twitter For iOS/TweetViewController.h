//
//  TweetViewController.h
//  Mini Twitter For iOS
//
//  Created by udit.ag on 05/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"
#import "Utils.h"
#import "UserTweetsViewController.h"

@interface TweetViewController : UITableViewController
@property (nonatomic, strong) Tweet* tweet;
@end
