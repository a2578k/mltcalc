//
//  ButtonControlView.m
//  mltcalc
//
//  Created by a2578k on 2014/05/02.
//  Copyright (c) 2014年 LoftLabo. All rights reserved.
//

#import "ButtonControlView4v.h"
#import "CommandContolView.h"
#import "Command.h"
#import "WebViewController.h"

extern Command *gcmd;
BOOL break_flag;
BOOL deg_or_rad_falg;


@interface ButtonControlView4v ()

@end

@implementation ButtonControlView4v

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        fnc1_click_falg=NO;
        fnc2_click_falg=NO;
        fnc3_click_falg=NO;
        fnc4_click_falg=NO;
        fnc5_click_falg=NO;
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *path;
        NSURL *url;
        // ボタンクリック音
        path = [bundle pathForResource:@"click"
                                ofType:@"mp3"];
        url = [NSURL fileURLWithPath:path];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)url,
                                         &_clickSound);
        deg_or_rad_falg=NO;// deg
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    text_view_rect=text_view.frame;
    [text_view removeFromSuperview];
    text_view=[[CalculatorDisp alloc] initWithFrame:text_view_rect];
    [self.view addSubview:text_view];
    // --------------- iad -------
    _adBannerView=nil;
    NSUserDefaults *defs=[NSUserDefaults standardUserDefaults];
    NSString *NoiAdProdoct=[defs objectForKey:@"NoiAdProdoct"];
    pymeyt_by_flag=NO;
    // pymeyt_flag iAdを表示するフラッグ
    // pymeyt_by_flag 購入フラッグ
    if (NoiAdProdoct==nil) {
    }else{
    }
    if (NoiAdProdoct==nil) {
        if (_adBannerView==nil) {
            _adBannerView = [[ADBannerView alloc] initWithFrame:CGRectZero];
            _adBannerView.frame = CGRectMake(0.0, title_bar.frame.size.height-_adBannerView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-title_bar.frame.size.height);
            //_adBannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
            [self.view addSubview:_adBannerView];
            _adBannerView.delegate = self;
            _bannerIsVisible = NO;
        }else{
            _bannerIsVisible = YES;
        }
    }
    // ---------------------------
    if_array=[NSArray arrayWithObjects:@"asin", @"atan", @"acos", @"sqrt", @"atan2", @"ex", @"x2", @"rand", @"abs", @"floor", @"ceil", @"nCr", @"nPr",@"ft", nil];
    title_bar=[[TitleBarClass alloc] initWithFrame:self.view.frame];
    title_bar.delegate=self;
    /*
     if (NoiAdProdoct==nil) {
     if (_adBannerView==nil) {
     _adBannerView = [[ADBannerView alloc] initWithFrame:CGRectZero];
     _adBannerView.frame = CGRectMake(0.0, title_bar.frame.size.height-_adBannerView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-title_bar.frame.size.height);
     //_adBannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
     [self.view addSubview:_adBannerView];
     _adBannerView.delegate = self;
     _bannerIsVisible = NO;
     }else{
     _bannerIsVisible = YES;
     }
     }
     */
    [self.view addSubview:title_bar];
    [title_bar setLeftButton:@"Menu" position:5];
    //NSLog(@"x=%f,%f,w=%f,h=%f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    fnc1Button.titleLabel.adjustsFontSizeToFitWidth=YES;
    fnc2Button.titleLabel.adjustsFontSizeToFitWidth=YES;
    fnc3Button.titleLabel.adjustsFontSizeToFitWidth=YES;
    fnc4Button.titleLabel.adjustsFontSizeToFitWidth=YES;
    fnc5Button.titleLabel.adjustsFontSizeToFitWidth=YES;
    NSString *prog1=[defs objectForKey:@"prog1"];
    if (prog1==nil) {
        prog1=@"asin";
    }
    NSString *prog2=[defs objectForKey:@"prog2"];
    if (prog2==nil) {
        prog2=@"acos";
    }
    NSString *prog3=[defs objectForKey:@"prog3"];
    if (prog3==nil) {
        prog3=@"atan";
    }
    NSString *prog4=[defs objectForKey:@"prog4"];
    if (prog4==nil) {
        prog4=@"nCr";
    }
    NSString *prog5=[defs objectForKey:@"prog5"];
    if (prog5==nil) {
        prog5=@"nPr";
    }
    [fnc1Button setTitle:prog1 forState:UIControlStateNormal];
    [fnc2Button setTitle:prog2 forState:UIControlStateNormal];
    [fnc3Button setTitle:prog3 forState:UIControlStateNormal];
    [fnc4Button setTitle:prog4 forState:UIControlStateNormal];
    [fnc4Button setTitle:prog4 forState:UIControlStateNormal];
    [fnc5Button setTitle:prog5 forState:UIControlStateNormal];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dspChngProc) name:@"DispChng" object:nil];
    [text_view noEdit];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)sinAction:(id)sender {
    AudioServicesPlaySystemSound(_clickSound);
    [text_view AddCmd:@"sin("];
}
-(IBAction)cosAction:(id)sender {
    AudioServicesPlaySystemSound(_clickSound);
    [text_view AddCmd:@"cos("];
}
-(IBAction)tanAction:(id)sender {
    AudioServicesPlaySystemSound(_clickSound);
    [text_view AddCmd:@"tan("];
}
-(IBAction)logAction:(id)sender {
    AudioServicesPlaySystemSound(_clickSound);
    [text_view AddCmd:@"log("];
}
-(IBAction)powAction:(id)sender {
    AudioServicesPlaySystemSound(_clickSound);
    [text_view AddCmd:@"^"];
}
-(IBAction)nAdd0Action:(id)sender {
    AudioServicesPlaySystemSound(_clickSound);
    [text_view AddCmd:@"0"];
}
-(IBAction)nAdd1Action:(id)sender {
    AudioServicesPlaySystemSound(_clickSound);
    [text_view AddCmd:@"1"];
}
-(IBAction)nAdd2Action:(id)sender {
    AudioServicesPlaySystemSound(_clickSound);
    [text_view AddCmd:@"2"];
}
-(IBAction)nAdd3Action:(id)sender {
    AudioServicesPlaySystemSound(_clickSound);
    [text_view AddCmd:@"3"];
}
-(IBAction)nAdd4Action:(id)sender {
    AudioServicesPlaySystemSound(_clickSound);
    [text_view AddCmd:@"4"];
}
-(IBAction)nAdd5Action:(id)sender {
    AudioServicesPlaySystemSound(_clickSound);
    [text_view AddCmd:@"5"];
}
-(IBAction)nAdd6Action:(id)sender {
    AudioServicesPlaySystemSound(_clickSound);
    [text_view AddCmd:@"6"];
}
-(IBAction)nAdd7Action:(id)sender {
    AudioServicesPlaySystemSound(_clickSound);
    [text_view AddCmd:@"7"];
}
-(IBAction)nAdd8Action:(id)sender {
    AudioServicesPlaySystemSound(_clickSound);
    [text_view AddCmd:@"8"];
}
-(IBAction)nAdd9Action:(id)sender {
    AudioServicesPlaySystemSound(_clickSound);
    [text_view AddCmd:@"9"];
}
-(IBAction)plusAction:(id)sender {
    AudioServicesPlaySystemSound(_clickSound);
    [text_view AddCmd:@"+"];
}
-(IBAction)minusAction:(id)sender {
    AudioServicesPlaySystemSound(_clickSound);
    [text_view AddCmd:@"-"];
}
-(IBAction)multiplicationAction:(id)sender {
    AudioServicesPlaySystemSound(_clickSound);
    [text_view AddCmd:@"*"];
}
-(IBAction)divadeAction:(id)sender {
    AudioServicesPlaySystemSound(_clickSound);
    [text_view AddCmd:@"/"];
}
-(IBAction)clearAction:(id)sender {
    AudioServicesPlaySystemSound(_clickSound);
    text_view.text=@"";
    [text_view hideDataTextView];
}
-(IBAction)delAction:(id)sender {
    AudioServicesPlaySystemSound(_clickSound);
    if ([text_view isEdit]) {
        [text_view deleteChar];
    }else{
        [text_view hideDataTextView];
    }
}
-(IBAction)packAction:(id)sender {
    AudioServicesPlaySystemSound(_clickSound);
    NSString *str=[text_view getText];
    [text_view setText:[NSString stringWithFormat:@"(%@)", str]];
}
-(IBAction)equalAction:(id)sender {
    break_flag=NO;
    AudioServicesPlaySystemSound(_clickSound);
    NSString *cmdstr=[NSString stringWithFormat:@"ans=%@;print ans;",[text_view getText]];
    [gcmd setCmdHistory:cmdstr];
    [gcmd setCalHistory:[text_view getText]];
    NSArray *arr=[gcmd expr:cmdstr];
    NSString *errmsg=[arr objectAtIndex:2];
    if ([errmsg isEqualToString:@""]==YES) {
        cmd_hlist_idx=0;
        [text_view setDataText:[NSArray arrayWithObjects:[text_view getText], [arr objectAtIndex:1],[arr objectAtIndex:2], nil]];
        [text_view showDataTextView];
    }else{
        [text_view setDataText:[NSArray arrayWithObjects:[text_view getText],[arr objectAtIndex:1], [arr objectAtIndex:2], nil]];
        [text_view showDataTextView];
    }
}
-(IBAction)leftParenthesisAction:(id)sender {
    AudioServicesPlaySystemSound(_clickSound);
    [text_view AddCmd:@"("];
}
-(IBAction)rightParenthesisAction:(id)sender {
    AudioServicesPlaySystemSound(_clickSound);
    [text_view AddCmd:@")"];
}
-(void)dspChngProc {
    AudioServicesPlaySystemSound(_clickSound);
    [text_view hideDataTextView];
}
-(IBAction)programAction:(id)sender {
    CommandContolView *new_view = [[CommandContolView alloc] initWithNibName:@"CommandContolView" bundle:nil];
    new_view.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
    [self.navigationController pushViewController:new_view animated:YES];
}
-(IBAction)shiftAction:(id)sender {
    AudioServicesPlaySystemSound(_clickSound);
    if (shift_view.hidden) {
        shift_view.hidden=NO;
    }else{
        shift_view.hidden=YES;
    }
}
-(IBAction)commaAction:(id)sender {
    AudioServicesPlaySystemSound(_clickSound);
    [text_view AddCmd:@"."];
}
-(IBAction)cammaAction:(id)sender {
    AudioServicesPlaySystemSound(_clickSound);
    [text_view AddCmd:@","];
}
-(IBAction)moodAction:(id)sender {
    AudioServicesPlaySystemSound(_clickSound);
    [text_view AddCmd:@"%"];
}
-(IBAction)asinAction:(id)sender {
    AudioServicesPlaySystemSound(_clickSound);
    [text_view AddCmd:@"asin("];
}
-(IBAction)atanAction:(id)sender {
    AudioServicesPlaySystemSound(_clickSound);
    [text_view AddCmd:@"atan("];
}
-(IBAction)acosAction:(id)sender {
    AudioServicesPlaySystemSound(_clickSound);
    [text_view AddCmd:@"acos("];
}
-(IBAction)rootAction:(id)sender {
    AudioServicesPlaySystemSound(_clickSound);
    [text_view AddCmd:@"sqrt("];
}
-(IBAction)squarAction:(id)sender {
    AudioServicesPlaySystemSound(_clickSound);
    [text_view AddCmd:@"x2("];
}
-(IBAction)xrootAction:(id)sender {
    AudioServicesPlaySystemSound(_clickSound);
    [text_view AddCmd:@"xroot("];
}
-(IBAction)ansAction:(id)sender {
    AudioServicesPlaySystemSound(_clickSound);
    [text_view AddCmd:@"ans"];
}
-(IBAction)fnc1Action:(UIButton*)arg_button {
    AudioServicesPlaySystemSound(_clickSound);
    if (fnc1_click_falg) {
        select_button_name=@"prog1";
        [self setupMenu:arg_button.titleLabel.text rect:CGRectMake(arg_button.frame.origin.x+20.0, arg_button.frame.origin.y+5, 110.0, 110.0)];
        fnc1_click_falg=NO;
    }else{
        fnc1_click_falg=YES;
        [self performSelector:@selector(fnc1SingleAction:) withObject:arg_button.titleLabel.text afterDelay:0.2];
    }
}
-(IBAction)fnc2Action:(UIButton*)arg_button {
    AudioServicesPlaySystemSound(_clickSound);
    if (fnc2_click_falg) {
        select_button_name=@"prog2";
        [self setupMenu:arg_button.titleLabel.text rect:CGRectMake(arg_button.frame.origin.x+20.0, arg_button.frame.origin.y+5, 110.0, 110.0)];
        fnc2_click_falg=NO;
    }else{
        fnc2_click_falg=YES;
        [self performSelector:@selector(fnc2SingleAction:) withObject:arg_button.titleLabel.text afterDelay:0.2];
    }
}
-(IBAction)fnc3Action:(UIButton*)arg_button {
    AudioServicesPlaySystemSound(_clickSound);
    if (fnc3_click_falg) {
        select_button_name=@"prog3";
        [self setupMenu:arg_button.titleLabel.text rect:CGRectMake(arg_button.frame.origin.x+20.0, arg_button.frame.origin.y+5, 110.0, 110.0)];
        fnc3_click_falg=NO;
    }else{
        fnc3_click_falg=YES;
        [self performSelector:@selector(fnc3SingleAction:) withObject:arg_button.titleLabel.text afterDelay:0.2];
    }
}
-(IBAction)fnc4Action:(UIButton*)arg_button {
    AudioServicesPlaySystemSound(_clickSound);
    if (fnc4_click_falg) {
        select_button_name=@"prog4";
        [self setupMenu:arg_button.titleLabel.text rect:CGRectMake(arg_button.frame.origin.x+20.0, arg_button.frame.origin.y+5, 110.0, 110.0)];
        fnc4_click_falg=NO;
    }else{
        fnc4_click_falg=YES;
        [self performSelector:@selector(fnc4SingleAction:) withObject:arg_button.titleLabel.text afterDelay:0.2];
    }
}
-(IBAction)fnc5Action:(UIButton*)arg_button {
    AudioServicesPlaySystemSound(_clickSound);
    if (fnc5_click_falg) {
        select_button_name=@"prog5";
        [self setupMenu:arg_button.titleLabel.text rect:CGRectMake(arg_button.frame.origin.x+20.0, arg_button.frame.origin.y+5, 110.0, 110.0)];
        fnc5_click_falg=NO;
    }else{
        fnc5_click_falg=YES;
        [self performSelector:@selector(fnc5SingleAction:) withObject:arg_button.titleLabel.text afterDelay:0.2];
    }
}
-(void)fnc1SingleAction:(NSString*)arg_fname {
    if (fnc1_click_falg) {
        [text_view AddCmd:[NSString stringWithFormat:@"%@(", arg_fname]];
    }
    fnc1_click_falg=NO;
}
-(void)fnc2SingleAction:(NSString*)arg_fname {
    if (fnc2_click_falg) {
        [text_view AddCmd:[NSString stringWithFormat:@"%@(", arg_fname]];
    }
    fnc2_click_falg=NO;
}
-(void)fnc3SingleAction:(NSString*)arg_fname {
    if (fnc3_click_falg) {
        [text_view AddCmd:[NSString stringWithFormat:@"%@(", arg_fname]];
    }
    fnc3_click_falg=NO;
}
-(void)fnc4SingleAction:(NSString*)arg_fname {
    if (fnc4_click_falg) {
        [text_view AddCmd:[NSString stringWithFormat:@"%@(", arg_fname]];
    }
    fnc4_click_falg=NO;
}
-(void)fnc5SingleAction:(NSString*)arg_fname {
    if (fnc5_click_falg) {
        [text_view AddCmd:[NSString stringWithFormat:@"%@(", arg_fname]];
    }
    fnc5_click_falg=NO;
}
-(void)copyAction:(NSString*)arg_value {
    
}
-(void)addFunction:(NSString*)arg_value {
    
}
-(void)selectMenu:(NSString*)arg_str {
    if (select_view!=nil) {
        NSUserDefaults *defs=[NSUserDefaults standardUserDefaults];
        if ([select_button_name isEqualToString:@"prog1"]) {
            [defs setObject:arg_str forKey:@"prog1"];
            [fnc1Button setTitle:arg_str forState:UIControlStateNormal];
        }else if ([select_button_name isEqualToString:@"prog2"]) {
            [defs setObject:arg_str forKey:@"prog2"];
            [fnc2Button setTitle:arg_str forState:UIControlStateNormal];
        }else if ([select_button_name isEqualToString:@"prog3"]) {
            [defs setObject:arg_str forKey:@"prog3"];
            [fnc3Button setTitle:arg_str forState:UIControlStateNormal];
        }else if ([select_button_name isEqualToString:@"prog4"]) {
            [defs setObject:arg_str forKey:@"prog4"];
            [fnc4Button setTitle:arg_str forState:UIControlStateNormal];
        }else if ([select_button_name isEqualToString:@"prog5"]) {
            [defs setObject:arg_str forKey:@"prog5"];
            [fnc5Button setTitle:arg_str forState:UIControlStateNormal];
        }
        [defs synchronize];
        [select_view removeFromSuperview];
        select_view=nil;
    }
    if (select_view!=nil) {
        [select_view removeFromSuperview];
        select_view=nil;
    }
    if (select_help_view!=nil) {
        [select_help_view removeFromSuperview];
        select_help_view=nil;
    }
}
-(void)setupMenu:(NSString*)arg_fname rect:(CGRect)arg_rect {
    select_view=[[SelectMenuView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
    NSMutableArray *new_array=[[NSMutableArray alloc] init];
    [new_array addObjectsFromArray:[gcmd getFnameArray]];
    [new_array addObjectsFromArray:if_array];
    [select_view setMenuItem:new_array fontSize:15.0 ViewRect:arg_rect];
    select_view.main_delegate=self;
    [self.view addSubview:select_view];
}
-(IBAction)lnAction:(id)sender {
    AudioServicesPlaySystemSound(_clickSound);
    [text_view AddCmd:@"ln("];
}
-(void)leftButtonAction {
    [text_view debug];
    if (select_view!=nil) {
        [select_view removeFromSuperview];
        select_view=nil;
    }
    if (select_help_view!=nil) {
        [select_help_view removeFromSuperview];
        select_help_view=nil;
    }
    NSString *HelpMenu_video=NSLocalizedString(@"HelpMenu_video", @"video");
    NSString *HelpMenu_NoPayment=NSLocalizedString(@"HelpMenu_NoPayment", @"広告を停止する");
    NSString *HelpMenu_Restore=@"Restore";
    select_help_view=[[SelectMenuView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
    NSUserDefaults *defs=[NSUserDefaults standardUserDefaults];
    NSString *add_ftp_prodoct=[defs objectForKey:@"NoiAdProdoct"];
    if (add_ftp_prodoct==nil) {
        [select_help_view setMenuItem:[NSArray arrayWithObjects:HelpMenu_video,HelpMenu_NoPayment,HelpMenu_Restore, nil] fontSize:15.0 ViewRect:CGRectMake(0.0, title_bar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-title_bar.frame.size.height)];
    }else{
        [select_help_view setMenuItem:[NSArray arrayWithObjects:HelpMenu_video, nil] fontSize:15.0 ViewRect:CGRectMake(0.0, title_bar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-title_bar.frame.size.height)];
    }
    //CGRect rect=select_view.frame;
    select_help_view.main_delegate=self;
    [self.view addSubview:select_help_view];
}
-(void)stopIad {
}
#pragma mark - PaymentNotification Method
- (void)paymentCompletedNotification:(NSNotification *)notification {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if (alertView!=nil) {
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        alertView = nil;
    }
    //[_alertView dismissWithClickedButtonIndex:0 animated:YES];
    //self.alertView = nil;
    NSUserDefaults *defs=[NSUserDefaults standardUserDefaults];
    [defs setObject:@"true" forKey:@"NoiAdProdoct"];
    
    NSString *Store_BuyEndMessage=NSLocalizedString(@"Store_BuyEndMessage", @"message");
    UIAlertView *alert =[[UIAlertView alloc]initWithTitle:Store_BuyEndMessage
                                                  message:nil
                                                 delegate:nil
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles:nil];
    [alert show];
    pymeyt_by_flag=YES;
    pymeyt_flag=NO;
    [self bannerOff];
}

- (void)paymentErrorNotification:(NSNotification *)notification {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    //[_alertView dismissWithClickedButtonIndex:0 animated:YES];
    //self.alertView = nil;
    if (alertView!=nil) {
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        alertView = nil;
    }
    
}
#pragma mark - PaymentManagerlDelegate Method

-(IBAction)DegReadAction:(id)sender {
    UIButton *button=(UIButton*)sender;
    if (deg_or_rad_falg) {
        [button setTitle:@"Deg" forState:UIControlStateNormal];
        deg_or_rad_falg=NO;
    }else{
        [button setTitle:@"Rad" forState:UIControlStateNormal];
        deg_or_rad_falg=YES;
    }
}
-(void)rightButtonAction {
    WebViewController *newview = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
    NSString *VideoUrl=NSLocalizedString(@"VideoUrl", VideoUrl);
    //newview.url_str=@"http://mapgrid.sakura.ne.jp/mltcalc/help.html";
    newview.url_str=VideoUrl;
    [self.navigationController pushViewController:newview animated:YES];
    newview.main_delegate=self;
    [newview setDisp];
}
-(void)middleButtonAction {
    
}
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}
-(IBAction)gyaku:(id)sender {
    AudioServicesPlaySystemSound(_clickSound);
    //NSString *str=[text_view getText];
    [text_view AddCmd:@"1/("];
}
-(IBAction)cmdUp:(id)sender {
    AudioServicesPlaySystemSound(_clickSound);
    NSString *cmdsre=[gcmd getCalHisrory:cmd_hlist_idx];
    [text_view setText:cmdsre];
    [text_view hideDataTextView];
    cmd_hlist_idx++;
}
-(IBAction)cmdDown:(id)sender {
    AudioServicesPlaySystemSound(_clickSound);
    cmd_hlist_idx--;
    if (cmd_hlist_idx<0) {
        cmd_hlist_idx=0;
    }
    NSString *cmdsre=[gcmd getCalHisrory:cmd_hlist_idx];
    [text_view setText:cmdsre];
    [text_view hideDataTextView];
}
#pragma mark - ADBannerViewDelegate Method
- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if (!_bannerIsVisible && pymeyt_flag) {
        // iAdのビューを表示する（画面の外からアニメーションさせる）
        CGRect rect=text_view.frame;
        rect.size.height=text_view_rect.size.height-banner.frame.size.height;
        rect.origin.y=title_bar.frame.size.height+banner.frame.size.height+8;
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        CGRect wrect=banner.frame;
        wrect=CGRectMake(0.0, title_bar.frame.size.height+4, wrect.size.width, wrect.size.height);
        banner.frame=wrect;
        //banner.frame = CGRectOffset(banner.frame, 0, banner.frame.size.height+title_bar.frame.size.height+2);
        text_view.frame=rect;
        [UIView commitAnimations];
        [text_view resize];
        wrect=banner.frame;
        _bannerIsVisible = YES;
        NSLog(@"bannerViewDidLoadAd");
    }
}
-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
	if (_bannerIsVisible) {
        // iAdのビューを消す（画面の外へアニメーションさせる）
        CGRect rect=text_view.frame;
        rect.size.height+=banner.frame.size.height;
        rect.origin.y=title_bar.frame.size.height+5;
		[UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        rect.origin.y=title_bar.frame.size.height+banner.frame.size.height+8;
		banner.frame = CGRectOffset(banner.frame, 0, -banner.frame.size.height-banner.frame.size.height-8);
        text_view.frame=text_view_rect;
		[UIView commitAnimations];
        [text_view resize];
		_bannerIsVisible = NO;
	}
}
-(void)bannerOff {
    if (_bannerIsVisible) {
        // iAdのビューを消す（画面の外へアニメーションさせる）
        NSLog(@"iAd size x=%f,y=%f, w=%f,h=%f", _adBannerView.frame.origin.x, _adBannerView.frame.origin.y, _adBannerView.frame.size.width, _adBannerView.frame.size.height);
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        CGRect wrect=_adBannerView.frame;
        wrect=CGRectMake(0.0, title_bar.frame.size.height-_adBannerView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-title_bar.frame.size.height);
        _adBannerView.frame=wrect;
        text_view.frame=text_view_rect;
        [UIView commitAnimations];
        NSLog(@"iAd size x=%f,y=%f, w=%f,h=%f", _adBannerView.frame.origin.x, _adBannerView.frame.origin.y, _adBannerView.frame.size.width, _adBannerView.frame.size.height);
        [text_view resize];
        _bannerIsVisible = NO;
    }
}
/*
 #pragma mark - PaymentManagerlDelegate Method
 - (void)finishRequest:(SKProductsRequest *)request productList:(NSArray *)productList {
 //NSLog(@"%s", __PRETTY_FUNCTION__);
 // 取得したプロダクト情報を順番にUItextVIewに表示する（今回は1つだけ）
 for (SKProduct *product in productList) {
 
 NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
 [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
 [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
 [numberFormatter setLocale:product.priceLocale];
 NSString *formattedString = [numberFormatter stringFromNumber:product.price];
 NSUserDefaults *defs=[NSUserDefaults standardUserDefaults];
 [defs setObject:formattedString forKey:@"PriceTire"];
 product_item=product;
 break;
 }
 
 }
 - (void)finishRequest:(SKRequest *)request didFailWithError:(NSError *)error {
 //NSLog(@"%s", __PRETTY_FUNCTION__);
 
 }
 - (void)finishPayment:(SKPaymentTransaction *)paymentTransaction {
 //NSLog(@"%s", __PRETTY_FUNCTION__);
 }
 
 - (void)finishPayment:(SKPaymentTransaction *)paymentTransaction didFailWithError:(NSError *)error {
 //NSLog(@"%s", __PRETTY_FUNCTION__);
 }
 */
@end
