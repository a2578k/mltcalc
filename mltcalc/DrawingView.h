//
//  DrawingView.h
//  GraphicsTest
//
//  Created by a2578k on 2013/11/26.
//  Copyright (c) 2013年 sogawa seiji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Command.h"
#include "calc.h"

@interface DrawingView : UIView {
    float vx0;
    float vy0;
    float vwidth;
    float vheight;
    float zoom;
    NSMutableArray *item_array;
    CGPoint start_location;
    CGPoint wpt;
}
@property float vx0;
@property float vy0;
@property float vwidth;
@property float vheight;
@property float zoom;
-(void)startDsp:(NSMutableArray*)arg_array;
// 仮想座標x0
// 仮想座標y0
// 仮想座標width
// 仮想座標height
-(float)expr:(float)arg_x cline:(ExprControl*)arg_item;
-(void)potaitProc;
-(void)PortraittToLandscapeRotaitProc;
-(void)LandscapeToPortraitRotaitProc;
@end
