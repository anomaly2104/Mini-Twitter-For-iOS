//
//  LoginViewController.m
//  Mini Twitter For iOS
//
//  Created by udit.ag on 11/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "MTLoginViewController.h"
#import "MTRootViewController.h"
#import "MTUser+Twitter.h"
@interface MTLoginViewController ()
@property (nonatomic, strong) TweeterFetcher *tweeterFetcher;
@property (nonatomic, strong) MTUser* currentUser;
@end

@implementation MTLoginViewController
@synthesize tweeterFetcher = _tweeterFetcher;
@synthesize currentUser = _currentUser;

- (MTUser *)currentUser {
    if(!_currentUser) _currentUser = [[MTUser alloc] init];
    return _currentUser;
}

- (TweeterFetcher *)tweeterFetcher {
    if(!_tweeterFetcher) _tweeterFetcher = [[TweeterFetcher alloc] init];
    return _tweeterFetcher;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)getCurrentLoggedInUser {
    
    NSURL* spinnerImageURL = [NSURL  fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"spinner" ofType:@"gif"]];
    UIImageView* spinnerImage = [AnimatedGif getAnimationForGifAtUrl:spinnerImageURL];
    CGFloat spinnerHeight = 100.0;
    CGFloat spinnerWidth = 100.0;
    spinnerImage.frame = CGRectMake(self.view.frame.size.width/2-spinnerWidth/2.0,150,spinnerWidth,spinnerHeight);
    [self.view addSubview:spinnerImage];
    
    LoginCompletionBlock loginCompletionBlock = ^(BOOL success) {
        NSString* userInfo= [[NSUserDefaults standardUserDefaults] objectForKey:TWITTER_DEFALT_ACCESS_TOKEN];
        NSString* currentUserName = [Utils extractValueForKey:@"screen_name" fromHTTPBody:userInfo];
        
        APICompletionBlock fetchUserDetails = ^(NSDictionary* userDetails) {
            self.currentUser = [MTUser userWithTwitterData:userDetails
                                    inManagedObjectContext:self.twitterDatabase.managedObjectContext];
            [self performSegueWithIdentifier:@"Show Root VIew Controller" sender:self];
        };
        [self.tweeterFetcher fetchDetailsForUser:currentUserName completionBlock:fetchUserDetails dispatcherQueue:dispatch_get_main_queue()];
    };
    [self.tweeterFetcher loginUserViewController:self CompletionBlock:loginCompletionBlock dispatcherQueue:dispatch_get_main_queue()];
}


- (void)useDocument {
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.twitterDatabase.fileURL path]]) {
        // does not exist on disk, so create it
        [self.twitterDatabase saveToURL:self.twitterDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            [self getCurrentLoggedInUser];
            
        }];
    } else if (self.twitterDatabase.documentState == UIDocumentStateClosed) {
        // exists on disk, but we need to open it
        [self.twitterDatabase openWithCompletionHandler:^(BOOL success) {
            [self getCurrentLoggedInUser];
        }];
    } else if (self.twitterDatabase.documentState == UIDocumentStateNormal) {
        // already open and ready to use
        [self getCurrentLoggedInUser];
    }
   
}

- (void)setTwitterDatabase:(UIManagedDocument *)twitterDatabase {
    if (_twitterDatabase != twitterDatabase) {
        _twitterDatabase = twitterDatabase;
        [self useDocument];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.twitterDatabase) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"Mini Twitter Database"];
        self.twitterDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Show Root VIew Controller"]) {
        [segue.destinationViewController setCurrentUser:self.currentUser];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
