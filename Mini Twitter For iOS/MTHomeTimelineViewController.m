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
@property (nonatomic, strong) TweeterFetcher *tweeterFetcher;
@property (nonatomic, strong) NSString *maxId;
@property (nonatomic, strong) NSString *sinceId;
@property (nonatomic) BOOL isFetching;
@property (nonatomic, strong) NSMutableDictionary *userNameToUIImage;
@property (nonatomic, strong) NSMutableDictionary *userNameToImageLoadOperation;
@property (nonatomic, strong) NSOperationQueue *queue;
@end

@implementation MTHomeTimelineViewController
@synthesize maxId = _maxId;
@synthesize sinceId = _sinceId;
@synthesize currentUser = _currentUser;
@synthesize tweeterFetcher = _tweeterFetcher;
@synthesize userNameToUIImage = _userNameToUIImage;
@synthesize userNameToImageLoadOperation = _userNameToImageLoadOperation;
@synthesize queue = _queue;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (TweeterFetcher *)tweeterFetcher {
    if (!_tweeterFetcher) _tweeterFetcher = [[TweeterFetcher alloc] init];
    return _tweeterFetcher;
}

- (NSOperationQueue *)queue {
    if (!_queue) _queue = [[NSOperationQueue alloc] init];
    
    return _queue;
}

- (NSMutableDictionary *)userNameToUIImage {
    if (!_userNameToUIImage) _userNameToUIImage = [[NSMutableDictionary alloc] init];
    return _userNameToUIImage;
}

- (NSMutableDictionary *)userNameToImageLoadOperation {
    if (!_userNameToImageLoadOperation) {
        _userNameToImageLoadOperation = [[NSMutableDictionary alloc] init];
    }
    return _userNameToImageLoadOperation;
}

- (void)setCurrentUser:(MTUser *)currentUser {
    _currentUser = currentUser;
    [self setupFetchedResultsController];
    self.maxId = @"-1";
    self.sinceId = @"-1";
    self.isFetching = NO;
    [self fetchHomeTimeline];
}

- (void)preferredContentSizeChanged:(NSNotification *)notification {
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to get new Tweets"];
    [refresh addTarget:self
                action:@selector(fetchNewHomeTimeLineTweets:)
      forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];

}

- (void)changeIdsForTweetId:(NSString*)tweetId {
    if ([self.maxId compare:tweetId] == NSOrderedDescending || [self.maxId isEqualToString:@"-1"]) {
        self.maxId = tweetId;
    }
    if ([self.sinceId compare:tweetId] == NSOrderedAscending || [self.sinceId isEqualToString:@"-1"]) {
        self.sinceId = tweetId;
    }
}

- (void)insertTwitterTweetDataIntoCoreData:(NSDictionary *)timeLineData {
    for (NSDictionary* key in timeLineData) {
        NSString* tweetId = [key valueForKey:TWITTER_TWEET_ID_STR];
        [self changeIdsForTweetId:tweetId];
        [MTHomeTimeLine insertFeedWithFeedData:key
                        inHomeTimeLineUserName:self.currentUser.userName
                        inManagedObjectContext:self.currentUser.managedObjectContext];
    }
}

- (void)fetchHomeTimeline {
    if (self.isFetching) {
        return;
    }
    self.isFetching = YES;
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] init];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    if (!self.tweeterFetcher) {
        NSLog(@"Fetcher Nil");
    }
    
    APICompletionBlock fetchHomeTimelineTweetsBlock = ^(NSDictionary * timeLineData) {
        self.navigationItem.rightBarButtonItem = nil;
        [self insertTwitterTweetDataIntoCoreData:timeLineData];
        self.isFetching = NO;
    };
    [self.tweeterFetcher fetchHomeTimelineForCurrentUserCompletionBlock:fetchHomeTimelineTweetsBlock
                                                        dispatcherQueue:dispatch_get_main_queue()
                                                                  maxId:self.maxId];
}

- (void)fetchNewHomeTimeLineTweets:(UIRefreshControl*)refresh {
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    APICompletionBlock fetchHomeTimelineTweetsBlock = ^(NSDictionary * timeLineData) {
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

- (void)setupFetchedResultsController {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MTTweet"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"tweetTimestamp"
                                                                                     ascending:NO
                                                                                      ]];
    request.predicate = [NSPredicate predicateWithFormat:@"any inHomeTimeLine.userName = %@", self.currentUser.userName];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.currentUser.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

- (MTTweetCell*)setTweetData:(MTTweet *)tweet OnCell:(MTTweetCell*)cell {
    [self changeIdsForTweetId:tweet.tweetId];
    cell.tweetedByName.text = tweet.tweetedBy.name;
    cell.tweetTime.text = [Utils convertTweetNSDateToTimeAgo:tweet.tweetTimestamp];
    cell.tweetMessage.text = tweet.tweetMessage;
    
    if([self.userNameToUIImage objectForKey:tweet.tweetedBy.userName]){
        cell.tweetedByProileImage.image = [self.userNameToUIImage objectForKey:tweet.tweetedBy.userName];
    } else {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            NSData *data = [[NSData alloc] initWithContentsOfURL:tweet.tweetedBy.profileUrl];
            UIImage *tmpImage = [[UIImage alloc] initWithData:data];
            [self.userNameToUIImage setObject:tmpImage forKey:tweet.tweetedBy.userName];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                cell.tweetedByProileImage.image = tmpImage;
            }];
        }];
        [self.userNameToImageLoadOperation setObject:operation forKey:tweet.tweetedBy.userName];
        [self.queue addOperation:operation];
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Home Timeline Tweet";
    MTTweetCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[MTTweetCell alloc] init];
//        cell = [[MTTweetCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];
    }
    MTTweet *tweetToShow = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell = [self setTweetData:tweetToShow OnCell:cell];
    return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    MTTweet *tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSOperation *operation = [self.userNameToImageLoadOperation objectForKey:tweet.tweetedBy.userName];
    if (operation) {
        [operation cancel];
        [self.userNameToImageLoadOperation removeObjectForKey:tweet.tweetedBy.userName];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MTTweet *tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
    id tweetMessage = tweet.tweetMessage;
    CGSize constraint = CGSizeMake(self.view.bounds.size.width - (CELL_MARGIN_LEFT + CELL_MARGIN_BETWEEN_PROFILE_PIC_AND_RIGHT_CONTENT + PROFILE_PICTURE_WIDTH + CELL_MARGIN_RIGHT), 20000.0f);
    
    CGSize tweetMessageSize = [tweetMessage sizeWithFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    
    CGSize tweetedBySize = [tweet.tweetedBy.name sizeWithFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    
    return (CELL_MARGIN_TOP*2 + CELL_MARGIN_BOTTOM + tweetedBySize.height + tweetMessageSize.height);
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"Home Timeline Tweet To Show Tweet" sender:[self.fetchedResultsController objectAtIndexPath:indexPath]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if( [segue.identifier isEqualToString:@"Home Timeline Tweet To Show Tweet"]){
        MTTweet* tweet = (MTTweet*)sender;
        [(MTTweetViewController *)segue.destinationViewController setTweet:tweet];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    float reload_distance = -400;
    if (y > h+reload_distance) {
        [self fetchHomeTimeline];
    }
}
@end
