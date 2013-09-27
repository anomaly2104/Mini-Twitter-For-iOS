//
//  HomeTimelineViewController.m
//  Mini Twitter For iOS
//
//  Created by udit.ag on 04/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "MTHomeTimelineViewController.h"
#import "MTUser+Twitter.h"

@interface MTHomeTimelineViewController ()
//@property (nonatomic, strong) NSArray* tweetsToShow;
@property (nonatomic, strong) TweeterFetcher *tweeterFetcher;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (strong, nonatomic) NSString *maxId;
@property (strong, nonatomic) NSString *sinceId;
@property (nonatomic) BOOL isFetching;
@end

@implementation MTHomeTimelineViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
@synthesize maxId = _maxId;
@synthesize sinceId = _sinceId;
@synthesize currentUser = _currentUser;
@synthesize tweeterFetcher = _tweeterFetcher;
@synthesize refreshButton = _refreshButton;

- (TweeterFetcher *) tweeterFetcher {
    if(!_tweeterFetcher) _tweeterFetcher = [[TweeterFetcher alloc] init];
    return _tweeterFetcher;
}
-(void)setCurrentUser:(MTUser *)currentUser{
    _currentUser = currentUser;
    [self setupFetchedResultsController];
    self.maxId = @"-1";
    self.sinceId = @"-1";
    self.isFetching = NO;
    [self fetchHomeTimeline];
}

-(void) viewDidLoad{
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to get new Tweets"];
    [refresh addTarget:self action:@selector(fetchNewHomeTimeLineTweets:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
}

-(void) changeIdsForTweetId:(NSString*) tweetId{
    if(  [self.maxId compare:tweetId] == NSOrderedDescending || [self.maxId isEqualToString:@"-1"] ){
        self.maxId = tweetId;
    }
    if(  [self.sinceId compare:tweetId] == NSOrderedAscending || [self.sinceId isEqualToString:@"-1"] ){
        self.sinceId = tweetId;
    }
}


-(void) insertTwitterTweetDataIntoCoreData : (NSDictionary *)timeLineData{
    for (NSDictionary* key in timeLineData) {
        
        NSString* tweetId = [key valueForKey:TWITTER_TWEET_ID_STR];
        [self changeIdsForTweetId:tweetId];
        
        [MTHomeTimeLine insertFeedWithFeedData:key inHomeTimeLineUserName:self.currentUser.userName inManagedObjectContext:self.currentUser.managedObjectContext];
    }

}

-(void) fetchHomeTimeline {
    if(self.isFetching){
        return;
    }
    self.isFetching = YES;
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] init];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    if(!self.tweeterFetcher){
        NSLog(@"Fetcher Nil");
    }
    
    APICompletionBlock fetchHomeTimelineTweetsBlock = ^(NSDictionary * timeLineData){
        self.navigationItem.rightBarButtonItem = nil;
        [self insertTwitterTweetDataIntoCoreData:timeLineData];
        self.isFetching = NO;
        
    };
    [self.tweeterFetcher fetchHomeTimelineForCurrentUserCompletionBlock:fetchHomeTimelineTweetsBlock
                                                        dispatcherQueue:dispatch_get_main_queue() maxId:self.maxId];
    
}

-(void) fetchNewHomeTimeLineTweets : (UIRefreshControl*) refresh {
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];

    APICompletionBlock fetchHomeTimelineTweetsBlock = ^(NSDictionary * timeLineData){
        [self insertTwitterTweetDataIntoCoreData:timeLineData];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",
                                 [formatter stringFromDate:[NSDate date]]];
        refresh.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
        [refresh endRefreshing];

        
    };
    [self.tweeterFetcher fetchHomeTimelineForCurrentUserCompletionBlock:fetchHomeTimelineTweetsBlock
                                                        dispatcherQueue:dispatch_get_main_queue() sinceId:self.sinceId];
}

- (IBAction)refreshHomeTimeline:(id)sender {
}

-(void) setupFetchedResultsController{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MTTweet"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"tweetTimestamp"
                                                                                     ascending:NO
                                                                                      ]];
    request.predicate = [NSPredicate predicateWithFormat:@"any inHomeTimeLine.userName = %@",self.currentUser.userName];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.currentUser.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

-(MTTweetCell*) setTweetData:(MTTweet *) tweet OnCell:(MTTweetCell*) cell {
    
    [self changeIdsForTweetId:tweet.tweetId];

    cell.tweetedByName.text = tweet.tweetedBy.name;
    cell.tweetTime.text = [Utils convertTweetNSDateToTimeAgo:tweet.tweetTimestamp];
    
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
    static NSString *CellIdentifier = @"Home Timeline Tweet";
    MTTweetCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[MTTweetCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier ];
    }
    
    MTTweet *tweetToShow = [self.fetchedResultsController objectAtIndexPath:indexPath];

    cell = [self setTweetData:tweetToShow OnCell:cell];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MTTweet *tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];

    id tweetMessage = tweet.tweetMessage;
    CGSize constraint = CGSizeMake(320 - (CELL_MARGIN_LEFT + CELL_MARGIN_RIGHT), 20000.0f);
    
    CGSize size = [tweetMessage sizeWithFont:[UIFont systemFontOfSize:TWEET_MESSAGE_UILABEL_FONT] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
    return (55+size.height);
}
-(void) viewWillAppear:(BOOL)animated{
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Cell selected %ld, %ld", (long)indexPath.section, (long)indexPath.row);
    [self performSegueWithIdentifier:@"Home Timeline Tweet To Show Tweet" sender:[self.fetchedResultsController objectAtIndexPath:indexPath]];
}

- (SEL) findAppropriateFunctionToInvokeOnBasisOfCurrentState1 {
    
    return @selector(doSomething);
}
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if( [segue.identifier isEqualToString:@"Home Timeline Tweet To Show Tweet"]){
        MTTweet* tweet = (MTTweet*)sender;
        [segue.destinationViewController setTweet:tweet];
    }
}

-(void) scrollViewDidScroll:(UIScrollView *)aScrollView{
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    float reload_distance = -400;
    if(y > h + reload_distance) {
        [self fetchHomeTimeline];
    }
}

@end
