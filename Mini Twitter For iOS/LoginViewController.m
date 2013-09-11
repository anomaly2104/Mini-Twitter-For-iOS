//
//  LoginViewController.m
//  Mini Twitter For iOS
//
//  Created by udit.ag on 11/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "LoginViewController.h"
#import "MiniTwitterRootViewController.h"

@interface LoginViewController ()
@property (nonatomic, strong) TweeterFetcher *tweeterFetcher;
@property (nonatomic, strong) User* currentUser;
@end

@implementation LoginViewController
@synthesize tweeterFetcher = _tweeterFetcher;
@synthesize currentUser = _currentUser;

-(User*) currentUser{
    if(!_currentUser) _currentUser = [[User alloc] init];
    return _currentUser;
}
- (TweeterFetcher *) tweeterFetcher {
    if(!_tweeterFetcher) _tweeterFetcher = [[TweeterFetcher alloc] init];
    return _tweeterFetcher;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSURL* spinnerImageURL = [NSURL  fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"spinner" ofType:@"gif"]];
    
    UIImageView* spinnerImage = [AnimatedGif getAnimationForGifAtUrl:spinnerImageURL];
    
    CGFloat spinnerHeight = 100.0;
    CGFloat spinnerWidth = 100.0;
    spinnerImage.frame = CGRectMake(self.view.frame.size.width/2-spinnerWidth/2.0,150,spinnerWidth,spinnerHeight);
    [self.view addSubview:spinnerImage];
    
    FetchCurrentUserCompletionBlock fetchCurrentUser = ^(ACAccount* userData){
        self.currentUser.userName = userData.username;
        self.currentUser.userId = [[userData valueForKey:@"properties"] valueForKey:@"user_id"];
        [self performSegueWithIdentifier:@"Show Root VIew Controller" sender:self];
    };
    
    [self.tweeterFetcher getCurrentLoggedInUserCompletionBlock:fetchCurrentUser
                                               dispatcherQueue:dispatch_get_main_queue()];
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"Show Root VIew Controller"]){
        [segue.destinationViewController setCurrentUser:self.currentUser];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
