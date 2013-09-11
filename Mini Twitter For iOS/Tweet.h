//
//  Tweet.h
//  Mini Twitter For iOS
//
//  Created by udit.ag on 09/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Tweet : NSObject

@property (nonatomic,strong) NSString *tweetMessage;
@property (nonatomic,strong) NSDate *tweetTimestamp;
@property (nonatomic,strong) NSString *tweetId;
@property (nonatomic, strong) User *tweetedBy;

@end
