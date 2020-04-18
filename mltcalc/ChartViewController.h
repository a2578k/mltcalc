//
//  ChartViewController.h
//  RankingChart
//
//  Created by a2578k on 2013/11/27.
//  Copyright (c) 2013年 sogawa seiji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "delegate.h"
#import "TitleBarClass.h"
#import "DrawingView.h"

@protocol ChartViewProtocol <NSObject>
-(void)closeView;
@end

@interface ChartViewController : UIViewController <TitleProtocol> {
    id<ChartViewProtocol> delegate;
    TitleBarClass *title_bar;
    DrawingView *draw_view;
    float view_hight;
    NSMutableArray *data_array;
}
@property (nonatomic, retain) id<ChartViewProtocol> delegate;
-(void)clear;
@end
