//
//  minitwitterViewController.m
//  Mini Twitter For iOS
//
//  Created by udit.ag on 04/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "minitwitterViewController.h"
#import "TweeterFetcher.h"

@interface minitwitterViewController ()
@property (nonatomic,strong) TweeterFetcher *tweeterFetcher;
@end

@implementation minitwitterViewController
@synthesize tweeterFetcher = _tweeterFetcher;

- (TweeterFetcher *) tweeterFetcher {
    if(!_tweeterFetcher) _tweeterFetcher = [[TweeterFetcher alloc] init];
    return _tweeterFetcher;
}
- (IBAction)refreshUserTweets:(id)sender {
    NSLog(@"Refreshing user tweets");
    if(!self.tweeterFetcher){
        NSLog(@"Fetcher Nil");
    }
    
    APICompletionBlock refreshUserTweetsBlock = ^(NSDictionary * timeLineData){
        
    };
    [self.tweeterFetcher fetchTimelineForUser:@"MastChamp"
                              completionBlock:refreshUserTweetsBlock
                              dispatcherQueue:dispatch_get_main_queue()];
    NSLog(@"Refresh Done");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
