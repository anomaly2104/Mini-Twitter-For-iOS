//
//  Padder.m
//  Mini Twitter For iOS
//
//  Created by udit.ag on 12/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "Padder.h"

@implementation Padder

- (id)initWithWidth:(CGFloat)width
{
    CGRect frame = CGRectMake(0, 0, width, 10);
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    self.opaque = NO;
    self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

@end
