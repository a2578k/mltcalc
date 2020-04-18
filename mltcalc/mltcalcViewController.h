//
//  mltcalcViewController.h
//  mltcalc
//
//  Created by a2578k on 2014/04/13.
//  Copyright (c) 2014年 LoftLabo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalculatorDisp.h"

@interface mltcalcViewController : UIViewController {
	int pipefd[2];
    CalculatorDisp *clc_disp;
}

@end
