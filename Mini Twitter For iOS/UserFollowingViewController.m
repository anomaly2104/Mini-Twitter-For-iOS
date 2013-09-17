//
//  UserFollowingViewController.m
//  Mini Twitter For iOS
//
//  Created by udit.ag on 13/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "UserFollowingViewController.h"
#import "User+Twitter.h"

@interface UserFollowingViewController ()
@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (nonatomic, strong) TweeterFetcher *tweeterFetcher;
@end

@implementation UserFollowingViewController

@synthesize tweeterFetcher = _tweeterFetcher;
@synthesize refreshButton = _refreshButton;


- (TweeterFetcher *) tweeterFetcher {
    if(!_tweeterFetcher) _tweeterFetcher = [[TweeterFetcher alloc] init];
    return _tweeterFetcher;
}

-(void) setupFetchedResultsController{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                                     ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)
                                                        ]];
    
    request.predicate = [NSPredicate predicateWithFormat:@"any followers.userName = %@", self.user.userName];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.user.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

-(void)setUser:(User *)user{
    _user = user;
    [self setupFetchedResultsController];
    [self refreshFollowing:self.refreshButton];
    self.title = @"Following";
}

-(void) disableRefresh{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] init];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
}

-(void) enableRefresh: (id) sender{
    self.navigationItem.rightBarButtonItem = sender;
}


- (IBAction)refreshFollowing:(id)sender {
    [self disableRefresh];
    if(!self.tweeterFetcher){
        NSLog(@"Fetcher Nil");
    }
    
    APICompletionBlock refreshUserFollowingBlock = ^(NSDictionary * followData){
        [self enableRefresh:sender];
        NSMutableArray *usersToShow = [[NSMutableArray alloc] init];
        NSDictionary *userData = [followData objectForKey:TWITTER_FOLLOW_USERS];
        for (NSDictionary* key in userData) {
            [self.user addFollowingsObject:[User userWithTwitterData:key inManagedObjectContext:self.user.managedObjectContext]];
    //        User *user = [User userWithTwitterData:key];
  //          [usersToShow addObject:user];
        }
//        self.usersToShow = usersToShow;
    };
    [self.tweeterFetcher fetchFollowingForUser:self.user.userName completionBlock:refreshUserFollowingBlock dispatcherQueue:dispatch_get_main_queue()];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refreshFollowing:self.refreshButton];
}


-(UserCell*) setUserData:(User *) user OnCell:(UserCell*) cell {
    
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
    static NSString *CellIdentifier = @"Following User ";
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UserCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier ];
    }
    
    User *userToShow = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell = [self setUserData:userToShow OnCell:cell];
    
    return cell;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Cell selected %ld, %ld", (long)indexPath.section, (long)indexPath.row);
    [self performSegueWithIdentifier:@"Following To User" sender:[self.fetchedResultsController objectAtIndexPath:indexPath]];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if( [segue.identifier isEqualToString:@"Following To User"]){
        User* user = (User*)sender;
        [segue.destinationViewController setUser:user];
    }
}

@end
