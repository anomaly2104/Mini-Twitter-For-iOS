//
//  LoginViewController.h
//  Mini Twitter For iOS
//
//  Created by udit.ag on 11/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/ACAccountType.h>
#import <Accounts/ACAccount.h>
#import "TweeterFetcher.h"
#import "AnimatedGif.h"
#import "User.h"

@interface LoginViewController : UIViewController
@property (nonatomic,strong) UIManagedDocument* twitterDatabase;
@end
