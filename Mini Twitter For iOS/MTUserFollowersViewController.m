//
//  UserFollowersViewController.m
//  Mini Twitter For iOS
//
//  Created by udit.ag on 13/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "MTUserFollowersViewController.h"
#import "MTUser+Twitter.h"

@interface MTUserFollowersViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (nonatomic, strong) TweeterFetcher *tweeterFetcher;
@property (strong, nonatomic) NSString* nextCursor;
@property (nonatomic) BOOL isFetching;

@end

@implementation MTUserFollowersViewController

@synthesize nextCursor = _nextCursor;
@synthesize tweeterFetcher = _tweeterFetcher;
@synthesize refreshButton = _refreshButton;

-(void) setupFetchedResultsController{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    request.sortDescriptors = @[];//[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name"
                                    //                                                 ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)
                                      //                  ]];
    
    request.predicate = [NSPredicate predicateWithFormat:@"any followings.userName = %@", self.user.userName];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.user.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

-(void)setUser:(MTUser *)user{
    _user = user;
    [self setupFetchedResultsController];
    self.title = @"Followers";

    self.nextCursor = @"-1";
    self.isFetching = NO;
    [self fetchUserFollowers];
}

- (TweeterFetcher *) tweeterFetcher {
    if(!_tweeterFetcher) _tweeterFetcher = [[TweeterFetcher alloc] init];
    return _tweeterFetcher;
}

-(void) disableRefresh{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] init];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
}

-(void) enableRefresh{
    self.navigationItem.rightBarButtonItem = nil;
}

-(void) fetchUserFollowers{
    if(self.isFetching){
        return;
    }
    self.isFetching = YES;
    
    [self disableRefresh];
    if(!self.tweeterFetcher){
        NSLog(@"Fetcher Nil");
    }
    
    APICompletionBlock refreshUserFollowerBlock = ^(NSDictionary * followData){
        [self enableRefresh];
        self.nextCursor = [NSString stringWithFormat:@"%@", [followData valueForKey:TWITTER_FOLLOW_CURSOR_NEXT] ];

//        NSMutableArray *usersToShow = [[NSMutableArray alloc] init];
        NSDictionary *userData = [followData objectForKey:TWITTER_FOLLOW_USERS];
        for (NSDictionary* key in userData) {
            [self.user addFollowersObject:[MTUser userWithTwitterData:key inManagedObjectContext:self.user.managedObjectContext]];
        }
        self.isFetching = NO;

    };
    [self.tweeterFetcher fetchFollowersForUser:self.user.userName completionBlock:refreshUserFollowerBlock dispatcherQueue:dispatch_get_main_queue() nextCursor:self.nextCursor];
}

- (IBAction)refreshFollower:(id)sender {
    
    
}

-(MTUserCell*) setUserData:(MTUser *) user OnCell:(MTUserCell*) cell {
    
    cell.userName.text = user.name;
    cell.userUserName.text =[ NSString stringWithFormat:@"@%@",user.userName ];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("Twitter Downloader", NULL);
    dispatch_async(downloadQueue, ^{
        
        NSData *data = [[NSData alloc] initWithContentsOfURL:user.profileUrl];
        UIImage *tmpImage = [[UIImage alloc] initWithData:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.userProileImage.image = tmpImage;
        });
    });
    return cell;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Follower User ";
    MTUserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[MTUserCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier ];
    }
    
    MTUser *userToShow = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell = [self setUserData:userToShow OnCell:cell];
    
    return cell;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Cell selected %ld, %ld", (long)indexPath.section, (long)indexPath.row);
    [self performSegueWithIdentifier:@"Follower To User" sender:[self.fetchedResultsController objectAtIndexPath:indexPath]];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if( [segue.identifier isEqualToString:@"Follower To User"]){
        MTUser* user = (MTUser*)sender;
        [segue.destinationViewController setUser:user];
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
        [self fetchUserFollowers];
    }
}

@end
