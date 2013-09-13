////
//  UserCell.m
//  Mini Twitter For iOS
//
//  Created by udit.ag on 13/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "UserCell.h"

@implementation UserCell
@synthesize userName,userUserName,userProileImage;

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x;
    CGRect frame;
    
    frame= CGRectMake(boundsX+CELL_MARGIN_LEFT ,CELL_MARGIN_TOP, PROFILE_PICTURE_WIDTH, PROFILE_PICTURE_HEIGHT);
    userProileImage.frame = frame;
    
    frame= CGRectMake(boundsX+CELL_MARGIN_LEFT + PROFILE_PICTURE_WIDTH + CELL_MARGIN_BETWEEN_PROFILE_PIC_AND_RIGHT_CONTENT ,5, 150, 20);
    userName.frame = frame;
        
    frame = CGRectMake(boundsX+CELL_MARGIN_LEFT + PROFILE_PICTURE_WIDTH + CELL_MARGIN_BETWEEN_PROFILE_PIC_AND_RIGHT_CONTENT ,30, 250, 15);
    userUserName.frame = frame;
    
    [userUserName sizeToFit];
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
        userUserName = [[UILabel alloc]init];
        userUserName.textAlignment = UITextAlignmentLeft;
        userUserName.font = [UIFont systemFontOfSize:USER_USERNAME_UILABEL_FONT];
        
        userName = [[UILabel alloc]init];
        userName.textAlignment = UITextAlignmentLeft;
        userName.font = [UIFont systemFontOfSize:USER_NAME_UILABEL_FONT];
        
        userProileImage = [[UIImageView alloc]init];
        
        [self.contentView addSubview:userName];
        [self.contentView addSubview:userUserName];
        [self.contentView addSubview:userProileImage];
        
    }
    return self;
}

/*
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}*/

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
