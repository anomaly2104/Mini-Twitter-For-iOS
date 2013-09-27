//
//  UserFollowersViewController.h
//  Mini Twitter For iOS
//
//  Created by udit.ag on 13/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTUser.h"
#import "MTUserCell.h"
#import "MTPadder.h"
#import "TweeterFetcher.h"
#import "MTCoreDataTableViewController.h"

@interface MTUserFollowersViewController : MTCoreDataTableViewController
@property (nonatomic, strong) MTUser* user;
@end
