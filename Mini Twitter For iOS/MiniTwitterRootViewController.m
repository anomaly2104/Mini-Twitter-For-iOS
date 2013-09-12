//
//  MiniTwitterTabBarViewController.m
//  Mini Twitter For iOS
//
//  Created by udit.ag on 11/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "MiniTwitterRootViewController.h"
#import "TweetCell.h"
#import "UserTweetsViewController.h"
#import "TweeterFetcher.h"

@interface MiniTwitterRootViewController ()

@end

@implementation MiniTwitterRootViewController
@synthesize currentUser = _currentUser;

-(User*) currentUser{
    if(!_currentUser) _currentUser = [[User alloc] init];
    return _currentUser;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
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
//        self.viewControllers = [NSArray arrayWithObjects:[self.viewControllers objectAtIndex:0], userTweetsNavigationViewController, [self.viewControllers objectAtIndex:2],nil];
        //[[self.viewControllers objectAtIndex:1] setUser:self.currentUser];
    }
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
