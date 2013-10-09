//
//  HomeTimelineTweetCell.m
//  Mini Twitter For iOS
//
//  Created by udit.ag on 04/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "MTTweetCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation MTTweetCell
@synthesize tweetedByName,tweetedByProileImage,tweetMessage,tweetTime;

- (void)assignProfileImageConstraints {
    tweetedByProileImage.translatesAutoresizingMaskIntoConstraints = NO;
    [tweetedByProileImage sizeToFit];
    NSLayoutConstraint *constraintLeft = [NSLayoutConstraint constraintWithItem:tweetedByProileImage
                                                                                    attribute:NSLayoutAttributeLeft
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:self
                                                                                    attribute:NSLayoutAttributeLeft
                                                                                   multiplier:1.0
                                                                                     constant:CELL_MARGIN_LEFT];

    NSLayoutConstraint *constraintTop = [NSLayoutConstraint constraintWithItem:tweetedByProileImage
                                                                                   attribute:NSLayoutAttributeTop
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:self
                                                                                   attribute:NSLayoutAttributeTop
                                                                                  multiplier:1.0
                                                                                    constant:CELL_MARGIN_TOP];
    
    NSDictionary *viewsDictionary = @{ @"profileImage": tweetedByProileImage };
    [self addConstraints:@[ constraintLeft, constraintTop]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[profileImage(50)]"
                                                                 options:NSLayoutFormatAlignAllLeading
                                                                 metrics:nil
                                                                   views:viewsDictionary]];
}

- (void)assignTweetMessageConstraints {
    tweetMessage.translatesAutoresizingMaskIntoConstraints = NO;
    [tweetMessage sizeToFit];
    NSLayoutConstraint *constraintLeft = [NSLayoutConstraint constraintWithItem:tweetMessage
                                                                                    attribute:NSLayoutAttributeLeft
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:tweetedByProileImage
                                                                                    attribute:NSLayoutAttributeRight
                                                                                   multiplier:1.0
                                                                                     constant:CELL_MARGIN_BETWEEN_PROFILE_PIC_AND_RIGHT_CONTENT];
    
    NSLayoutConstraint *constraintRight = [NSLayoutConstraint constraintWithItem:tweetMessage
                                                                      attribute:NSLayoutAttributeRight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1.0
                                                                       constant:-CELL_MARGIN_RIGHT];
    
    NSLayoutConstraint *constraintTop = [NSLayoutConstraint constraintWithItem:tweetMessage
                                                                                   attribute:NSLayoutAttributeTop
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:tweetedByName
                                                                                   attribute:NSLayoutAttributeBottom
                                                                                  multiplier:1.0
                                                                                    constant:CELL_MARGIN_TOP];
    [self addConstraints:@[ constraintLeft, constraintRight, constraintTop]];
}

- (void)assignTweetedByNameConstraints {
    tweetedByName.translatesAutoresizingMaskIntoConstraints = NO;
    [tweetedByName sizeToFit];
    NSLayoutConstraint *constraintLeft = [NSLayoutConstraint constraintWithItem:tweetedByName
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:tweetedByProileImage
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1.0
                                                                       constant:CELL_MARGIN_BETWEEN_PROFILE_PIC_AND_RIGHT_CONTENT];
    
    NSLayoutConstraint *constraintTop = [NSLayoutConstraint constraintWithItem:tweetedByName
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1.0
                                                                      constant:CELL_MARGIN_TOP];
    [self addConstraints:@[ constraintLeft, constraintTop]];

}

- (void)assignTweetTimeConstraints {
    tweetTime.translatesAutoresizingMaskIntoConstraints = NO;
    [tweetTime sizeToFit];
    NSLayoutConstraint *constraintLeft = [NSLayoutConstraint constraintWithItem:tweetTime
                                                                      attribute:NSLayoutAttributeRight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1.0
                                                                       constant:-CELL_MARGIN_RIGHT];
    
    NSLayoutConstraint *constraintTop = [NSLayoutConstraint constraintWithItem:tweetTime
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1.0
                                                                      constant:CELL_MARGIN_TOP];
    [self addConstraints:@[ constraintLeft, constraintTop]];
}

- (void)assignConstraints {
    [self assignProfileImageConstraints];
    [self assignTweetedByNameConstraints];
    [self assignTweetMessageConstraints];
    [self assignTweetTimeConstraints];
}

- (id)init {
    if (self = [super init]) {
        // Initialization code
        tweetMessage = [[UILabel alloc]init];
        tweetMessage.font = [UIFont systemFontOfSize:TWEET_MESSAGE_UILABEL_FONT];
        
        [tweetMessage setNumberOfLines:0];
        [tweetMessage setLineBreakMode:NSLineBreakByWordWrapping];
        
        tweetedByName = [[UILabel alloc]init];
        tweetedByName.font = [UIFont systemFontOfSize:TWEETED_BY_NAME_UILABEL_FONT];
        
        tweetTime = [[UILabel alloc]init];
        tweetTime.font = [UIFont systemFontOfSize:TWEET_TIMESTAMP_UILABEL_FONT];
        
        tweetedByProileImage = [[UIImageView alloc]init];
        
        [self.contentView addSubview:tweetMessage];
        [self.contentView addSubview:tweetedByName];
        [self.contentView addSubview:tweetTime];
        [self.contentView addSubview:tweetedByProileImage];
        [self assignConstraints];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
@end
