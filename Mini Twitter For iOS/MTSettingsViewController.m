//
//  SettingsViewController.m
//  Mini Twitter For iOS
//
//  Created by udit.ag on 20/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "MTSettingsViewController.h"
#import "TweeterFetcher.h"
@interface MTSettingsViewController ()
@property (nonatomic,strong) TweeterFetcher* tweeterFetcher;
@end

@implementation MTSettingsViewController
@synthesize tweeterFetcher = _tweeterFetcher;

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

#pragma mark - Table view delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"sign out"]) {
        LogoutCompletionBlock logoutCompletionBlock = ^(BOOL success){
            if (success) {
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Log Out"
                                                                  message:@"Logged out successfully."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"Exit"
                                                        otherButtonTitles:nil];
                [message show];

                exit(0);
            }
        };
        [self.tweeterFetcher logoutUserViewController:self CompletionBlock:logoutCompletionBlock dispatcherQueue:dispatch_get_main_queue()];
    }
}
@end
