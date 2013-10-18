//
//  UserTweetsViewController.m
//  Mini Twitter For iOS
//
//  Created by udit.ag on 04/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "MTUserTweetsViewController.h"
#import "MTTweet+Twitter.h"
#import "MTUser+Twitter.h"
#import <QuartzCore/QuartzCore.h>

@interface MTUserTweetsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *userProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userUserName;
@property (weak, nonatomic) IBOutlet UILabel *tweetsCount;
@property (weak, nonatomic) IBOutlet UILabel *followingCount;
@property (weak, nonatomic) IBOutlet UILabel *followersCount;
@property (nonatomic, strong) TweeterFetcher *tweeterFetcher;
@property (strong, nonatomic) NSString *maxId;
@property (strong, nonatomic) NSString *sinceId;
@property (nonatomic) BOOL isFetching;
@property (nonatomic, strong) NSMutableDictionary *userNameToUIImage;
@property (nonatomic, strong) NSMutableDictionary *userNameToImageLoadOperation;
@property (nonatomic, strong) NSOperationQueue *queue;
@end

@implementation MTUserTweetsViewController
- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
@synthesize maxId = _maxId;
@synthesize sinceId = _sinceId;
@synthesize tweeterFetcher = _tweeterFetcher;
@synthesize user = _user;
@synthesize userNameToUIImage = _userNameToUIImage;
@synthesize userNameToImageLoadOperation = _userNameToImageLoadOperation;
@synthesize queue = _queue;

- (TweeterFetcher *)tweeterFetcher {
    if(!_tweeterFetcher) _tweeterFetcher = [[TweeterFetcher alloc] init];
    return _tweeterFetcher;
}

- (void)setUser:(MTUser *)user {
    _user = user;
    [self setupFetchedResultsController];
    self.title = self.user.name;
    self.isFetching = NO;
    self.maxId = @"-1";
    self.sinceId = @"-1";
    [self fetchUserTweets];
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

- (void)preferredContentSizeChanged:(NSNotification *)notification {
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to get new Tweets"];
    [refresh addTarget:self
                action:@selector(fetchNewUserTweets:)
      forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    [self.tableView reloadData];
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
        [MTTweet tweetWithTwitterData:key inManagedObjectContext:self.user.managedObjectContext];
    }
    
}

- (void)fetchUserTweets {
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
    
    APICompletionBlock refreshUserTweetsBlock = ^(NSDictionary * timeLineData) {
        self.navigationItem.rightBarButtonItem = nil;
        [self insertTwitterTweetDataIntoCoreData:timeLineData];
        self.isFetching = NO;
    };
    [self.tweeterFetcher fetchTimelineForUser:self.user.userName
                              completionBlock:refreshUserTweetsBlock
                              dispatcherQueue:dispatch_get_main_queue()
                                        maxId: self.maxId];
    
}
- (void)fetchNewUserTweets:(UIRefreshControl*)refresh {
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    
    APICompletionBlock refreshUserTweetsBlock = ^(NSDictionary * timeLineData) {
        [self insertTwitterTweetDataIntoCoreData:timeLineData];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",
                                 [formatter stringFromDate:[NSDate date]]];
        refresh.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
        [refresh endRefreshing];
    };
    [self.tweeterFetcher fetchTimelineForUser:self.user.userName
                              completionBlock:refreshUserTweetsBlock
                              dispatcherQueue:dispatch_get_main_queue()
                                      sinceId: self.sinceId];
}

- (void)setUserProfileData {
    
    APICompletionBlock getUserDetailsBlock = ^(NSDictionary * UserData) {
        MTUser* user = [MTUser userWithTwitterData:UserData inManagedObjectContext:self.user.managedObjectContext];
        
        self.userName.text = user.name;
//        self.userName.accessibilityLabel = [Utils appendString:[Utils appendString:@"You are viewing " withString:user.name] withString:@" Profile"];
        self.userUserName.text = [NSString stringWithFormat:@"@%@", user.userName ];
        self.tweetsCount.text = [NSString stringWithFormat:@"%@", user.numberTweets];
        self.tweetsCount.textColor = [UIColor blueColor];
        self.followersCount.text = [NSString stringWithFormat:@"%@", user.numberFollowers];
        self.followersCount.textColor = [UIColor blueColor];

        self.followingCount.text = [NSString stringWithFormat:@"%@", user.numberFollowing];
        self.followingCount.textColor = [UIColor blueColor];
        dispatch_queue_t downloadQueue = dispatch_queue_create("Twitter Downloader", NULL);
        dispatch_async(downloadQueue, ^{
            
            NSData *data = [[NSData alloc] initWithContentsOfURL:self.user.profileUrl];
            UIImage *tmpImage = [[UIImage alloc] initWithData:data];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.userProfileImage.image = tmpImage;
            });
        });
    };
    [self.tweeterFetcher fetchDetailsForUser:self.user.userName
                             completionBlock:getUserDetailsBlock
                             dispatcherQueue:dispatch_get_main_queue()];
}

- (void)setupFetchedResultsController {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MTTweet"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"tweetTimestamp"
                                                                                     ascending:NO]];
    
        request.predicate = [NSPredicate predicateWithFormat:@"tweetedBy.userName = %@", self.user.userName];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.user.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
    [self setUserProfileData];
}

- (MTTweetCell*)setTweetData:(MTTweet *)tweet onCell:(MTTweetCell*)cell {

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
    static NSString *cellIdentifier = @"User Tweet";
    MTTweetCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[MTTweetCell alloc] init];
    }
    MTTweet *tweetToShow = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell = [self setTweetData:tweetToShow onCell:cell];
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
    [self performSegueWithIdentifier:@"User Tweet To Show Tweet"
                              sender:[self.fetchedResultsController objectAtIndexPath:indexPath]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ( [segue.identifier isEqualToString:@"User Tweet To Show Tweet"]) {
        MTTweet* tweet = (MTTweet*)sender;
        [(MTTweetViewController *)segue.destinationViewController setTweet:tweet];
    } else if ( [segue.identifier isEqualToString:@"User To Following"]) {
        [(MTUserFollowingViewController *)segue.destinationViewController setUser:self.user];
    } else if ( [segue.identifier isEqualToString:@"User To Followers"]) {
        [(MTUserFollowersViewController *)segue.destinationViewController setUser:self.user];
    }
}

- (IBAction)handleTapOnFollower:(id)sender {
    self.followersCount.backgroundColor = [UIColor lightGrayColor];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, .05 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.followersCount.backgroundColor = [UIColor whiteColor];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        MTUserFollowersViewController *nextViewController = [storyboard instantiateViewControllerWithIdentifier:@"followersViewController"];
        nextViewController.user = self.user;
        [UIView  beginAnimations:nil context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.75];
        [self.navigationController pushViewController:nextViewController animated:NO];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
        [UIView commitAnimations];
    });
}

- (IBAction)handleTapOnFollowing:(id)sender {
    self.followingCount.backgroundColor = [UIColor lightGrayColor];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, .05 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.followingCount.backgroundColor = [UIColor whiteColor];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        MTUserFollowingViewController *nextViewController = [storyboard instantiateViewControllerWithIdentifier:@"followingViewController"];
        nextViewController.user = self.user;
        
        [UIView  beginAnimations:nil context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.75];
        [self.navigationController pushViewController:nextViewController animated:NO];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
        [UIView commitAnimations];
    });
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    float reload_distance = -400;
    if (y > h + reload_distance) {
        [self fetchUserTweets];
    }
}
@end
