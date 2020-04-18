//
//  mltcalcAppDelegate.h
//  mltcalc
//
//  Created by a2578k on 2014/04/13.
//  Copyright (c) 2014年 LoftLabo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavigationController.h"
#import "ChartViewController.h"

@interface mltcalcAppDelegate : UIResponder <UIApplicationDelegate> {
    CustomNavigationController *navigationController;
    //CustomNavigationController *navigationControllerGraph;
}

@property (strong, nonatomic) UIWindow *window;

@end
