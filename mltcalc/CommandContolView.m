//
//  CommandContolView.m
//  mltcalc
//
//  Created by a2578k on 2014/05/02.
//  Copyright (c) 2014年 LoftLabo. All rights reserved.
//

#import "CommandContolView.h"
#import "KeyboardAccessoryView.h"
#import "ChartViewController.h"
#import "WebViewController.h"
#include <signal.h>
//extern FILE *yyin;
//extern FILE *yyout;
//FILE *app_out;
//extern int yyparse(void);
//char   is_std_in;
#import "Command.h"
#include "calc.h"
extern Command *gcmd;
extern int eror_flag;
extern BOOL break_flag;
BOOL auto_break_flag;
extern BOOL deg_or_rad_falg;
//extern int *pipefd;
//extern int *pipe_ofd;
extern CommandList *gl_cmd_list;

#import "ViewModeController.h"
@interface CommandContolView ()

@end

@implementation CommandContolView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        select_view=nil;
        text_view=nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if_array=[NSArray arrayWithObjects:@"asin", @"atan", @"acos", @"sqrt", @"atan2", @"ex", @"x2", @"rand", @"abs", @"floor", @"ceil", @"nCr", @"nPr",@"ft",@"degmode",@"radmode",@"arrayColSize",@"arrayRowSize",@"addArray", nil];
    loadTimer=nil;
    auto_break_flag=YES;
    cmd_hlist_idx=0;
    out_str=@"";
    title_bar=[[TitleBarClass alloc] initWithFrame:self.view.frame];
    title_bar.delegate=self;
    [self.view addSubview:title_bar];
    [title_bar setRightButton:@" Help " position:15];
    [title_bar setMiddleButton:@"Graph" position:80];
    [title_bar setLeftButton:@"Close" position:5];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keybaordWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dspChngProc) name:@"DispChng" object:nil];
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
    [self.view  bringSubviewToFront:title_bar];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIScreen *sc = [UIScreen mainScreen];
    CGRect nativeBounds=[sc nativeBounds];
    float scl=[sc nativeScale];
    if (text_view==nil) {
        CGRect rect=[[UIScreen mainScreen] bounds];
        self.view.frame=CGRectMake(0.0, 0.0, rect.size.width, rect.size.height);
        text_view=[[CalculatorDisp alloc] initWithFrame:CGRectMake(0.0, title_bar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-title_bar.frame.size.height)];
        text_view.delegate=self;
        //CGRect trect=title_bar.frame;
        //NSUserDefaults *defs=[NSUserDefaults standardUserDefaults];
        //NSString *NoiAdProdoct=[defs objectForKey:@"NoiAdProdoct"];
        [self.view addSubview:text_view];
        [self performSelector:@selector(afterProc) withObject:nil afterDelay:0.5];
    }
}
-(void)afterProc {
    [gcmd expr:@""];
    [text_view showKeyboad];
}
-(void)stdInMonitaring {
    char buf[128];
    while(1) {
        long rcnt=read(fileno(stdin), buf, sizeof buf);
        if (rcnt==-1) {
            break;
        }
        buf[rcnt]=0;
        NSString* str = [NSString stringWithCString: buf encoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle:@"確認" message:str
                                      delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        });
        //write([m_pipeWriteHandle fileDescriptor], buf, strlen(buf));
        //NSLog(@"%@", str);
    }
}

- (void)handleFileHandleReadCompletionNotification:(NSNotification *)theNotification
{
    //char buf[128];
    //NSLog(@"read");
    //long rcnt=read(pipe_ofd[0], buf, sizeof buf);
    //if (rcnt==-1) {
    //    return;
    //}
    //buf[rcnt]=0;
    NSString *str = [[NSString alloc] initWithData:[[theNotification userInfo] objectForKey:NSFileHandleNotificationDataItem]
                                          encoding: NSUTF8StringEncoding];
    //NSRange trng=[str rangeOfString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [str length])];
    //if (trng.length>0) {
    //    str=[str substringWithRange:NSMakeRange(trng.location+1, [str length]-trng.location-1)];
    //    UIAlertView *alert =
    //    [[UIAlertView alloc] initWithTitle:@"確認" message:str
    //                              delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //    [alert show];
    //}
    //    UIAlertView *alert =
    //[[UIAlertView alloc] initWithTitle:@"確認" message:str
    //                              delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //    [alert show];
    //[text_view setText:str];
    NSLog(@"log>%@", str);
    [text_view AddWord:str];
}
/*
-(void)handleNotification:(NSNotification*)notification {
    [pipeReadHandle readInBackgroundAndNotify] ;
    NSString *str = [[NSString alloc] initWithData: [[notification userInfo] objectForKey: NSFileHandleNotificationDataItem] encoding: NSASCIIStringEncoding] ;
    NSLog(@"%@", str);
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"確認" message:@"stdout notification"
                                  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    });
}
 */
