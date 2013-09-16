//
//  Tweet+Twitter.h
//  Mini Twitter For iOS
//
//  Created by udit.ag on 16/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "Tweet.h"

@interface Tweet (Twitter)
+(Tweet*) tweetWithTwitterData:(NSDictionary*) tweetTwitterData;
@end
