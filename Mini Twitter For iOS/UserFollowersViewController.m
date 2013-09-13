//
//  UserFollowersViewController.m
//  Mini Twitter For iOS
//
//  Created by udit.ag on 13/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "UserFollowersViewController.h"

@interface UserFollowersViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (nonatomic, strong) TweeterFetcher *tweeterFetcher;
@property (nonatomic,strong) NSArray* usersToShow;
@end

@implementation UserFollowersViewController

@synthesize tweeterFetcher = _tweeterFetcher;
@synthesize usersToShow = _usersToShow;
@synthesize refreshButton = _refreshButton;


-(void) setUsersToShow:(NSArray *)usersToShow{
    if( _usersToShow != usersToShow ) {
        _usersToShow = usersToShow;
        [self.tableView reloadData];
    }
}
- (TweeterFetcher *) tweeterFetcher {
    if(!_tweeterFetcher) _tweeterFetcher = [[TweeterFetcher alloc] init];
    return _tweeterFetcher;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
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
            
            User *user = [[User alloc] init];
            
            user.name = [key objectForKey:TWITTER_USER_NAME];
            user.userName = [key objectForKey:TWITTER_USER_USERNAME];
            user.profileUrl = [NSURL URLWithString:[key objectForKey:TWITTER_USER_PROFILE_IMAGE_URL]];
            user.userId = [key objectForKey:TWITTER_USER_ID_STR];
            user.following = [key objectForKey:TWITTER_USER_FOLLOWING];
            /*            NSLog(@"Following values: %@", following);
             if([following isEqualToString:@"false"]){
             user.following = [NSNumber numberWithInt:0];
             } else if([following isEqualToString:@"true"]){
             user.following = [NSNumber numberWithInt:1];
             } else{
             //some error: must be true or false
             }
             */
            [usersToShow addObject:user];
        }
        self.usersToShow = usersToShow;
    };
    [self.tweeterFetcher fetchFollowersForUser:self.user.userName completionBlock:refreshUserFollowingBlock dispatcherQueue:dispatch_get_main_queue()];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refreshFollowing:self.refreshButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.usersToShow count];
}

-(UserCell*) setUserData:(User *) user OnCell:(UserCell*) cell {
    
    cell.userName.text = user.name;
    cell.userUserName.text = user.userName;
    
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
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UserCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier ];
    }
    
    User *userToShow = [self.usersToShow objectAtIndex:indexPath.row];
    
    cell = [self setUserData:userToShow OnCell:cell];
    
    return cell;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Cell selected %ld, %ld", (long)indexPath.section, (long)indexPath.row);
    [self performSegueWithIdentifier:@"Follower To User" sender:[self.usersToShow objectAtIndex:indexPath.row]];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if( [segue.identifier isEqualToString:@"Follower To User"]){
        User* user = (User*)sender;
        [segue.destinationViewController setUser:user];
    }
}


@end
