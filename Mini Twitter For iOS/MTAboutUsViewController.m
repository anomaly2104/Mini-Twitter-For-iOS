//
//  MTAboutUsViewController.m
//  Mini Twitter For iOS
//
//  Created by udit.ag on 10/10/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "MTAboutUsViewController.h"

@interface MTAboutUsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *twitterBird;

@end

@implementation MTAboutUsViewController
@synthesize twitterBird = _twitterBird;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.twitterBird.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *widthEqualsHeight = [NSLayoutConstraint constraintWithItem:self.twitterBird
                                                                         attribute:NSLayoutAttributeWidth
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.twitterBird
                                                                         attribute:NSLayoutAttributeHeight
                                                                        multiplier:1.0
                                                                          constant:0.0];
//    widthEqualsHeight.priority = 750;
    [self.twitterBird addConstraint:widthEqualsHeight];
}


@end
