//
//  WebViewController.m
//  LinkList
//
//  Created by a2578k on 2013/09/22.
//  Copyright (c) 2013年 sogawa seiji. All rights reserved.
//

#import "WebViewController.h"

NSMutableDictionary *link_dict;

@interface WebViewController ()

@end

@implementation WebViewController
@synthesize main_delegate;
@synthesize url_str,url;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor=[UIColor grayColor];
        self.url_str=nil;
        self.url=nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    title_bar=[[TitleBarClass alloc] initWithFrame:self.view.frame];
    title_bar.delegate=self;
    [self.view addSubview:title_bar];
    [title_bar setLeftButton:@"Close" position:15];
    [title_bar setRightButton:@"Back" position:15];
    [self deleteCookie];
}
// 切替時の再描画処理
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    CGRect rect=[[UIScreen mainScreen] bounds];
    web_view=[[UIWebView alloc] initWithFrame:CGRectMake(0.0, title_bar.frame.size.height, rect.size.width, rect.size.height-title_bar.frame.size.height)];
    web_view.delegate=self;
    [self.view addSubview:web_view];
    [self performSelector:@selector(afterProc) withObject:nil afterDelay:0.5];
}
-(void)afterProc {
    if (url_str!=nil) {
        self.url=[NSURL URLWithString:url_str];
        [web_view loadRequest:[NSURLRequest requestWithURL:self.url]];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setDisp {
    if (self.url==nil) {
        if (self.url_str!=nil) {
            self.url=[NSURL URLWithString:url_str];
            [web_view loadRequest:[NSURLRequest requestWithURL:self.url]];
        }
    }
}
-(void)rightButtonAction {
    [web_view goBack];
}
-(void)middleButtonAction {
    
}
-(void)leftButtonAction {
    [self.navigationController popViewControllerAnimated:YES];
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
/*
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString* URLString = [[[request URL] standardizedURL] absoluteString];
    // copy
    if ([URLString isEqualToString:@"http://mapgrid.sakura.ne.jp/mltcalc/copy.cgi"]==YES) {
        NSString* html = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('html')[0].outerHTML"];
        NSString *input_js=@"copy;";
        NSString *input_str=[web_view stringByEvaluatingJavaScriptFromString: input_js];
        [self.main_delegate copyAction:input_str];
    }
    // add function
    return YES;
}
 */
-(void)webViewDidFinishLoad:(UIWebView*)webView{
    NSString* wurl_str = [webView stringByEvaluatingJavaScriptFromString:@"document.URL"];
    // copy
    if ([wurl_str isEqualToString:@"http://mapgrid.sakura.ne.jp/mltcalc/copy.cgi"]==YES) {
        NSString* body = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
        NSString *str2 = [body stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
        str2 = [str2 stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
        str2 = [str2 stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
        [self.main_delegate copyAction:str2];
        /*
        NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
        NSError *jsonParsingError = nil;
        NSDictionary *result_dict =[NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
        if (jsonParsingError!=nil) {
            UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle:@"error" message:@"json error"
                                      delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }else{
            //NSString *input_js=@"copy;";
            //NSString *input_str=[web_view stringByEvaluatingJavaScriptFromString: input_js];
            [self.main_delegate copyAction:[result_dict objectForKey:@"copy"]];
        }
         */
    }
    // add function
    if ([wurl_str isEqualToString:@"http://mapgrid.sakura.ne.jp/mltcalc/add_function.cgi"]==YES) {
        NSString* body = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
        NSString *str2 = [body stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
        str2 = [str2 stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
        str2 = [str2 stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
        [self.main_delegate addFunction:str2];
        /*
         NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
         NSError *jsonParsingError = nil;
         NSDictionary *result_dict =[NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
         if (jsonParsingError!=nil) {
         UIAlertView *alert =
         [[UIAlertView alloc] initWithTitle:@"error" message:@"json error"
         delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
         [alert show];
         }else{
         //NSString *input_js=@"copy;";
         //NSString *input_str=[web_view stringByEvaluatingJavaScriptFromString: input_js];
         [self.main_delegate copyAction:[result_dict objectForKey:@"copy"]];
         }
         */
    }
}
-(void)deleteCookie {
    //#ifndef HONBAN
    //    debug_text_view.text=@"deleteCookie";
    //#endif
    //if (url_str==nil) {
    //    return;
    //}
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    //NSArray* facebookCookies = [cookies cookiesForURL:[NSURL URLWithString:url_str]];
    NSArray* facebookCookies = [cookies cookies];
    
    for (NSHTTPCookie* cookie in facebookCookies) {
        [cookies deleteCookie:cookie];
    }
}
@end
