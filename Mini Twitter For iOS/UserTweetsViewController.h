//
//  UserTweetsViewController.h
//  Mini Twitter For iOS
//
//  Created by udit.ag on 04/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface UserTweetsViewController : UITableViewController
@property (nonatomic, strong) NSArray* homeTimelineTweets;
@property (nonatomic, strong) User* user;
@end
