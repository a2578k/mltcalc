//
//  TitleBarClass.m
//  LinkList
//
//  Created by a2578k on 2013/09/21.
//  Copyright (c) 2013年 sogawa seiji. All rights reserved.
//

#import "TitleBarClass.h"
#import <QuartzCore/QuartzCore.h>

@implementation TitleBarClass
@synthesize delegate;
@synthesize left_button;
@synthesize right_button;
@synthesize middle_button;
@synthesize title_label;
- (id)initWithFrame:(CGRect)frame
{
    float iOSVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    float height=40.0;
    if (iOSVersion>=7.0) {
        height=45.0;
    }
    frame.size.height=height;
    self = [super initWithFrame:frame];
    if (self) {
        self.frame=frame;
        self.backgroundColor=[UIColor whiteColor];
        self.layer.borderWidth = 1.0f;    //ボーダーの幅
        title_label = [[UILabel alloc]
                                  initWithFrame: CGRectMake(65.0, frame.size.height-27.0, 105.0, 21.0)];
        title_label.backgroundColor = [UIColor clearColor];
        title_label.text=@"";
        title_label.adjustsFontSizeToFitWidth=YES;
        [self addSubview:title_label];
        left_button=nil;
        right_button=nil;
    }
    return self;
}
-(id)init {
    self = [super init];
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */
// 左ボタン生成
-(void)setLeftButton:(NSString*)title_name position:(int)left_pos {
    if (left_button!=nil) {
        [left_button removeFromSuperview];
        left_button=nil;
    }
    CGRect frame=self.frame;
    UIImage *image = [UIImage imageNamed:@"rect2985.png"];
    left_button=[UIButton buttonWithType:UIButtonTypeCustom];
    [left_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [left_button.titleLabel setFont:[UIFont systemFontOfSize:16]];
    CGSize size;
    //float iOSVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    //if (iOSVersion>=7.0) {
        size=[title_name sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0f]}];
    //}
    [left_button setBackgroundImage:image forState:UIControlStateNormal];
    left_button.frame=CGRectMake(left_pos, frame.size.height-23.0, size.width+30, 21.0);
    [left_button setTitle:title_name forState:UIControlStateNormal];
    [left_button addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:left_button];
}
// 右ボタン生成
-(void)setRightButton:(NSString*)title_name position:(int)right_pos {
    if (right_button!=nil) {
        [right_button removeFromSuperview];
        right_button=nil;
    }
    CGRect frame=self.frame;
    UIImage *image = [UIImage imageNamed:@"rect2985.png"];
    right_button=[UIButton buttonWithType:UIButtonTypeCustom];
    [right_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [right_button.titleLabel setFont:[UIFont systemFontOfSize:16]];
    CGSize size;
    //float iOSVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    size=[title_name sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0f]}];
    [right_button setBackgroundImage:image forState:UIControlStateNormal];
    right_button.frame=CGRectMake(frame.size.width-size.width-right_pos-2, frame.size.height-23.0, size.width+10, 21.0);
    [right_button setTitle:title_name forState:UIControlStateNormal];
    [right_button addTarget:self action:@selector(rightButtonAction:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:right_button];
}
// 右ボタン生成
-(void)setMiddleButton:(NSString*)title_name position:(int)right_pos {
    float pt_x=self.frame.size.width-right_pos;
    if (right_button!=nil) {
        pt_x=right_button.frame.origin.x;
    }
    if (middle_button!=nil) {
        [middle_button removeFromSuperview];
        middle_button=nil;
    }
    CGRect frame=self.frame;
    UIImage *image = [UIImage imageNamed:@"rect2985.png"];
    middle_button=[UIButton buttonWithType:UIButtonTypeCustom];
    [middle_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [middle_button.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [middle_button setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    CGSize size;
    //float iOSVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    size=[title_name sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0f]}];
    [middle_button setBackgroundImage:image forState:UIControlStateNormal];
    middle_button.frame=CGRectMake(pt_x-size.width-right_pos-2, frame.size.height-23.0, size.width+10, 21.0);
    [middle_button setTitle:title_name forState:UIControlStateNormal];
    [middle_button addTarget:self action:@selector(middleButtonAction:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:middle_button];
}
-(void)disableMiddleButton {
    middle_button.enabled=NO;
}
-(void)enableMiddleButton {
    middle_button.enabled=YES;
}
-(void)reSize:(CGRect)arg_rect {
    self.frame=arg_rect;
    if (right_button!=nil) {
        CGRect rect=right_button.frame;
        rect.origin.x=arg_rect.size.width-right_button.frame.size.width-10.0;
        right_button.frame=rect;
    }
    if (middle_button!=nil) {
        float pt_x=self.frame.size.width-15;
        if (right_button!=nil) {
            pt_x=right_button.frame.origin.x;
        }
        CGRect rect=middle_button.frame;
        rect.origin.x=pt_x-rect.size.width-10.0;
        middle_button.frame=rect;
    }
    if (title_label!=nil) {
        float pt_x=self.frame.size.width-15;
        if (right_button!=nil) {
            pt_x=right_button.frame.origin.x;
        }
        if (middle_button!=nil) {
            pt_x=middle_button.frame.origin.x;
        }
        CGRect rect=title_label.frame;
        rect.size.width=pt_x-rect.origin.x;
        title_label.frame=rect;
    }
}
// left button action
-(void)leftButtonAction:(id)sender {
    [self.delegate leftButtonAction];
}
// right button action
-(void)rightButtonAction:(id)sender {
    [self.delegate rightButtonAction];
}
// right button action
-(void)middleButtonAction:(id)sender {
    [self.delegate middleButtonAction];
}
// タイトル変更
-(void)setTitle:(NSString*)arg_text {
    float iOSVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    CGSize size;
    if (iOSVersion>=7.0) {
        size=[arg_text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]}];
    }else{
        size = [arg_text sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(320.0, 14.0) lineBreakMode:NSLineBreakByWordWrapping];
    }
    float pt_x=100.0;
    if (left_button!=nil) {
        pt_x=left_button.frame.origin.x+left_button.frame.size.width+20.0;
    }
    if (middle_button!=nil) {
        
    }
}
@end
