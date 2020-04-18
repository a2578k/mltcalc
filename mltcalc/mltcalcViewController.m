//
//  mltcalcViewController.m
//  mltcalc
//
//  Created by a2578k on 2014/04/13.
//  Copyright (c) 2014年 LoftLabo. All rights reserved.
//

#import "mltcalcViewController.h"
#include <signal.h>
extern FILE *yyin;
extern FILE *yyout;
extern int yyparse(void);
char   is_std_in;

@interface mltcalcViewController ()

@end

@implementation mltcalcViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // text view
    clc_disp=[[CalculatorDisp alloc] initWithFrame:CGRectMake(0.0, 20.0, self.view.frame.size.width, self.view.frame.size.height-20.0)];
    [self.view addSubview:clc_disp];
    //NSLog(@"%p", stdin);
    //NSLog(@"%p", stdout);
	if (pipe(pipefd) < 0) {
		perror("pipe");
		
	}
    is_std_in=TRUE;
    dup2(pipefd[0], STDIN_FILENO); //パイプの読み込みを標準入力につなぐ
    close(pipefd[0]);              //つないだらパイプはクローズする
	// パイプへの書き込み
    //[self pipeMonitoring:pipefd[0]];
	// パイプからの読み込み
	//close(pipefd[1]); //エラー処理省略
	//close(pipefd[0]); //エラー処理省略
    [self performSelectorInBackground:@selector(stdoutMonitaring) withObject:nil];
    [self performSelectorInBackground:@selector(yyparseProc) withObject:nil];
    //[self performSelector:@selector(outPrint) withObject:nil afterDelay:1.5];
}
-(void)outPrint {
	char *s = "1+2\n";
	write(pipefd[1], s, strlen(s)); //エラー処理省略
}
-(void)yyparseProc {
    yyparse ();
}
-(void)stdoutMonitaring {
	int wpipefd[2];
	if (pipe(wpipefd) < 0) {
		perror("pipe");
		exit(-1);
	}
    dup2(wpipefd[1], STDOUT_FILENO);
    close(wpipefd[1]);
    char buf[128];
    NSLog(@"read");
    while(1) {
        if (read(wpipefd[0], buf, sizeof buf)==-1) {
            break;
        }
        NSString* str = [NSString stringWithCString: buf encoding:NSUTF8StringEncoding];
        NSLog(@"%@", str);
    }
	close(wpipefd[1]); //エラー処理省略
	close(wpipefd[0]); //エラー処理省略
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
