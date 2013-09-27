//
//  MiniTwitterTabBarViewController.h
//  Mini Twitter For iOS
//
//  Created by udit.ag on 11/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTUser.h"
#import "MTHomeTimelineViewController.h"
@interface MiniTwitterRootViewController : UITabBarController <UITabBarControllerDelegate>
@property (nonatomic, strong) MTUser* currentUser;
@end
