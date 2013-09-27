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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ( cell.tag == 1 ) {
        LogoutCompletionBlock logoutCompletionBlock = ^(BOOL success){
            if (success) {
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Log Out"
                                                                  message:@"Logged out successfully."
                                                                 delegate:self
                                                        cancelButtonTitle:@"Exit"
                                                        otherButtonTitles:nil];
                [message show];
                
            }
        };
        [self.tweeterFetcher logoutUserViewController:self CompletionBlock:logoutCompletionBlock dispatcherQueue:dispatch_get_main_queue()];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    exit(0);
}
@end
