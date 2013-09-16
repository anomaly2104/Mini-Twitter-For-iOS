//
//  User+Twitter.h
//  Mini Twitter For iOS
//
//  Created by udit.ag on 16/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "User.h"

@interface User (Twitter)
-(NSURL*) profileUrl;
+(User*) userWithTwitterData:(NSDictionary*) userTwitterData;
@end
