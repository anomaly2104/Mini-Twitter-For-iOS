//
//  HomeTimelineViewController.m
//  Mini Twitter For iOS
//
//  Created by udit.ag on 04/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "HomeTimelineViewController.h"

@interface HomeTimelineViewController ()
@property (nonatomic, strong) TweeterFetcher *tweeterFetcher;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@end

@implementation HomeTimelineViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

@synthesize homeTimelineTweets = _homeTimelineTweets;
@synthesize tweeterFetcher = _tweeterFetcher;
@synthesize refreshButton = _refreshButton;

-(void) setHomeTimelineTweets:(NSArray *)homeTimelineTweets {
    if( _homeTimelineTweets != homeTimelineTweets ) {
        _homeTimelineTweets = homeTimelineTweets;
        [self.tableView reloadData];
    }
}
- (TweeterFetcher *) tweeterFetcher {
    if(!_tweeterFetcher) _tweeterFetcher = [[TweeterFetcher alloc] init];
    return _tweeterFetcher;
}

- (IBAction)refreshHomeTimeline:(id)sender {
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] init];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    if(!self.tweeterFetcher){
        NSLog(@"Fetcher Nil");
    }
    
    APICompletionBlock refreshhomeTimelineTweetsBlock = ^(NSDictionary * timeLineData){
        self.navigationItem.rightBarButtonItem = sender;
        
        NSMutableArray *homeTimelineTweets = [[NSMutableArray alloc] init];
        for (NSDictionary* key in timeLineData) {
            Tweet *tweet = [[Tweet alloc] init];
            tweet.tweetTimestamp = [key objectForKey:TWITTER_TWEET_TIMESTAMP];
            tweet.tweetMessage = [key objectForKey:TWITTER_TWEET_MESSAGE];
            tweet.tweetId = [key objectForKey:TWITTER_TWEET_ID];
            
            tweet.tweetedBy = [[User alloc] init];
            tweet.tweetedBy.name = [[key objectForKey:TWITTER_TWEET_USER] objectForKey:TWITTER_USER_NAME];
            tweet.tweetedBy.profileUrl = [NSURL URLWithString: [[key objectForKey:TWITTER_TWEET_USER] objectForKey:TWITTER_USER_PROFILE_IMAGE_URL]];
            tweet.tweetedBy.userId = [[key objectForKey:TWITTER_TWEET_USER] objectForKey:TWITTER_USER_ID];
            tweet.tweetedBy.userName = [[key objectForKey:TWITTER_TWEET_USER] objectForKey:TWITTER_USER_USERNAME];
            
            [homeTimelineTweets addObject:tweet];
        }
        self.homeTimelineTweets = homeTimelineTweets;
    };
    [self.tweeterFetcher fetchHomeTimelineForCurrentUserCompletionBlock:refreshhomeTimelineTweetsBlock
                                                        dispatcherQueue:dispatch_get_main_queue()];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refreshHomeTimeline:self.refreshButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.homeTimelineTweets count];
}

-(HomeTimelineTweetCell*) setTweetData:(Tweet *) tweet OnCell:(HomeTimelineTweetCell*) cell {

    cell.tweetedByName.text = tweet.tweetedBy.name;
    cell.tweetTime.text = [Utils convertTweetTimeToTimeAgo:tweet.tweetTimestamp];
    
    cell.tweetMessage.text = tweet.tweetMessage;
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("Twitter Downloader", NULL);
    dispatch_async(downloadQueue, ^{

        NSData *data = [[NSData alloc] initWithContentsOfURL:tweet.tweetedBy.profileUrl];
        UIImage *tmpImage = [[UIImage alloc] initWithData:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.tweetedByProileImage.image = tmpImage;
        });
    });
    return cell;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Home Timeline Tweet Cell";
    HomeTimelineTweetCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[HomeTimelineTweetCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier ];
    }
    
    Tweet *homeTimelineTweets = [self.homeTimelineTweets objectAtIndex:indexPath.row];

    cell = [self setTweetData:homeTimelineTweets OnCell:cell];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Tweet *homeTimelineTweet = [self.homeTimelineTweets objectAtIndex:indexPath.row];

    id tweetMessage = homeTimelineTweet.tweetMessage;
    CGSize constraint = CGSizeMake(320 - (CELL_MARGIN_LEFT + CELL_MARGIN_RIGHT), 20000.0f);
    
    CGSize size = [tweetMessage sizeWithFont:[UIFont systemFontOfSize:TWEET_MESSAGE_UILABEL_FONT] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
    return (55+size.height);
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Cell selected %ld, %ld", (long)indexPath.section, (long)indexPath.row);
    [self performSegueWithIdentifier:@"Home Timeline Tweet To Show Tweet" sender:self];
}

- (SEL) findAppropriateFunctionToInvokeOnBasisOfCurrentState1 {
    
    return @selector(doSomething);
}
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if( [segue.identifier isEqualToString:@"Home Timeline Tweet To Show Tweet"]){
        Tweet* tweet = [[Tweet alloc] init];        
        [segue.destinationViewController setTweet:tweet];
    }
}

@end
