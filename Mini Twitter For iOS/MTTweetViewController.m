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

NSString * const hashTagKey = @"HashTag";
NSString * const userNameKey = @"UserName";
NSString * const normalKey = @"NormalKey";
NSString * const tweetWordType = @"TweetWordType";

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
            attributes = @{NSForegroundColorAttributeName:[UIColor redColor],
                           tweetWordType: userNameKey,
                           userNameKey:[word substringFromIndex:1]};
            
        } else if([word characterAtIndex:0] == '#'){
            attributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:0.180392
                                                                          green:0.545098
                                                                           blue:0.341176
                                                                          alpha:1.0],
                           tweetWordType: hashTagKey,
                           hashTagKey:[word substringFromIndex:1]};

        } else {
            attributes = @{NSForegroundColorAttributeName:[UIColor blackColor], tweetWordType: normalKey};
        }
        NSAttributedString * subString = [[NSAttributedString alloc]
                                          initWithString:[NSString stringWithFormat:@"%@ ",word]
                                          attributes:attributes];
        [attributedTweetMessage appendAttributedString:subString];
    }
    return attributedTweetMessage;
}

- (void)openViewControllerForUserName:(NSString *)userName {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    MTUserTweetsViewController *nextViewController = [storyboard instantiateViewControllerWithIdentifier:@"MTUserTweetsViewController"];
    NSDictionary *userData = @{@"screen_name": userName};
    MTUser *newUser = [MTUser userWithTwitterData:userData inManagedObjectContext:self.tweet.managedObjectContext];
    nextViewController.user = newUser;
    
    [UIView  beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:1.0];
    [self.navigationController pushViewController:nextViewController animated:NO];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.navigationController.view cache:NO];
    [UIView commitAnimations];
}

- (IBAction)tweetMessageTapped:(UITapGestureRecognizer *)recognizer {
        UITextView *textView = (UITextView *)recognizer.view;
        
        NSLayoutManager *layoutManager = textView.layoutManager;
        CGPoint location = [recognizer locationInView:textView];
        
        NSUInteger characterIndex;
        characterIndex = [layoutManager characterIndexForPoint:location
                                               inTextContainer:textView.textContainer
                      fractionOfDistanceBetweenInsertionPoints:NULL];
        
        if (characterIndex < textView.textStorage.length) {
            
            NSRange range;
            id wordType = [textView.attributedText attribute:tweetWordType
                                                  atIndex:characterIndex
                                           effectiveRange:&range];
            
            if([wordType isEqualToString:userNameKey]){
                NSString *userName = [textView.attributedText attribute:userNameKey
                                                                atIndex:characterIndex
                                                         effectiveRange:&range];
                [self openViewControllerForUserName:userName];
            } else if([wordType isEqualToString:hashTagKey]){
                // TODO: Segue to hashtag controller once it is in place.
            }
        }
}

- (void)setFonts {
    self.tweetedByName.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.tweetedByUserName.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.tweetMessage.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.tweetTime.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
}

- (void)setTweetValues {
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

- (void)viewDidLoad {
    [self setTweetValues];
    [self setFonts];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Tweet To User"]) {
        [(MTUserTweetsViewController *)segue.destinationViewController setUser:self.tweet.tweetedBy];
    }
}

@end