- (void)applicationDidEnterBackground {
}
- (void)applicationWillEnterForeground {
}
/*
-(void)stdoutMonitaring {
    //dispatch_async(dispatch_get_main_queue(), ^{
    //    [text_view showKeyboad];
    //});
    if (pipe_ofd[0]==0) {
        if (pipe(pipe_ofd) < 0) {
            perror("pipe");
            exit(-1);
        }
    }
    char buf[128];
    NSLog(@"read");
    while(1) {
        long rcnt=read(pipe_ofd[0], buf, sizeof buf);
        if (rcnt==-1) {
            break;
        }
        if (pipe_ofd[0]==0) {
            break;
        }
        buf[rcnt]=0;
        NSLog(@"length=%d", (int)strlen(buf));
       out_str = [NSString stringWithCString: buf encoding:NSUTF8StringEncoding];
        if (out_str==nil) {
            continue;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle:@"確認" message:out_str
                                      delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        });
        NSDictionary *dic = [NSDictionary dictionaryWithObject:out_str forKey:@"word"];
        NSNotification *n =
        [NSNotification notificationWithName:@"AddWord" object:self userInfo:dic];
        // 通知実行！
        [[NSNotificationCenter defaultCenter] postNotification:n];
        NSLog(@">%@", out_str);
    }
	//close(pipe_ofd[1]); //エラー処理省略
	//close(pipe_ofd[0]); //エラー処理省略
}
*/
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL) textView: (UITextView*) textView shouldChangeTextInRange: (NSRange) range replacementText: (NSString*) text {
    return YES;
}
-(void)Expr {
    BOOL bk_flag=deg_or_rad_falg;
    if (auto_break_flag) {
        loadTimer = [NSTimer scheduledTimerWithTimeInterval:0.2f
                                                     target:self
                                                   selector:@selector(loadRootDictionary:)
                                                   userInfo:nil
                                                    repeats:NO];
    }
    [gcmd setCmdHistory:[text_view getText]];
    NSArray *arr=[gcmd expr:[text_view getText]];
    cmd_hlist_idx=0;
    //RunCommandList(NULL, gl_cmd_list);
    if ([arr count]<2) {
        [text_view setDataText:[NSArray arrayWithObjects:[text_view getText], @"",@"Conversion error", nil]];
    }else{
        [text_view setDataText:[NSArray arrayWithObjects:[text_view getText], [arr objectAtIndex:1],[arr objectAtIndex:2], nil]];
        //NSString *errmsg=[arr objectAtIndex:2];
        //if ([errmsg isEqualToString:@""]==NO) {
        //    gcmd=[[Command alloc] init];
        //}
    }
    //[text_view AddWord:[NSString stringWithFormat:@"=%@", pvalue]];
    [text_view showDataTextView];
    deg_or_rad_falg=bk_flag;
}
#pragma mark - Keyboard Control
- (void)keyboardWillShow:(NSNotification*)notification
{
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [[self.view superview] convertRect:keyboardRect fromView:nil];
    CGRect trect=self.view.frame;
    trect=CGRectMake(0.0, title_bar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-keyboardRect.size.height-title_bar.frame.size.height);
    text_view.frame=trect;
    [text_view resize];
    text_view.keybd=YES;
}
- (void)keybaordWillHide:(NSNotification*)notification
{
    //CGRect trect=text_view.frame;
    //trect=self.view.frame;
    text_view.frame=CGRectMake(0.0, title_bar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    [text_view resize];
    text_view.keybd=NO;
}
-(void)ChgChar {
    
}
-(void)BackChar {
    
}
-(void)cmdDown {
    cmd_hlist_idx--;
    if (cmd_hlist_idx<0) {
        cmd_hlist_idx=0;
    }
    NSString *cmdsre=[gcmd getCmdHisrory:cmd_hlist_idx];
    [text_view setText:cmdsre];
    [text_view hideDataTextView];
}
-(void)cmdUp {
    NSString *cmdsre=[gcmd getCmdHisrory:cmd_hlist_idx];
    [text_view setText:cmdsre];
    [text_view hideDataTextView];
    cmd_hlist_idx++;
}
-(void)crtLeft {
    
}
-(void)crtRight {
    
}
-(void)Calculator {
    [self.navigationController popViewControllerAnimated:NO];
}
-(void)dspChngProc {
    [text_view hideDataTextView];
}
-(void)helpAction {
    
}
-(void)editFuncAction {
    break_flag=NO;
    f_edit=YES;
    f_remove=NO;
    f_call=NO;
    NSArray *farray=[gcmd getFnameArray];
    NSMutableArray *menu_list=[[NSMutableArray alloc] init];
    [menu_list addObject:@"add func"];
    [menu_list addObjectsFromArray:farray];
    select_view=[[SelectMenuView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, text_view.frame.size.height+title_bar.frame.size.height)];
    [select_view setMenuItem:menu_list fontSize:17.0 ViewRect:CGRectMake(0.0, title_bar.frame.size.height+5, self.view.frame.size.width, text_view.frame.size.height)];
    select_view.main_delegate=self;
    [self.view addSubview:select_view];
}
-(void)callFuncAction {
    f_edit=NO;
    f_remove=NO;
    f_call=YES;
    NSMutableArray *new_array=[[NSMutableArray alloc] init];
    [new_array addObjectsFromArray:[gcmd getFnameArray]];
    [new_array addObjectsFromArray:if_array];
    select_view=[[SelectMenuView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, text_view.frame.size.height+title_bar.frame.size.height)];
    [select_view setMenuItem:new_array fontSize:15.0 ViewRect:CGRectMake(0.0, 20.0, self.view.frame.size.width, text_view.frame.size.height)];
    select_view.main_delegate=self;
    [self.view addSubview:select_view];
}
-(void)selectMenu:(NSString*)arg_str {
    if (f_edit==NO&&f_call==NO) {
        if ([arg_str isEqualToString:@"auto break off"]) {
            auto_break_flag=NO;
        }
        if ([arg_str isEqualToString:@"auto break on"]) {
            auto_break_flag=YES;
        }
        if ([arg_str isEqualToString:@"web help"]) {
            WebViewController *newview = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
            NSString *HelpUrl=NSLocalizedString(@"HelpUrl", @"HelpUrl");
            //newview.url_str=@"http://mapgrid.sakura.ne.jp/mltcalc/help.html";
            newview.url_str=HelpUrl;
            [self.navigationController pushViewController:newview animated:YES];
            newview.main_delegate=self;
            [newview setDisp];
        }
        if ([arg_str isEqualToString:@"video"]) {
            NSString *VideoUrl=NSLocalizedString(@"VideoUrl", @"VideoUrl");
            WebViewController *newview = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
            newview.url_str=VideoUrl;
            [self.navigationController pushViewController:newview animated:YES];
            newview.main_delegate=self;
            [newview setDisp];
        }
    }
    if (select_view!=nil) {
        [select_view removeFromSuperview];
        select_view=nil;
    }
    if (f_edit) {
        if ([arg_str isEqualToString:@"add func"]) {
            text_view.text=@"function newfunc(x) {\n    return (x);\n}\n";
            //NSLog(@"len=%d", [[text_view getText] length]);
        }else{
            text_view.text=[gcmd getFunctionSrc:arg_str];
            [text_view hideDataTextView];
        }
        remove_name=arg_str;
    }
    if (f_call) {
        [text_view AddCmd:arg_str];
    }
    if (f_remove) {
        remove_name=arg_str;
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"message"
                                                      message:[NSString stringWithFormat:@"remove %@ OK?", arg_str]
                                                     delegate:self
                                            cancelButtonTitle:@"NO"
                                            otherButtonTitles:@"YES", nil];
        [alert show];
    }
}
-(BOOL)saveFuncAction {
    NSArray *arr=[gcmd check:[text_view getText]];
    if (eror_flag!=0) {
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"error"
                                                      message:[arr objectAtIndex:2]
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
        [alert show];
        return NO;
    }else{
        [gcmd addFunctionSource:[arr objectAtIndex:0]];
        return YES;
    }
}
-(void)clearFuncAction {
    [text_view setText:@""];
    [text_view hideDataTextView];
}
-(void)leftButtonAction {
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)removeFunctionAction {
    [gcmd removeFunction:remove_name];
    NSNotification *n = [NSNotification notificationWithName:@"normlKeybrd" object:self];
    [[NSNotificationCenter defaultCenter] postNotification:n];
}
-(void)alertView:(UIAlertView*)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex==1) {
        [gcmd removeFunction:remove_name];
    }
}
// timeout
- (void)loadRootDictionary:(NSTimer *)theTimer {
    if (loadTimer!=nil) {
        [loadTimer invalidate];
        loadTimer=nil;
    }
    break_flag=YES;
}
-(void)rightButtonAction {
    // web
    // video
    // auto break on
    f_call=NO;
    f_edit=NO;
    f_remove=NO;
    NSLog(@"rightButtonAction");
    if (select_view!=nil) {
        [select_view removeFromSuperview];
        select_view=nil;
    }
    NSString *break_str;
    if (auto_break_flag) {
        break_str=@"auto break off";
    }else{
        break_str=@"auto break on";
    }
    select_view=[[SelectMenuView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
    [select_view setMenuItem:[NSArray arrayWithObjects:@"web help", @"video", break_str, nil] fontSize:15.0 ViewRect:CGRectMake(130.0, 20.0, self.view.frame.size.width, self.view.frame.size.height)];
    select_view.main_delegate=self;
    [self.view addSubview:select_view];
}
-(void)middleButtonAction {
    if (auto_break_flag) {
        loadTimer = [NSTimer scheduledTimerWithTimeInterval:0.2f
                                                     target:self
                                                   selector:@selector(loadRootDictionary:)
                                                   userInfo:nil
                                                    repeats:NO];
    }
    [gcmd setCmdHistory:[text_view getText]];
    NSArray *arr=[gcmd expr:[text_view getText]];
    NSString *errmsg=[arr objectAtIndex:2];
    if ([errmsg isEqualToString:@""]==NO) {
        cmd_hlist_idx=0;
        [text_view setDataText:[NSArray arrayWithObjects:[text_view getText], [arr objectAtIndex:1],[arr objectAtIndex:2], nil]];
        [text_view showDataTextView];
    }else{
        //GraphData *gitem=GetGraphData(0);
        ChartViewController *chart_view = [[ChartViewController alloc] initWithNibName:@"ChartViewController" bundle:nil];
        [self.navigationController pushViewController:chart_view animated:YES];
        NSNotification *n = [NSNotification notificationWithName:@"select_graph_view" object:self];
        [[NSNotificationCenter defaultCenter] postNotification:n];
    }
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
-(void)copyAction:(NSString*)arg_value {
    [self.navigationController popViewControllerAnimated:YES];
    //NSData *data = [arg_value dataUsingEncoding:NSUTF8StringEncoding];
    //NSData *data=[[NSData alloc] initWithBase64EncodedString:arg_value options:kNilOptions];
    //NSString *decode_str=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [text_view setText:arg_value];
    [text_view hideDataTextView];
}
-(void)addFunction:(NSString*)arg_value {
    [self.navigationController popViewControllerAnimated:YES];
    NSArray *arr=[gcmd check:arg_value];
    if (eror_flag!=0) {
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"error"
                                                      message:[arr objectAtIndex:2]
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
        [alert show];
    }else{
        [gcmd addFunctionSource:[arr objectAtIndex:0]];
    }
}
@end
