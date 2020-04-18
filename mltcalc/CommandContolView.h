//
//  CommandContolView.h
//  mltcalc
//
//  Created by a2578k on 2014/05/02.
//  Copyright (c) 2014年 LoftLabo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeyboardAccessoryView.h"
#import "CalculatorDisp.h"
#import "SelectMenuView.h"
#import "TitleBarClass.h"
#import "delegate.h"

@interface CommandContolView : UIViewController <UITextViewDelegate,UITextInputDelegate,UIAlertViewDelegate,KeyboardProtocol,SelectMenuProtocol,TitleProtocol,MainControlProtocol> {
    TitleBarClass *title_bar;
    CalculatorDisp *text_view;
    SelectMenuView *select_view;
    NSString *out_str;
    BOOL pymeyt_flag;
    BOOL _bannerIsVisible;
    int cmd_hlist_idx;
    BOOL f_edit;
    BOOL f_remove;
    BOOL f_call;
    NSString *remove_name;
    NSTimer *loadTimer;
    NSArray *if_array;
}
-(void)dspChngProc;
@end
