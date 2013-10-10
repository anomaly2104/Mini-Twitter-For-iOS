//
//  MiniTwitterTabBarViewController.m
//  Mini Twitter For iOS
//
//  Created by udit.ag on 11/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "MTRootViewController.h"
#import "MTTweetCell.h"
#import "MTUserTweetsViewController.h"
#import "MTCreateTweetViewController.h"
#import "MTSettingsViewController.h"
#import "TweeterFetcher.h"

@implementation MTRootViewController
@synthesize currentUser = _currentUser;

- (MTUser*)currentUser {
    if (!_currentUser) _currentUser = [[MTUser alloc] init];
    return _currentUser;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)setTabBarViewControllersCurrentUsers {
    NSMutableArray* newViewControllers = [self.viewControllers mutableCopy];
    for (UINavigationController* navigationController in newViewControllers) {
        if ( [navigationController isKindOfClass:[UINavigationController class]]) {
            UIViewController* tabBarController = [navigationController.viewControllers lastObject];
            if ([tabBarController isKindOfClass:[MTUserTweetsViewController class]] &&
                [tabBarController respondsToSelector:@selector(setUser:)]) {
                [tabBarController performSelector:@selector(setUser:) withObject:self.currentUser];
            } else if ([tabBarController isKindOfClass: [MTHomeTimelineViewController class] ]) {
                [tabBarController performSelector:@selector(setCurrentUser:) withObject:self.currentUser];
            }
        }
    }
    
    if ( self.viewControllers != newViewControllers ) {
        self.viewControllers = newViewControllers;
    }
}

- (void)setTabBarViewControllersBarTintColors {
    for (UINavigationController* navigationController in self.viewControllers) {
        if ( [navigationController isKindOfClass:[UINavigationController class]]) {
            if ([[navigationController.viewControllers lastObject] isKindOfClass:[MTUserTweetsViewController class]]) {
                navigationController.navigationBar.barTintColor = [UIColor blueColor];
            } else if ([[navigationController.viewControllers lastObject] isKindOfClass:[MTHomeTimelineViewController class]]) {
                navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.64
                                                                                  green:0.16
                                                                                   blue:0.16
                                                                                  alpha:1.0];
            } else if ([[navigationController.viewControllers lastObject] isKindOfClass:[MTCreateTweetViewController class]]) {
                navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0
                                                                                  green:0.39
                                                                                   blue:0.0
                                                                                  alpha:1.0];
            } else if ([[navigationController.viewControllers lastObject] isKindOfClass:[MTSettingsViewController class]]) {
                navigationController.navigationBar.barTintColor = [UIColor brownColor];
            }
            
            navigationController.navigationBar.tintColor = [UIColor whiteColor];
            
            
        }
    }
    
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor], UITextAttributeTextColor,
                                               [UIColor blackColor], UITextAttributeTextShadowColor,
                                               [NSValue valueWithUIOffset:UIOffsetMake(-1, 0)], UITextAttributeTextShadowOffset, nil];
    
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];

    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    [self setTabBarViewControllersCurrentUsers];
    [self setTabBarViewControllersBarTintColors];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        [viewController performSelector:@selector(popToRootViewControllerAnimated:) ];
    }
}

@end
