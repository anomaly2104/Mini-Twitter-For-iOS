//
//  User.h
//  Mini Twitter For iOS
//
//  Created by udit.ag on 09/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSURL *profileUrl;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSNumber *numberTweets;
@property (nonatomic, strong) NSNumber *numberFollowers;
@property (nonatomic, strong) NSNumber *numberFollowing;
@end
