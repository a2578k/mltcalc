//
//  ButtonControlView.h
//  mltcalc
//
//  Created by a2578k on 2014/05/02.
//  Copyright (c) 2014年 LoftLabo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "CalculatorDisp.h"
#import "SelectMenuView.h"
#import "TitleBarClass.h"
#import "delegate.h"
#import <iAd/iAd.h>

@interface ButtonControlView : UIViewController <SelectMenuProtocol,TitleProtocol,MainControlProtocol> {
    TitleBarClass *title_bar;
    IBOutlet CalculatorDisp *text_view;
    IBOutlet UIView *shift_view;
    SelectMenuView *select_view;
    SelectMenuView *select_help_view;
    IBOutlet UIButton *fnc1Button;
    IBOutlet UIButton *fnc2Button;
    IBOutlet UIButton *fnc3Button;
    IBOutlet UIButton *fnc4Button;
    IBOutlet UIButton *fnc5Button;
    BOOL fnc1_click_falg;
    BOOL fnc2_click_falg;
    BOOL fnc3_click_falg;
    BOOL fnc4_click_falg;
    BOOL fnc5_click_falg;
    NSString *select_button_name;
    UIAlertView *alertView;
    SystemSoundID _clickSound;      // ボタンクリックの効果音
    int cmd_hlist_idx;
    NSArray *if_array;
    BOOL pymeyt_flag;               // iadk購入フラッグ
    BOOL _bannerIsVisible;          // 
    ADBannerView *_adBannerView;
    BOOL pymeyt_by_flag;
    CGRect text_view_rect;
}
-(IBAction)sinAction:(id)sender;
-(IBAction)cosAction:(id)sender;
-(IBAction)tanAction:(id)sender;
-(IBAction)logAction:(id)sender;
-(IBAction)powAction:(id)sender;
-(IBAction)nAdd0Action:(id)sender;
-(IBAction)nAdd1Action:(id)sender;
-(IBAction)nAdd2Action:(id)sender;
-(IBAction)nAdd3Action:(id)sender;
-(IBAction)nAdd4Action:(id)sender;
-(IBAction)nAdd5Action:(id)sender;
-(IBAction)nAdd6Action:(id)sender;
-(IBAction)nAdd7Action:(id)sender;
-(IBAction)nAdd8Action:(id)sender;
-(IBAction)nAdd9Action:(id)sender;
-(IBAction)plusAction:(id)sender;
-(IBAction)minusAction:(id)sender;
-(IBAction)multiplicationAction:(id)sender;
-(IBAction)divadeAction:(id)sender;
-(IBAction)clearAction:(id)sender;
-(IBAction)delAction:(id)sender;
-(IBAction)packAction:(id)sender;
-(IBAction)equalAction:(id)sender;
-(IBAction)leftParenthesisAction:(id)sender;
-(IBAction)rightParenthesisAction:(id)sender;
-(IBAction)programAction:(id)sender;
-(IBAction)shiftAction:(id)sender;
-(IBAction)commaAction:(id)sender;
-(IBAction)asinAction:(id)sender;
-(IBAction)atanAction:(id)sender;
-(IBAction)acosAction:(id)sender;
-(IBAction)rootAction:(id)sender;
-(IBAction)squarAction:(id)sender;
-(IBAction)xrootAction:(id)sender;
-(IBAction)ansAction:(id)sender;
-(IBAction)fnc1Action:(id)sender;
-(IBAction)fnc2Action:(id)sender;
-(IBAction)fnc3Action:(id)sender;
-(IBAction)fnc4Action:(id)sender;
-(IBAction)fnc5Action:(id)sender;
-(IBAction)lnAction:(id)sender;
-(IBAction)DegReadAction:(id)sender;
-(IBAction)cammaAction:(id)sender;
-(IBAction)moodAction:(id)sender;
-(void)fnc1SingleAction:(NSString*)arg_fname;
-(void)fnc2SingleAction:(NSString*)arg_fname;
-(void)fnc3SingleAction:(NSString*)arg_fname;
-(void)fnc4SingleAction:(NSString*)arg_fname;
-(void)fnc5SingleAction:(NSString*)arg_fname;
-(void)setupMenu:(NSString*)arg_fname rect:(CGRect)arg_rect;
-(IBAction)gyaku:(id)sender;
-(IBAction)cmdUp:(id)sender;
-(IBAction)cmdDown:(id)sender;
@end
