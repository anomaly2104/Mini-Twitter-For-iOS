//
//  HomeTimelineTweetCell.m
//  Mini Twitter For iOS
//
//  Created by udit.ag on 04/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "HomeTimelineTweetCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation HomeTimelineTweetCell
@synthesize tweetedByName,tweetedByProileImage,tweetMessage,tweetTime;

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x;
    CGRect frame;
    
    frame= CGRectMake(boundsX+CELL_MARGIN_LEFT ,CELL_MARGIN_TOP, PROFILE_PICTURE_WIDTH, PROFILE_PICTURE_HEIGHT);
    tweetedByProileImage.frame = frame;

    frame= CGRectMake(boundsX+CELL_MARGIN_LEFT + PROFILE_PICTURE_WIDTH + CELL_MARGIN_BETWEEN_PROFILE_PIC_AND_RIGHT_CONTENT ,5, 150, 20);
    tweetedByName.frame = frame;

    frame = CGRectMake(boundsX+220 ,5, 100, 20);
    tweetTime.frame = frame;

    frame = CGRectMake(boundsX+CELL_MARGIN_LEFT + PROFILE_PICTURE_WIDTH + CELL_MARGIN_BETWEEN_PROFILE_PIC_AND_RIGHT_CONTENT ,30, 250, 15);
    tweetMessage.frame = frame;

    [tweetMessage sizeToFit];
    
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
        tweetMessage = [[UILabel alloc]init];
        tweetMessage.textAlignment = UITextAlignmentLeft;
        tweetMessage.font = [UIFont systemFontOfSize:TWEET_MESSAGE_UILABEL_FONT];

        [tweetMessage setNumberOfLines:0];
        [tweetMessage setLineBreakMode:UILineBreakModeWordWrap];
        
        tweetedByName = [[UILabel alloc]init];
        tweetedByName.textAlignment = UITextAlignmentLeft;
        tweetedByName.font = [UIFont systemFontOfSize:TWEETED_BY_NAME_UILABEL_FONT];
        
        tweetTime = [[UILabel alloc]init];
        tweetTime.textAlignment = UITextAlignmentRight;
        tweetTime.font = [UIFont systemFontOfSize:TWEET_TIMESTAMP_UILABEL_FONT];
        
        tweetedByProileImage = [[UIImageView alloc]init];

        [self.contentView addSubview:tweetMessage];
        [self.contentView addSubview:tweetedByName];
        [self.contentView addSubview:tweetTime];
        [self.contentView addSubview:tweetedByProileImage];
        
    }
    return self;
}


/*- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}
*/
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
