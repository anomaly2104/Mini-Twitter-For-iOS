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
#import "TweeterFetcher.h"

@interface MTRootViewController ()

@end

@implementation MTRootViewController
@synthesize currentUser = _currentUser;

-(MTUser*) currentUser{
    if(!_currentUser) _currentUser = [[MTUser alloc] init];
    return _currentUser;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

-(void) setHomeCurrentUser{
    
}

-(void) setTabBarViewControllersCurrentUsers{
    NSMutableArray* newViewControllers = [self.viewControllers mutableCopy];

    for(UINavigationController* navigationController in newViewControllers){
        if( [navigationController isKindOfClass:[UINavigationController class]]){
            UIViewController* tabBarController = [navigationController.viewControllers lastObject];
            if ([tabBarController isKindOfClass:[MTUserTweetsViewController class]] && [tabBarController respondsToSelector:@selector(setUser:)]) {
                [tabBarController performSelector:@selector(setUser:) withObject:self.currentUser];
            } else if([tabBarController isKindOfClass: [MTHomeTimelineViewController class] ]){
                [tabBarController performSelector:@selector(setCurrentUser:) withObject:self.currentUser];
            }
        }
    }
    
    if ( self.viewControllers != newViewControllers ) {
        self.viewControllers = newViewControllers;
    }

   /*
    UINavigationController* userTweetsNavigationViewController = [self.viewControllers objectAtIndex:1];
    //    NSLog(@"Class of object at 1: %@",[userTweetsNavigationViewController class]);
    
    UserTweetsViewController *userTweetsViewController = [userTweetsNavigationViewController.viewControllers lastObject];
    //  NSLog(@"Class of object at 1: %@",[userTweetsViewController class]);
    
    if([userTweetsViewController isKindOfClass:[UserTweetsViewController class]]){
        [userTweetsViewController setUser:self.currentUser];
        userTweetsNavigationViewController.viewControllers = [NSArray arrayWithObject:userTweetsViewController];
        
        NSMutableArray* newViewControllers = [self.viewControllers mutableCopy];
        [newViewControllers setObject:userTweetsNavigationViewController atIndexedSubscript:1];
        self.viewControllers = newViewControllers;
    }
*/
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    [self setTabBarViewControllersCurrentUsers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSLog(@"Prepare for segue in tab bar vc");
}

- (void) tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    if([viewController isKindOfClass:[UINavigationController class]]){
        [viewController performSelector:@selector(popToRootViewControllerAnimated:) ];
    }
//    NSLog(@"Class of selected object: %@",[viewController class]);
}

@end
