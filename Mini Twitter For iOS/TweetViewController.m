//
//  TweetViewController.m
//  Mini Twitter For iOS
//
//  Created by udit.ag on 05/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "TweetViewController.h"

@interface TweetViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *tweetedByProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *tweetedByName;
@property (weak, nonatomic) IBOutlet UILabel *tweetMessage;
@property (weak, nonatomic) IBOutlet UILabel *tweetTime;
@property (weak, nonatomic) IBOutlet UILabel *tweetedByUserName;
@property (nonatomic, strong) Utils* utils;
@end

@implementation TweetViewController
@synthesize tweet = _tweet;
@synthesize tweetTime = _tweetTime;
@synthesize tweetedByName = _tweetedByName;
@synthesize tweetedByUserName = _tweetedByUserName;
@synthesize tweetedByProfileImage = _tweetedByProfileImage;
@synthesize tweetMessage = _tweetMessage;
@synthesize utils = _utils;

-(Utils*)utils{
    if(!_utils) _utils = [[Utils alloc] init];
    return _utils;
}

-(void) viewDidLoad{
    self.tweetedByName.text = self.tweet.tweetedBy.name;
    self.tweetedByUserName.text = [NSString stringWithFormat:@"@%@", self.tweet.tweetedBy.userName];
    self.tweetMessage.text = self.tweet.tweetMessage;
    NSString* tweetTimeToShow = [self.utils convertTweetDateToStringTimeStamp: self.tweet.tweetTimestamp];
    self.tweetTime.text =  tweetTimeToShow;
    dispatch_queue_t downloadQueue = dispatch_queue_create("Twitter Downloader", NULL);
    dispatch_async(downloadQueue, ^{
        
        NSData *data = [[NSData alloc] initWithContentsOfURL:self.tweet.tweetedBy.profileUrl];
        UIImage *tmpImage = [[UIImage alloc] initWithData:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tweetedByProfileImage.image = tmpImage;
        });
    });

//    self.tweetedByProfileImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.tweetedByProfileImage]];
}
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"Tweet To User"]){
        [segue.destinationViewController setUser:self.tweet.tweetedBy];
    }
}

@end
