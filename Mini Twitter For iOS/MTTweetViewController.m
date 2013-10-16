//
//  TweetViewController.m
//  Mini Twitter For iOS
//
//  Created by udit.ag on 05/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "MTTweetViewController.h"
#import "MTUser+Twitter.h"

@interface MTTweetViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *tweetedByProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *tweetedByName;
@property (weak, nonatomic) IBOutlet UITextView *tweetMessage;
@property (weak, nonatomic) IBOutlet UILabel *tweetTime;
@property (weak, nonatomic) IBOutlet UILabel *tweetedByUserName;
@property (nonatomic, strong) Utils* utils;
@end

@implementation MTTweetViewController
@synthesize tweet = _tweet;
@synthesize tweetTime = _tweetTime;
@synthesize tweetedByName = _tweetedByName;
@synthesize tweetedByUserName = _tweetedByUserName;
@synthesize tweetedByProfileImage = _tweetedByProfileImage;
@synthesize tweetMessage = _tweetMessage;
@synthesize utils = _utils;

- (Utils*)utils {
    if(!_utils) _utils = [[Utils alloc] init];
    return _utils;
}

- (NSAttributedString *)attributedMessageFromMessage:(NSString *)tweetMessage {
    NSArray* messageWords = [tweetMessage componentsSeparatedByString: @" "];
    NSMutableAttributedString *attributedTweetMessage = [[NSMutableAttributedString alloc] initWithString:@""];
    
    for (NSString *word in messageWords) {
        NSDictionary * attributes;
        if([word characterAtIndex:0] == '@'){
            attributes = [NSDictionary dictionaryWithObject:[UIColor redColor] forKey:NSForegroundColorAttributeName];
        } else if([word characterAtIndex:0] == '#'){
            attributes = [NSDictionary dictionaryWithObject:[UIColor colorWithRed:0.180392
                                                                            green:0.545098
                                                                             blue:0.341176
                                                                            alpha:1.0]
                                                     forKey:NSForegroundColorAttributeName];
        } else {
            attributes = [NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
        }
        NSAttributedString * subString = [[NSAttributedString alloc]
                                          initWithString:[NSString stringWithFormat:@"%@ ",word]
                                          attributes:attributes];
        [attributedTweetMessage appendAttributedString:subString];
    }
    return attributedTweetMessage;
}

- (void)setFonts{
    self.tweetedByName.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.tweetedByUserName.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.tweetMessage.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.tweetTime.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

- (void)viewDidLoad {
    self.tweetedByName.text = self.tweet.tweetedBy.name;
    self.tweetedByUserName.text = [NSString stringWithFormat:@"@%@", self.tweet.tweetedBy.userName];
    self.tweetMessage.attributedText = [self attributedMessageFromMessage:self.tweet.tweetMessage];
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
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Tweet To User"]) {
        [(MTUserTweetsViewController *)segue.destinationViewController setUser:self.tweet.tweetedBy];
    }
}

@end
