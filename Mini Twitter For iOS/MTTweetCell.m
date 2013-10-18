//
//  HomeTimelineTweetCell.m
//  Mini Twitter For iOS
//
//  Created by udit.ag on 04/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "MTTweetCell.h"
#import <QuartzCore/QuartzCore.h>

@interface MTTweetCell ()
@end
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
    [tweetedByName setContentCompressionResistancePriority:500 forAxis:UILayoutConstraintAxisHorizontal];
}

- (void)assignTweetTimeConstraints {
    tweetTime.translatesAutoresizingMaskIntoConstraints = NO;
    [tweetTime sizeToFit];
    NSLayoutConstraint *constraintRight = [NSLayoutConstraint constraintWithItem:tweetTime
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

    NSLayoutConstraint *constraintLeft = [NSLayoutConstraint constraintWithItem:tweetTime
                                                                       attribute:NSLayoutAttributeLeft
                                                                       relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                          toItem:tweetedByName
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1.0
                                                                        constant:CELL_MARGIN_RIGHT];
    [tweetTime setContentCompressionResistancePriority:750 forAxis:UILayoutConstraintAxisHorizontal];
    [self addConstraints:@[ constraintRight, constraintTop, constraintLeft]];
}

- (void)assignConstraints {
    [self assignProfileImageConstraints];
    [self assignTweetedByNameConstraints];
    [self assignTweetMessageConstraints];
    [self assignTweetTimeConstraints];
}

- (void)calculateAndSetFonts {
    tweetMessage.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    [tweetMessage setNumberOfLines:0];
    [tweetMessage setLineBreakMode:NSLineBreakByWordWrapping];
    
    tweetedByName.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    tweetTime.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
}

- (id)init {
    if (self = [super init]) {
        // Initialization code
        tweetMessage = [[UILabel alloc]init];
        tweetedByName = [[UILabel alloc]init];
        tweetTime = [[UILabel alloc]init];
        tweetedByProileImage = [[UIImageView alloc]init];
        
        [self calculateAndSetFonts];
        
        [self.contentView addSubview:tweetedByName];
        [self.contentView addSubview:tweetTime];
        [self.contentView addSubview:tweetMessage];
        [self.contentView addSubview:tweetedByProileImage];
        [self assignConstraints];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
@end
