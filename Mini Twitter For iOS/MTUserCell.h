//
//  UserCell.h
//  Mini Twitter For iOS
//
//  Created by udit.ag on 13/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import <UIKit/UIKit.h>
#define CELL_MARGIN_TOP 10
#define CELL_MARGIN_BOTTOM 10
#define CELL_MARGIN_LEFT 10
#define CELL_MARGIN_RIGHT 10

#define CELL_MARGIN_BETWEEN_PROFILE_PIC_AND_RIGHT_CONTENT 10

#define USER_USERNAME_UILABEL_FONT 14
#define USER_NAME_UILABEL_FONT 15

#define PROFILE_PICTURE_HEIGHT 50
#define PROFILE_PICTURE_WIDTH 50

@interface MTUserCell : UITableViewCell
@property (nonatomic,strong)UILabel *userName;
@property (nonatomic,strong)UILabel *userUserName;
@property (nonatomic,strong)UIImageView *userProileImage;
@end
