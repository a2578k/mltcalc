//
//  ChartViewController.m
//  RankingChart
//
//  Created by a2578k on 2013/11/27.
//  Copyright (c) 2013年 sogawa seiji. All rights reserved.
//

#import "ChartViewController.h"
#import "WebViewController.h"

@interface ChartViewController ()

@end

@implementation ChartViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    data_array=[[NSMutableArray alloc] init];
    title_bar=[[TitleBarClass alloc] initWithFrame:self.view.frame];
    title_bar.delegate=self;
    [self.view addSubview:title_bar];
    [title_bar setLeftButton:@"Close" position:5];
    //CGRect rect=draw_view.frame;
}
-(void)clear {
    [draw_view startDsp:[[NSMutableArray alloc] init]];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    view_hight=self.view.frame.size.height;
    draw_view=[[DrawingView alloc] initWithFrame:CGRectMake(0.0, title_bar.frame.origin.y+title_bar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-title_bar.frame.origin.y-title_bar.frame.size.height)];
    // 表示に必要なデータをセットする
    //CGRect rect=draw_view.frame;
    draw_view.backgroundColor=[UIColor blueColor];
    [self.view addSubview:draw_view];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)leftButtonAction {
    NSNotification *n = [NSNotification notificationWithName:@"select_calc_view" object:self];
    [[NSNotificationCenter defaultCenter] postNotification:n];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)rightButtonAction {
}
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
                                        duration:(NSTimeInterval)duration {
    
    CGRect rect=self.view.bounds;
    //self.view.frame=rect;
    view_hight=rect.size.height;
    [title_bar reSize:CGRectMake(0.0, 0.0, rect.size.width, title_bar.frame.size.height)];
    draw_view.frame=CGRectMake(0.0, title_bar.frame.size.height, title_bar.frame.size.width, rect.size.height-title_bar.frame.size.height);
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        [draw_view LandscapeToPortraitRotaitProc];
    }else{
        [draw_view PortraittToLandscapeRotaitProc];
    }
}
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}
-(void)middleButtonAction {
    
}
@end
