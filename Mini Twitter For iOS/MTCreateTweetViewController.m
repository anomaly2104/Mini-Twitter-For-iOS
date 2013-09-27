//
//  CreateTweetViewController.m
//  Mini Twitter For iOS
//
//  Created by udit.ag on 12/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "MTCreateTweetViewController.h"
#import "MTTweet+Twitter.h"
#import "MTRootViewController.h"

@interface MTCreateTweetViewController ()

@property (nonatomic, strong) TweeterFetcher *tweeterFetcher;
@property (strong, nonatomic) IBOutlet UITextView *tweetMessageTextBox;
@property (strong, nonatomic) UIBarButtonItem *tweetTextLengthBarItem;
@property (strong, nonatomic) UILabel *tweetTextLength;
- (IBAction)postTweet:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *tweetButton;

@end

@implementation MTCreateTweetViewController

@synthesize tweetMessageTextBox = _tweetMessageTextBox;
@synthesize tweetTextLength = _tweetTextLength;
@synthesize tweetTextLengthBarItem = _tweetTextLengthBarItem;
@synthesize tweetButton = _tweetButton;
@synthesize tweeterFetcher = _tweeterFetcher;

- (TweeterFetcher *) tweeterFetcher {
    if(!_tweeterFetcher) _tweeterFetcher = [[TweeterFetcher alloc] init];
    return _tweeterFetcher;
}

-(UILabel*) tweetTextLength{
    if(!_tweetTextLength){
        _tweetTextLength = [[UILabel alloc] initWithFrame:CGRectMake(0,0,30,16)];
        _tweetTextLength.opaque = NO;
        _tweetTextLength.font = [UIFont systemFontOfSize:14];
        _tweetTextLength.textAlignment = UITextAlignmentCenter;
        _tweetTextLength.textColor = [UIColor whiteColor];
        _tweetTextLength.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
        _tweetTextLength.text = @"120";
        
    }
    return _tweetTextLength;
}
-(UIBarButtonItem*) tweetTextLengthBarItem{
    if(!_tweetTextLengthBarItem){
        _tweetTextLengthBarItem = [[UIBarButtonItem alloc] initWithCustomView:self.tweetTextLength];
    }
    return _tweetTextLengthBarItem;
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.tweetMessageTextBox becomeFirstResponder];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tweetMessageTextBox.delegate = self;
    [self setInitialRightNavigationBar];
}

-(void)setInitialRightNavigationBar {
    
    if(self.tweetButton){
        self.navigationItem.rightBarButtonItems = @[self.tweetButton,self.tweetTextLengthBarItem];
    }
    else{
        self.navigationItem.rightBarButtonItems = @[self.tweetTextLengthBarItem];
    }
    
    
}

-(void) enableTweetPosting {
    [self setInitialRightNavigationBar];
    [self.tweetMessageTextBox setEditable:YES];
    [self.tweetMessageTextBox becomeFirstResponder];
}

-(void) disableTweetPosting {
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] init];
    [spinner startAnimating];
    MTPadder* padding = [[MTPadder alloc] initWithWidth:10];
    UIBarButtonItem* spinnerView = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    UIBarButtonItem* paddingItem = [[UIBarButtonItem alloc] initWithCustomView:padding];
    
    self.navigationItem.rightBarButtonItems = @[paddingItem,spinnerView];
    
    [self.tweetMessageTextBox setEditable:NO];
}

-(void) tweetSuccess{
    [self.tweetMessageTextBox setText:@""];
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Tweet Successfull"
                                                      message:@"Tweet created successfully."
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
    [self enableTweetPosting];
}
- (IBAction)postTweet:(id)sender {
    [self disableTweetPosting];
    
    APICompletionBlock postTweetCompletionBlock = ^(NSDictionary * responseData){
        MTRootViewController* tabBarController = (MTRootViewController*)self.tabBarController;
        
        [MTTweet tweetWithTwitterData:responseData inManagedObjectContext:tabBarController.currentUser.managedObjectContext];
        [self tweetSuccess];
    };
    NSString* tweet = self.tweetMessageTextBox.text;
    [self.tweeterFetcher postTweet:tweet completionBlock:postTweetCompletionBlock dispatcherQueue:dispatch_get_main_queue()];
}

-(void) textViewDidChange:(UITextView *)textView{
    NSString* tweetText = textView.text;
    NSUInteger currentTweetLength = tweetText.length;

    if(currentTweetLength == 0){
        [self.tweetButton setEnabled:NO];
        [self.tweetTextLength setText:@"120"];
    }
    else{
        [self.tweetButton setEnabled:YES];
        if(currentTweetLength > 120){
            [self.tweetTextLength setText:@"0"];
            self.tweetMessageTextBox.text = [self.tweetMessageTextBox.text substringToIndex:120];
        } else {
            [self.tweetTextLength setText:[NSString stringWithFormat:@"%d",120-currentTweetLength]];
        }
    }
}

- (IBAction)cancelTweet:(id)sender {
    [self.tweetMessageTextBox resignFirstResponder];
    self.tabBarController.selectedIndex=0;
}
@end
