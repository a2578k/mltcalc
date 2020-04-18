//
//  CustomNavigationController.m
//  pasyaLauncher
//
//  Created by a2578k on 13/01/30.
//  Copyright (c) 2013年 sogawa seiji. All rights reserved.
//

#import "CustomNavigationController.h"

@interface CustomNavigationController ()

@end

@implementation CustomNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    rflag=NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(select_calc_view) name:@"select_calc_view" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(select_graph_view) name:@"select_graph_view" object:nil];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
 - (NSUInteger)supportedInterfaceOrientations{
 return UIInterfaceOrientationMaskLandscape;
 }
 */

// ios6 初期向き
- (NSUInteger)supportedInterfaceOrientations{
    return [self.viewControllers.lastObject supportedInterfaceOrientations];
}

- (BOOL)shouldAutorotate{
    return [self.viewControllers.lastObject shouldAutorotate];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return [self.viewControllers.lastObject preferredInterfaceOrientationForPresentation];
}
// web_view切り替え
-(void)select_calc_view {
    rflag=NO;
}
// リンクリスト切り替え
-(void)select_graph_view {
    rflag=YES;
}
@end
