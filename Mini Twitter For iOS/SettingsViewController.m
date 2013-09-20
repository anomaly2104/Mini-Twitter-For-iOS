//
//  SettingsViewController.m
//  Mini Twitter For iOS
//
//  Created by udit.ag on 20/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "SettingsViewController.h"
#import "TweeterFetcher.h"
@interface SettingsViewController ()
@property (nonatomic,strong) TweeterFetcher* tweeterFetcher;
@end

@implementation SettingsViewController

@synthesize tweeterFetcher = _tweeterFetcher;
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"sign out"]){
        LogoutCompletionBlock logoutCompletionBlock = ^(BOOL success){
            
        };
        [self.tweeterFetcher logoutUserViewController:self CompletionBlock:logoutCompletionBlock dispatcherQueue:dispatch_get_main_queue()];
        exit(0);
    }
}
@end
