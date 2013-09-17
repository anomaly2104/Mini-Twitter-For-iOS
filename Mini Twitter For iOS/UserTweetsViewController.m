//
//  UserTweetsViewController.m
//  Mini Twitter For iOS
//
//  Created by udit.ag on 04/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "UserTweetsViewController.h"
#import "Tweet+Twitter.h"
#import "User+Twitter.h"

@interface UserTweetsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *userProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userUserName;
@property (weak, nonatomic) IBOutlet UILabel *tweetsCount;
@property (weak, nonatomic) IBOutlet UILabel *followingCount;
@property (weak, nonatomic) IBOutlet UILabel *followersCount;

@property (nonatomic, strong) TweeterFetcher *tweeterFetcher;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@end

@implementation UserTweetsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

//@synthesize tweetsToShow = _tweetsToShow;
@synthesize tweeterFetcher = _tweeterFetcher;
@synthesize refreshButton = _refreshButton;
@synthesize user = _user;

/*-(void) setTweetsToShow:(NSArray *)tweetsToShow{
    if( _tweetsToShow != tweetsToShow ) {
        _tweetsToShow = tweetsToShow;
        [self.tableView reloadData];
    }
}*/
- (TweeterFetcher *) tweeterFetcher {
    if(!_tweeterFetcher) _tweeterFetcher = [[TweeterFetcher alloc] init];
    return _tweeterFetcher;
}

- (IBAction)refreshUserTimeline:(id)sender {
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] init];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    if(!self.tweeterFetcher){
        NSLog(@"Fetcher Nil");
    }
    
    APICompletionBlock refreshUserTweetsBlock = ^(NSDictionary * timeLineData){
        self.navigationItem.rightBarButtonItem = sender;
        
//        NSMutableArray *tweetsToShow = [[NSMutableArray alloc] init];
        for (NSDictionary* key in timeLineData) {
    //        Tweet *tweet = [Tweet tweetWithTwitterData:key];
            [Tweet tweetWithTwitterData:key inManagedObjectContext:self.user.managedObjectContext];
//            [tweetsToShow addObject:tweet];
        }
  //      self.tweetsToShow = tweetsToShow;
    };
    [self.tweeterFetcher fetchTimelineForUser:self.user.userName completionBlock:refreshUserTweetsBlock dispatcherQueue:dispatch_get_main_queue()];
}

-(void) setUserProfileData{
        self.userName.text = self.user.name;
        self.userUserName.text = [NSString stringWithFormat:@"@%@",self.user.userName ];
        self.tweetsCount.text = [NSString stringWithFormat:@"%@",self.user.numberTweets];
        self.followersCount.text = [NSString stringWithFormat:@"%@",self.user.numberFollowers];
        self.followingCount.text = [NSString stringWithFormat:@"%@",self.user.numberFollowing];
        
        dispatch_queue_t downloadQueue = dispatch_queue_create("Twitter Downloader", NULL);
        dispatch_async(downloadQueue, ^{
            
            NSData *data = [[NSData alloc] initWithContentsOfURL:self.user.profileUrl];
            UIImage *tmpImage = [[UIImage alloc] initWithData:data];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.userProfileImage.image = tmpImage;
            });
        });
}

-(void) setupFetchedResultsController{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"tweetTimestamp"
                                                                                     ascending:NO
                                                        ]];
    
        request.predicate = [NSPredicate predicateWithFormat:@"tweetedBy.userName = %@", self.user.userName];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.user.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

-(void)setUser:(User *)user{
    _user = user;
    [self setupFetchedResultsController];
    [self refreshUserTimeline:self.refreshButton];
    self.title = self.user.name;
    [self setUserProfileData];
}

-(TweetCell*) setTweetData:(Tweet *) tweet OnCell:(TweetCell*) cell {
    
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
    static NSString *CellIdentifier = @"User Tweet";
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[TweetCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier ];
    }
    
    Tweet *tweetToShow = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell = [self setTweetData:tweetToShow OnCell:cell];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Tweet *tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    id tweetMessage = tweet.tweetMessage;
    CGSize constraint = CGSizeMake(320 - (CELL_MARGIN_LEFT + CELL_MARGIN_RIGHT), 20000.0f);
    
    CGSize size = [tweetMessage sizeWithFont:[UIFont systemFontOfSize:TWEET_MESSAGE_UILABEL_FONT] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
    return (55+size.height);
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Cell selected %ld, %ld", (long)indexPath.section, (long)indexPath.row);
    [self performSegueWithIdentifier:@"User Tweet To Show Tweet" sender:[self.fetchedResultsController objectAtIndexPath:indexPath]];
}

- (SEL) findAppropriateFunctionToInvokeOnBasisOfCurrentState1 {
    
    return @selector(doSomething);
}
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if( [segue.identifier isEqualToString:@"User Tweet To Show Tweet"]){
        Tweet* tweet = (Tweet*)sender;
        [segue.destinationViewController setTweet:tweet];
    } else if( [segue.identifier isEqualToString:@"User To Following"]){
        [segue.destinationViewController setUser:self.user];
    } else if( [segue.identifier isEqualToString:@"User To Followers"]){
        [segue.destinationViewController setUser:self.user];
    }
}

@end
