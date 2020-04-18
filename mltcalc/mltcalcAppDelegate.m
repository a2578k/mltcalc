//
//  mltcalcAppDelegate.m
//  mltcalc
//
//  Created by a2578k on 2014/04/13.
//  Copyright (c) 2014年 LoftLabo. All rights reserved.
//

#import "mltcalcAppDelegate.h"
#import "CommandContolView.h"
#import "ButtonControlView.h"
#import "ButtonControlView4v.h"
#import "Command.h"
Command *gcmd;
//int *pipefd=NULL;
//int *pipe_ofd=NULL;

@implementation mltcalcAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    CGRect rect=[[UIScreen mainScreen] bounds];
    //NSString *devstr = [[UIDevice currentDevice] platformString];
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *func_path = [documentsDirectory stringByAppendingPathComponent:@"function.json"];
    NSString *value_path = [documentsDirectory stringByAppendingPathComponent:@"default_value.txt"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:value_path]==NO) {
        NSString *initPath = [[NSBundle mainBundle] pathForResource:@"default_value" ofType:@"txt"];
        NSData *str_data=[NSData dataWithContentsOfFile:initPath];
        NSString *str_out=[[NSString alloc] initWithData:str_data encoding:NSUTF8StringEncoding];
        [str_out writeToFile:value_path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:func_path]==NO) {
        NSString *initPath = [[NSBundle mainBundle] pathForResource:@"default_function" ofType:@"json"];
        NSData *str_data=[NSData dataWithContentsOfFile:initPath];
        NSString *str_out=[[NSString alloc] initWithData:str_data encoding:NSUTF8StringEncoding];
        [str_out writeToFile:func_path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    gcmd=[[Command alloc] init];
    //[gcmd initialFile:value_path];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    if (rect.size.height>480) {
        ButtonControlView *newview = [[ButtonControlView alloc] initWithNibName:@"ButtonControlView" bundle:nil];
        navigationController=[[CustomNavigationController alloc] initWithRootViewController:newview];
    }else{
        ButtonControlView4v *newview = [[ButtonControlView4v alloc] initWithNibName:@"ButtonControlView4v" bundle:nil];
        navigationController=[[CustomNavigationController alloc] initWithRootViewController:newview];
    }
    [navigationController setNavigationBarHidden:YES animated:YES];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(select_calc_view) name:@"select_calc_view" object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(select_graph_view) name:@"select_graph_view" object:nil];
    //ChartViewController *newview = [[ChartViewController alloc] initWithNibName:@"ChartViewController" bundle:nil];
    //navigationControllerGraph=[[CustomNavigationController alloc] initWithRootViewController:newview];
    //[navigationControllerGraph setNavigationBarHidden:YES animated:YES];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
    if (pipefd!=NULL) {
        //close(STDIN_FILENO);
        if (pipefd[0]!=0) {
            close(pipefd[1]); //エラー処理省略
            close(pipefd[0]); //エラー処理省略
        }
        pipefd[0]=0;
        pipefd[1]=0;
    }
    if (pipe_ofd!=NULL) {
        if (pipe_ofd[0]!=0) {
            close(pipe_ofd[1]); //エラー処理省略
            close(pipe_ofd[0]); //エラー処理省略
        }
        pipe_ofd[0]=0;
        pipe_ofd[1]=0;
    }
     */
    NSNotification *n =[NSNotification notificationWithName:@"applicationDidEnterBackground" object:self userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:n];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSNotification *n =[NSNotification notificationWithName:@"applicationWillEnterForeground" object:self userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:n];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
// web_view切り替え
-(void)select_calc_view {
    //self.window.rootViewController = navigationController;
}
// リンクリスト切り替え
-(void)select_graph_view {
    //self.window.rootViewController = navigationControllerGraph;
}
@end
