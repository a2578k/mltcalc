//
//  KeyboardAccessoryView.m
//  InputTest
//
//  Created by a2578k on 2013/12/20.
//  Copyright (c) 2013年 sogawa seiji. All rights reserved.
//

#import "KeyboardAccessoryView.h"

@implementation KeyboardAccessoryView

@synthesize delegate;
- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.frame=frame;
        self.backgroundColor=[UIColor whiteColor];
        self.layer.borderWidth = 0.5f;    //ボーダーの幅
        view1=[self CreateView1:frame];
        [self addSubview:view1];
        view2=nil;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitAction) name:@"normlKeybrd" object:nil];
    }
    return self;
}
-(void)changeView {
    if (view2==nil) {
        view2=[self CreateView2:self.frame];
        [self addSubview:view2];
    }else{
        [view2 removeFromSuperview];
        view2=nil;
    }
}
-(int)getViewMode {
    if (view2.hidden==YES) {
        return 0;
    }else{
        return 1;
    }
}
-(UIButton*)CreateButton:(NSString*)arg_title imageNamed:(NSString*)arg_name point:(CGPoint)arg_point {
    UIButton *ret_button=[UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:arg_name];
    ret_button=[UIButton buttonWithType:UIButtonTypeCustom];
    [ret_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [ret_button.titleLabel setFont:[UIFont systemFontOfSize:14]];
    CGSize size;
    size=[arg_title sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]}];
    [ret_button setBackgroundImage:image forState:UIControlStateNormal];
    ret_button.frame=CGRectMake(arg_point.x, arg_point.y, size.width+30, 20.0);
    [ret_button setTitle:arg_title forState:UIControlStateNormal];
    return ret_button;
}
-(UIView*)CreateView1:(CGRect)arg_rect {
    UIView *ret_view=[[UIView alloc] initWithFrame:arg_rect];
    ret_view.backgroundColor=[UIColor whiteColor];
    ret_view.alpha=1.0;
    UIButton *expr_button;
    // 実行ボタン
    CGRect frame=self.frame;
    UIImage *image = [UIImage imageNamed:@"box2.png"];
    expr_button=[UIButton buttonWithType:UIButtonTypeCustom];
    [expr_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [expr_button.titleLabel setFont:[UIFont systemFontOfSize:14]];
    NSString *title_name=@"Run";
    CGSize size;
    size=[title_name sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]}];
    [expr_button setBackgroundImage:image forState:UIControlStateNormal];
    expr_button.frame=CGRectMake(frame.size.width-size.width-40.0, 3.0, size.width+30, 25.0);
    [expr_button setTitle:title_name forState:UIControlStateNormal];
    [expr_button addTarget:self action:@selector(exprAction) forControlEvents:UIControlEventTouchDown];
    [ret_view addSubview:expr_button];
    [self setTagButtonData:[[NSArray alloc] initWithObjects:@"callFunc", @"editFunc", @"Clear", @"    ↑    ", @"    ↓    ", nil] view:ret_view];
    return ret_view;
}
-(UIView*)CreateView2:(CGRect)arg_rect {
    UIView *ret_view=[[UIView alloc] initWithFrame:arg_rect];
    ret_view.backgroundColor=[UIColor whiteColor];
    ret_view.alpha=1.0;
    // remove
    // save
    // exit
    UIButton *expr_button;
    // 実行ボタン
    CGRect frame=self.frame;
    UIImage *image = [UIImage imageNamed:@"box2.png"];
    expr_button=[UIButton buttonWithType:UIButtonTypeCustom];
    [expr_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [expr_button.titleLabel setFont:[UIFont systemFontOfSize:14]];
    NSString *title_name=@"exit";
    CGSize size;
    size=[title_name sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]}];
    [expr_button setBackgroundImage:image forState:UIControlStateNormal];
    expr_button.frame=CGRectMake(frame.size.width-size.width-40.0, 3.0, size.width+25, 25.0);
    [expr_button setTitle:title_name forState:UIControlStateNormal];
    [expr_button addTarget:self action:@selector(exitAction) forControlEvents:UIControlEventTouchDown];
    [ret_view addSubview:expr_button];
    [self setTagButtonData:[[NSArray alloc] initWithObjects:@"remove", @"save", nil] view:ret_view];
    return ret_view;
}

-(void)exprAction {
    [self.delegate Expr];
}
-(void)exitAction {
    [self changeView];
}
//
-(void)tagAction:(id)sender {
    UIButton *button=(UIButton*)sender;
    if ([button.titleLabel.text isEqualToString:@"editFunc"]) {
        [self changeView];
        [delegate editFuncAction];
        return;
    }else if ([button.titleLabel.text isEqualToString:@"callFunc"]) {
        [delegate callFuncAction];
        return;
    }else if ([button.titleLabel.text isEqualToString:@"Clear"]) {
        [delegate clearFuncAction];
    }else if ([button.titleLabel.text isEqualToString:@"    ↑    "]) {
        [delegate cmdUp];
    }else if ([button.titleLabel.text isEqualToString:@"    ↓    "]) {
        [delegate cmdDown];
        return;
    }else if ([button.titleLabel.text isEqualToString:@"remove"]) {
        [delegate removeFunctionAction];
    }else if ([button.titleLabel.text isEqualToString:@"save"]) {
        [self saveFuncAction];
    }
}
// tag button 設定
-(void)setTagButtonData:(NSArray*)arg_data_array view:(UIView*)arg_view {
    float pt=3.0;
    UIImage *image = [UIImage imageNamed:@"mbtn.png"];
    UIFont *font=[UIFont systemFontOfSize:13];
    for(NSString *button_name in arg_data_array) {
        UIButton *new_button=[UIButton buttonWithType:UIButtonTypeCustom];
        [new_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal]; //有効時
        CGSize size;
        size=[button_name sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]}];
        //CGSize size = [button_name sizeWithFont:new_button.titleLabel.font constrainedToSize:CGSizeMake(430.0, 30.0) lineBreakMode:NSLineBreakByWordWrapping];
        //[kousin_button setBackgroundImage:btn23_image forState:UIControlStateNormal];
        [new_button.titleLabel setFont:font];
        [new_button setBackgroundImage:image forState:UIControlStateNormal];
        new_button.frame=CGRectMake(pt, 3.0, size.width+4.0, 25.0);
        pt+=size.width+4.0+2.0;
        [new_button setTitle:button_name forState:UIControlStateNormal];
        [new_button addTarget:self action:@selector(tagAction:) forControlEvents:UIControlEventTouchDown];
        [arg_view addSubview:new_button];
    }
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */
-(void)saveFuncAction {
    if ([delegate saveFuncAction]) {
        [self changeView];
    }
}
-(void)editFuncAction {
    [delegate editFuncAction];
}
-(void)removeFunction {
    [delegate removeFunctionAction];
}
@end
