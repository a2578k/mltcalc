//
//  TitleBarClass.h
//  LinkList
//
//  Created by a2578k on 2013/09/21.
//  Copyright (c) 2013年 sogawa seiji. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TitleProtocol <NSObject>
-(void)leftButtonAction;
-(void)rightButtonAction;
-(void)middleButtonAction;
@end

@interface TitleBarClass : UIView {
    id<TitleProtocol> delegate;
    SEL left_sel;
    SEL right_sel;
    UIButton *left_button;
    UIButton *right_button;
    UIButton *middle_button;
    UILabel *title_label;
}
@property (nonatomic, retain) id<TitleProtocol> delegate;
@property (nonatomic, retain) UIButton *left_button;
@property (nonatomic, retain) UIButton *right_button;
@property (nonatomic, retain) UIButton *middle_button;
@property (nonatomic, retain) UILabel *title_label;
-(void)setLeftButton:(NSString*)title_name position:(int)left_pos;
-(void)setRightButton:(NSString*)title_name position:(int)right_pos;
-(void)setMiddleButton:(NSString*)title_name position:(int)right_pos;
-(void)reSize:(CGRect)arg_rect;
-(void)disableMiddleButton;
-(void)enableMiddleButton;
-(void)setTitle:(NSString*)arg_text;
//
@end
