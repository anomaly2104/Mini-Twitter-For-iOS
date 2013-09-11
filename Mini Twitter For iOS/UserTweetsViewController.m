//
//  UserTweetsViewController.m
//  Mini Twitter For iOS
//
//  Created by udit.ag on 04/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "UserTweetsViewController.h"
#import "TweeterFetcher.h"
#import "HomeTimelineTweetCell.h"
#import "Utils.h"

@interface UserTweetsViewController ()
@property (nonatomic, strong) TweeterFetcher *tweeterFetcher;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@end

@implementation UserTweetsViewController
@synthesize user = _user;

-(User*) user{
    if(!_user) _user = [[User alloc] init];
    return _user;
}

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
//@synthesize userName = _userName;

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

- (IBAction)refreshUserTweets:(id)sender {
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] init];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    if(!self.tweeterFetcher){
        NSLog(@"Fetcher Nil");
    }
    
    APICompletionBlock refreshhomeTimelineTweetsBlock = ^(NSDictionary * timeLineData){
        self.navigationItem.rightBarButtonItem = sender;
        
        NSMutableArray *homeTimelineTweets = [[NSMutableArray alloc] init];
        for (id key in timeLineData) {
            [homeTimelineTweets addObject:key];
        }
        self.homeTimelineTweets = homeTimelineTweets;
    };
    NSLog(@"Fetching Tweets of User: %@", self.user.userName);
    [self.tweeterFetcher fetchTimelineForUser:self.user.userName completionBlock:refreshhomeTimelineTweetsBlock dispatcherQueue:dispatch_get_main_queue()];
    
}

- (UIViewController *) init{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.userName = @"MastChamp";
    [self refreshUserTweets:self.refreshButton];
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

-(HomeTimelineTweetCell*) setTweetData:(NSDictionary *) tweet OnCell:(HomeTimelineTweetCell*) cell {
    id name = [[tweet objectForKey:TWITTER_TWEET_USER] objectForKey:TWITTER_USER_NAME];
    id timeStamp = [tweet objectForKey:TWITTER_TWEET_TIMESTAMP];
    id profileImageUrl = [[tweet objectForKey:TWITTER_TWEET_USER] objectForKey:TWITTER_USER_PROFILE_IMAGE_URL];
    id tweetMessage = [tweet objectForKey:TWITTER_TWEET_MESSAGE];
    
    cell.tweetedByName.text = name;
    cell.tweetTime.text = [Utils convertTweetTimeToTimeAgo:timeStamp];
    
    cell.tweetMessage.text = tweetMessage;
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("Twitter Downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSURL *url = [NSURL URLWithString: profileImageUrl];
        NSData *data = [[NSData alloc] initWithContentsOfURL:url];
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
    
    NSDictionary *homeTimelineTweets = [self.homeTimelineTweets objectAtIndex:indexPath.row];
    
    cell = [self setTweetData:homeTimelineTweets OnCell:cell];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *homeTimelineTweet = [self.homeTimelineTweets objectAtIndex:indexPath.row];
    
    id tweetMessage = [homeTimelineTweet objectForKey:TWITTER_TWEET_MESSAGE];
    CGSize constraint = CGSizeMake(320 - (CELL_MARGIN_LEFT + CELL_MARGIN_RIGHT), 20000.0f);
    
    CGSize size = [tweetMessage sizeWithFont:[UIFont systemFontOfSize:TWEET_MESSAGE_UILABEL_FONT] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
    return (55+size.height);
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Cell selected %ld, %ld", (long)indexPath.section, (long)indexPath.row);
 //   [self performSegueWithIdentifier:@"Home Timeline Tweet To Show Tweet" sender:self];
}

/*- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if( [segue.identifier isEqualToString:@"Home Timeline Tweet To Show Tweet"]){
        
    }
}*/

@end
