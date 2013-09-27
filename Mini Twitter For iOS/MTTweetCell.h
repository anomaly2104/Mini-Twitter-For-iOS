//
//  HomeTimelineTweetCell.h
//  Mini Twitter For iOS
//
//  Created by udit.ag on 04/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CELL_MARGIN_TOP 10
#define CELL_MARGIN_BOTTOM 10
#define CELL_MARGIN_LEFT 10
#define CELL_MARGIN_RIGHT 10

#define CELL_MARGIN_BETWEEN_PROFILE_PIC_AND_RIGHT_CONTENT 10

#define TWEET_MESSAGE_UILABEL_FONT 12
#define TWEETED_BY_NAME_UILABEL_FONT 14
#define TWEET_TIMESTAMP_UILABEL_FONT 12

#define PROFILE_PICTURE_HEIGHT 50
#define PROFILE_PICTURE_WIDTH 50

@interface MTTweetCell : UITableViewCell
@property (nonatomic,strong)UILabel *tweetedByName;
@property (nonatomic,strong)UILabel *tweetTime;
@property (nonatomic,strong)UILabel *tweetMessage;
@property (nonatomic,strong)UIImageView *tweetedByProileImage;
@end
