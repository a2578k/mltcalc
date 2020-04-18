//
//  KeyboardAccessoryView.h
//  InputTest
//
//  Created by a2578k on 2013/12/20.
//  Copyright (c) 2013年 sogawa seiji. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol KeyboardProtocol <NSObject>
-(void)Expr;
-(void)ChgChar;
-(void)BackChar;
-(void)cmdDown;
-(void)cmdUp;
-(void)crtLeft;
-(void)crtRight;
-(void)Calculator;
-(void)helpAction;
-(void)editFuncAction;
-(void)callFuncAction;
-(BOOL)saveFuncAction;
-(void)clearFuncAction;
-(void)removeFunctionAction;
@end
typedef enum {HtmlKeyBoard,NormalKeyBoard,HideKeyboard} KeyboardType;
@interface KeyboardAccessoryView : UIView {
    id<KeyboardProtocol> delegate;
    UIView *view1;
    UIView *view2;
}
@property (nonatomic, retain) id<KeyboardProtocol> delegate;
-(void)setTagButtonData:(NSArray*)arg_data_array view:(UIView*)arg_view;
-(UIView*)CreateView1:(CGRect)arg_rect;
-(UIView*)CreateView2:(CGRect)arg_rect;
-(void)changeView;
-(int)getViewMode;
@end
