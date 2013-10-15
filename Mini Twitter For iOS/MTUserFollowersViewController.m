//
//  UserFollowersViewController.m
//  Mini Twitter For iOS
//
//  Created by udit.ag on 13/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "MTUserFollowersViewController.h"
#import "MTUser+Twitter.h"
#import "MTUserTweetsViewController.h"

@interface MTUserFollowersViewController ()
@property (nonatomic, strong) TweeterFetcher *tweeterFetcher;
@property (strong, nonatomic) NSString* nextCursor;
@property (nonatomic) BOOL isFetching;
@property (nonatomic, strong) NSMutableDictionary *userNameToUIImage;
@property (nonatomic, strong) NSMutableDictionary *userNameToImageLoadOperation;
@property (nonatomic, strong) NSOperationQueue *queue;
@end

@implementation MTUserFollowersViewController
@synthesize nextCursor = _nextCursor;
@synthesize tweeterFetcher = _tweeterFetcher;
@synthesize userNameToUIImage = _userNameToUIImage;
@synthesize userNameToImageLoadOperation = _userNameToImageLoadOperation;
@synthesize queue = _queue;

- (void)setupFetchedResultsController {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MTUser"];
    request.sortDescriptors = @[];
    request.predicate = [NSPredicate predicateWithFormat:@"any followings.userName = %@", self.user.userName];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.user.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

- (void)setUser:(MTUser *)user {
    _user = user;
    [self setupFetchedResultsController];
    self.title = @"Followers";

    self.nextCursor = @"-1";
    self.isFetching = NO;
    [self fetchUserFollowers];
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

- (void)disableRefresh {
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] init];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
}

- (void)enableRefresh {
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)fetchUserFollowers {
    if (self.isFetching) {
        return;
    }
    self.isFetching = YES;
    
    [self disableRefresh];
    if (!self.tweeterFetcher) {
        NSLog(@"Fetcher Nil");
    }
    
    APICompletionBlock refreshUserFollowerBlock = ^(NSDictionary *followData) {
        [self enableRefresh];
        self.nextCursor = [NSString stringWithFormat:@"%@", [followData valueForKey:TWITTER_FOLLOW_CURSOR_NEXT]];
        NSDictionary *userData = [followData objectForKey:TWITTER_FOLLOW_USERS];
        for (NSDictionary* key in userData) {
            [self.user addFollowersObject:[MTUser userWithTwitterData:key inManagedObjectContext:self.user.managedObjectContext]];
        }
        self.isFetching = NO;
    };
    [self.tweeterFetcher fetchFollowersForUser:self.user.userName
                               completionBlock:refreshUserFollowerBlock
                               dispatcherQueue:dispatch_get_main_queue()
                                    nextCursor:self.nextCursor];
}

- (MTUserCell*)setUserData:(MTUser *)user OnCell:(MTUserCell*)cell {
    cell.userName.text = user.name;
    cell.userUserName.text =[ NSString stringWithFormat:@"@%@", user.userName];
    if([self.userNameToUIImage objectForKey:user.userName]){
        cell.userProileImage.image = [self.userNameToUIImage objectForKey:user.userName];
    } else {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            NSData *data = [[NSData alloc] initWithContentsOfURL:user.profileUrl];
            UIImage *tmpImage = [[UIImage alloc] initWithData:data];
            [self.userNameToUIImage setObject:tmpImage forKey:user.userName];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                cell.userProileImage.image = tmpImage;
            }];
        }];
        [self.userNameToImageLoadOperation setObject:operation forKey:user.userName];
        [self.queue addOperation:operation];
    }
    return cell;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Follower User ";
    MTUserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[MTUserCell alloc] init];
    }
    MTUser *userToShow = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell = [self setUserData:userToShow OnCell:cell];
    return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    MTUser *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSOperation *operation = [self.userNameToImageLoadOperation objectForKey:user.userName];
    if (operation) {
        [operation cancel];
        [self.userNameToImageLoadOperation removeObjectForKey:user.userName];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"Follower To User"
                              sender:[self.fetchedResultsController objectAtIndexPath:indexPath]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Follower To User"]) {
        MTUser* user = (MTUser*)sender;
        [(MTUserTweetsViewController *)segue.destinationViewController setUser:user];
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
        [self fetchUserFollowers];
    }
}

@end
