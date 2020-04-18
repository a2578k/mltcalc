//
//  DrawingView.m
//  GraphicsTest
//
//  Created by a2578k on 2013/11/26.
//  Copyright (c) 2013年 sogawa seiji. All rights reserved.
//

#import "DrawingView.h"
#import <QuartzCore/QuartzCore.h>
extern int eror_flag;
extern BOOL break_flag;
extern NSMutableDictionary *gl_vdict;
extern double floor2(double vl);

@implementation DrawingView
@synthesize vx0,vy0,vwidth,vheight,zoom;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        item_array=[[NSMutableArray alloc] init];
        zoom=1.0;
        vx0=-160.0;
        vy0=frame.size.height/2.0;
        //UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        //[self addGestureRecognizer:panGesture];
        UIPinchGestureRecognizer* pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
        [self addGestureRecognizer:pinchGesture];
    }
    return self;
}
-(void)startDsp:(NSMutableArray*)arg_array {
    item_array=arg_array;
    [self setNeedsDisplay];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    start_location=location;
    wpt=CGPointMake(vx0, vy0);
    [self setNeedsDisplay];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    float dx=location.x-start_location.x;
    float dy=location.y-start_location.y;
    vx0=wpt.x-dx;
    vy0=wpt.y+dy;
    [self setNeedsDisplay];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setNeedsDisplay];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setNeedsDisplay];
}
//ラインの描画
- (void)drawLine:(CGContextRef)context point0:(CGPoint)arg_point0 point1:(CGPoint)arg_point1 {
    //CGContextSetLineWidth(context, 1.0);
    //CGContextSetRGBFillColor(context,0.0/255.0f,255.0/255.0f,0.0/255.0f,1.0f);
    //CGContextSetLineCap(_context,kCGLineCapRound);
    CGContextMoveToPoint(context,arg_point0.x,arg_point0.y);
    CGContextAddLineToPoint(context,arg_point1.x,arg_point1.y);
    CGContextStrokePath(context);
}
-(void)arrowLine:(CGContextRef)context point0:(CGPoint)arg_point0 point1:(CGPoint)arg_point1 {
    float f=atan2(arg_point0.y-arg_point1.y, arg_point0.x-arg_point1.x);
    float a_f=f+M_PI/8.0;
    float b_f=f-M_PI/8.0;
    [self drawLine:context point0:arg_point0 point1:arg_point1];
    [self drawLine:context point0:arg_point1 point1:CGPointMake(arg_point1.x+8.0*cos(a_f), arg_point1.y+8.0*sin(a_f))];
    [self drawLine:context point0:arg_point1 point1:CGPointMake(arg_point1.x+8.0*cos(b_f), arg_point1.y+8.0*sin(b_f))];
}
//ポリラインの描画
- (void)drawPolyline:(CGContextRef)context ptlist:(NSArray*)arg_array {
    CGContextSetLineWidth(context, 2.0);
    CGContextSetLineCap(context,kCGLineCapRound);
    CGContextSetLineJoin(context,kCGLineJoinRound);
    NSValue *start_value=[arg_array objectAtIndex:0];
    CGContextMoveToPoint(context,[start_value CGPointValue].x, [start_value CGPointValue].y);
    for (int i=1;i<[arg_array count];i++) {
        NSValue *item_value=[arg_array objectAtIndex:i];
        CGContextAddLineToPoint(context,[item_value CGPointValue].x, [item_value CGPointValue].y);
    }
    CGContextStrokePath(context);
}
//円の描画
- (void)drawCircle:(CGContextRef)context point:(CGPoint)arg_pt {
    CGContextFillEllipseInRect(context,CGRectMake(arg_pt.x-1.5,arg_pt.y-1.5,3,3));
    CGContextStrokePath(context);
}
// 描画色の設定
-(void)setStrokeColor:(CGContextRef)context color:(UIColor*)arg_color {
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;
    
    // UIColor 型の color から RGBA の値を取得します。
    [arg_color getRed:&red green:&green blue:&blue alpha:&alpha];
    CGFloat rgbary[4] = {red, green, blue, 1.0};
    CGContextSetStrokeColor(context, rgbary);
}
-(void)setStrokeRgbColor:(CGContextRef)context red:(float)a_red green:(float)a_green blue:(float)a_blue {
    CGFloat rgbary[4] = {a_red, a_green, a_blue, 1.0};
    CGContextSetStrokeColor(context, rgbary);
}
//矩形の描画
-(void)drawFillRect:(CGContextRef)context rect:(CGRect)arg_rect {
    UIColor *color=[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.7];
    //CGContextSetStrokeColorWithColor(context,color.CGColor);
    CGContextSetFillColorWithColor(context,color.CGColor);
    CGContextFillRect(context,arg_rect);
    CGContextStrokePath(context);
}
// 日付文字列の表示
-(NSString*)getDtateStr:(int)arg_idx {
    NSDate *noewdate=[NSDate date];
    NSDateComponents *comps=[[NSDateComponents alloc] init];
    [comps setDay:arg_idx];
    NSCalendar *calender=[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date=[calender dateByAddingComponents:comps toDate:noewdate options:0];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd"];
    NSString *ret_str = [formatter stringFromDate:date];
    return ret_str;
}
/*
 -(void)getNerPoint {
 for(NSMutableDictionary *item_hash in item_array) {
 NSArray *dsp_array=[item_hash objectForKey:@"dsp_array"];
 NSArray *rank_array=[item_hash objectForKey:@"rank_array"];
 float min_dp=999999.0;
 NSValue *select_value=nil;
 NSString *select_vstr=@"";
 for(NSObject *item_object in dsp_array) {
 if ([item_object isKindOfClass:[NSArray class]]) {
 NSArray *array=(NSArray*)item_object;
 for(NSValue *item_value in array) {
 CGPoint pt=[item_value CGPointValue];
 if (fabsf(pt.x-xp)<min_dp) {
 select_value=item_value;
 int vidx=[dsp_array indexOfObject:item_value];
 select_vstr=[rank_array objectAtIndex:vidx];
 }
 }
 }else if ([item_object isKindOfClass:[NSValue class]]) {
 NSValue *value=(NSValue*)item_object;
 CGPoint pt=[value CGPointValue];
 if (fabsf(pt.x-xp)<min_dp) {
 select_value=(NSValue*)item_object;
 }
 }
 }
 if (select_value!=nil) {
 [item_hash setObject:select_value forKey:@"sel_pos"];
 [item_hash setObject:[NSString stringWithFormat:@"%@:%@", [item_hash objectForKey:@"title"], [] forKey:<#(id<NSCopying>)#>
 }
 }
 }
 */
-(float)expr:(float)arg_x cline:(ExprControl*)arg_item {
    break_flag=NO;
    [gl_vdict setObject:[NSNumber numberWithFloat:arg_x] forKey:@"x"];
    if (arg_item->clist_ctl.start_pt!=NULL) {
        RunCommandList(gl_vdict, NULL, arg_item->clist_ctl.start_pt);
    }
    return GetValue(arg_item->a_array[0]);
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //グラフィックスコンテキストの取得
    CGContextRef _context=UIGraphicsGetCurrentContext();
    //[self setContext:UIGraphicsGetCurrentContext()];
	
    //色の指定
    //[self setColor_r:230 g:230 b:230];
    
    //背景の表示
    //CGContextFillEllipseInRect(_context,self.frame);
    //[self fillRect_x:0 y:0 w:self.frame.size.width h:self.frame.size.height];
    //CGRect r1 = CGRectMake(50.0 , 50.0, 100.0, 100.0);
	CGContextSetRGBFillColor(_context,22.0/255.0f,58.0/255.0f,148.0/255.0f,1.0f);
    //CGContextSetFillColorWithColor(_context, [[UIColor brownColor] CGColor]);
    //CGContextRGBStrokeColor
    CGContextAddRect(_context,CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height));
    CGContextFillPath(_context);
    //[self drawPolyline:_context ptlist:array];
    // grid
    [self setStrokeRgbColor:_context red:0.5 green:0.5 blue:0.5];
    //[self setStrokeColor:_context color:[UIColor lightGrayColor]];
    float nv=log(self.frame.size.width*zoom)/log(10.0); //
    float n=floor(log(self.frame.size.width*zoom)/log(10.0));
    if (n==nv) {
        n=1;
    }else{
        if (nv<1.0) {
            n=1;
        }else{
            n=nv-n;
        }
    }
    float dx=pow(10, n);
    float dl=32.0*zoom;
    float dv=0.5/dl;
    //int v=vx0/dx;
    //int vy=vy0/dx;
    vwidth=self.frame.size.width*zoom;
    vheight=self.frame.size.height*zoom;
    CGContextSetLineWidth(_context, 1.0);
    CGContextSetStrokeColorWithColor(_context, [[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0] CGColor]);
    int idx=0;
    for(float wx=-vx0; wx<=self.frame.size.width; wx+=dl) {
        //int gn=(vx0+wx)/dl;
        float gv=0.5*idx;
        CGContextSetStrokeColorWithColor(_context, [[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0] CGColor]);
        if ((gv-floor(gv))==0.0) {
            CGContextSetLineWidth(_context, 1.0);
            [self drawLine:_context point0:CGPointMake(wx, 0.0) point1:CGPointMake(wx, self.frame.size.height)];
            NSString *dstr=[NSString stringWithFormat:@"%g", gv];
            [dstr drawAtPoint:CGPointMake(wx+2, self.frame.size.height-20.0)
               withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                               [UIFont systemFontOfSize:11.0], NSFontAttributeName,
                               [UIColor whiteColor], NSForegroundColorAttributeName,
                               nil]];
        }else{
            CGContextSetLineWidth(_context, 0.5);
            [self drawLine:_context point0:CGPointMake(wx, 0.0) point1:CGPointMake(wx, self.frame.size.height)];
        }
        idx++;
    }
    idx=0;
    for(float wx=-vx0;wx>=0; wx-=dl) {
        //int gn=(wx-vx0)/dl;
        float gv=0.5*idx;
        CGContextSetStrokeColorWithColor(_context, [[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0] CGColor]);
        if ((gv-floor(gv))==0.0) {
            CGContextSetLineWidth(_context, 1.0);
            [self drawLine:_context point0:CGPointMake(abs(wx), 0.0) point1:CGPointMake(abs(wx), self.frame.size.height)];
            NSString *dstr=[NSString stringWithFormat:@"%g", gv];
            [dstr drawAtPoint:CGPointMake(abs(wx)+2, self.frame.size.height-20.0)
               withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                               [UIFont systemFontOfSize:11.0], NSFontAttributeName,
                               [UIColor whiteColor], NSForegroundColorAttributeName,
                               nil]];
        }else{
            CGContextSetLineWidth(_context, 0.5);
            [self drawLine:_context point0:CGPointMake(abs(wx), 0.0) point1:CGPointMake(abs(wx), self.frame.size.height)];
        }
        idx--;
    }
    //float start_value=vy0-floor2(vy0/dl)*dl;
    idx=0;
    for(float wy=vy0; wy>0; wy-=dl) {
        //int gn=wy/dl;
        float gv=0.5*idx;
        CGContextSetStrokeColorWithColor(_context, [[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0] CGColor]);
        if ((gv-floor(gv))==0.0) {
            CGContextSetLineWidth(_context, 1.0);
            [self drawLine:_context point0:CGPointMake(0.0, wy) point1:CGPointMake(self.frame.size.width, wy)];
            NSString *dstr=[NSString stringWithFormat:@"%g", gv];
            [dstr drawAtPoint:CGPointMake(2.0,wy-20)
               withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                               [UIFont systemFontOfSize:11.0], NSFontAttributeName,
                               [UIColor whiteColor], NSForegroundColorAttributeName,
                               nil]];
        }else{
            CGContextSetLineWidth(_context, 0.5);
            [self drawLine:_context point0:CGPointMake(0.0, wy) point1:CGPointMake(self.frame.size.width, wy)];
        }
        idx++;
    }
    idx=0;
    for(float wy=vy0; wy<self.frame.size.height; wy+=dl) {
        float gv=0.5*idx;
        CGContextSetStrokeColorWithColor(_context, [[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0] CGColor]);
        if ((gv-floor(gv))==0.0) {
            CGContextSetLineWidth(_context, 1.0);
            [self drawLine:_context point0:CGPointMake(0.0, wy) point1:CGPointMake(self.frame.size.width, wy)];
            NSString *dstr=[NSString stringWithFormat:@"%g", gv];
            [dstr drawAtPoint:CGPointMake(2.0,wy-20)
               withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                               [UIFont systemFontOfSize:11.0], NSFontAttributeName,
                               [UIColor whiteColor], NSForegroundColorAttributeName,
                               nil]];
        }else{
            CGContextSetLineWidth(_context, 0.5);
            [self drawLine:_context point0:CGPointMake(0.0, wy) point1:CGPointMake(self.frame.size.width, wy)];
        }
        idx--;
    }
    CGContextSetLineWidth(_context, 1.0);
    CGContextSetStrokeColorWithColor(_context, [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] CGColor]);
    [self drawLine:_context point0:CGPointMake(-vx0, 0.0) point1:CGPointMake(-vx0, self.frame.size.height)];
    [self drawLine:_context point0:CGPointMake(0.0, vy0) point1:CGPointMake(self.frame.size.width, vy0)];
    CGContextSetLineWidth(_context, 0.5);
    idx=0;
    while(true) {
        GraphData *gitem=GetGraphData(idx);
        if (gitem==NULL) {
            break;
        }
        if (idx==1) {
            NSLog(@"br");
        }
        NSString* color_name = [NSString stringWithCString: gitem->color_name encoding:NSUTF8StringEncoding];
        if ([color_name isEqualToString:@"black"]) {
            CGContextSetStrokeColorWithColor(_context, [[UIColor blackColor] CGColor]);
        }else if ([color_name isEqualToString:@"blue"]) {
            CGContextSetStrokeColorWithColor(_context, [[UIColor blueColor] CGColor]);
        }else if ([color_name isEqualToString:@"brown"]) {
            CGContextSetStrokeColorWithColor(_context, [[UIColor brownColor] CGColor]);
        }else if ([color_name isEqualToString:@"cyan"]) {
            CGContextSetStrokeColorWithColor(_context, [[UIColor cyanColor] CGColor]);
        }else if ([color_name isEqualToString:@"darkGray"]) {
            CGContextSetStrokeColorWithColor(_context, [[UIColor darkGrayColor] CGColor]);
        }else if ([color_name isEqualToString:@"gray"]) {
            CGContextSetStrokeColorWithColor(_context, [[UIColor grayColor] CGColor]);
        }else if ([color_name isEqualToString:@"green"]) {
            CGContextSetStrokeColorWithColor(_context, [[UIColor greenColor] CGColor]);
        }else if ([color_name isEqualToString:@"lightGray"]) {
            CGContextSetStrokeColorWithColor(_context, [[UIColor lightGrayColor] CGColor]);
        }else if ([color_name isEqualToString:@"magenta"]) {
            CGContextSetStrokeColorWithColor(_context, [[UIColor magentaColor] CGColor]);
        }else if ([color_name isEqualToString:@"orange"]) {
            CGContextSetStrokeColorWithColor(_context, [[UIColor orangeColor] CGColor]);
        }else if ([color_name isEqualToString:@"purple"]) {
            CGContextSetStrokeColorWithColor(_context, [[UIColor purpleColor] CGColor]);
        }else if ([color_name isEqualToString:@"red"]) {
            CGContextSetStrokeColorWithColor(_context, [[UIColor redColor] CGColor]);
        }else if ([color_name isEqualToString:@"white"]) {
            CGContextSetStrokeColorWithColor(_context, [[UIColor whiteColor] CGColor]);
        }else if ([color_name isEqualToString:@"yellow"]) {
            CGContextSetStrokeColorWithColor(_context, [[UIColor yellowColor] CGColor]);
        }else if ([color_name isEqualToString:@"darkText"]) {
            CGContextSetStrokeColorWithColor(_context, [[UIColor darkTextColor] CGColor]);
        }else{
            CGContextSetStrokeColorWithColor(_context, [[UIColor blackColor] CGColor]);
        }
        [item_array removeAllObjects];
        //[self setStrokeRgbColor:_context red:0.0 green:1.0 blue:1.0];
        //double wxd=320.0
        for(float dx=vx0; dx<=vx0+self.frame.size.width; dx++) {
            float wx=dv*dx;
            float wy=[self expr:wx cline:gitem->exp_item];
            float y=wy/dv;
            CGPoint pt=CGPointMake(dx-vx0, vy0-y);
            [item_array addObject:[NSValue valueWithCGPoint:pt]];
        }
        /*
         for(double wx=vx0/zoom; wx<((vwidth+vx0)/zoom); wx++) {
         double wy=[self expr:wx cline:gitem->exp_item];
         //if (wx==2.0) {
         //    NSLog(@"x,y=(%f,%f)", (wx-vx0)/zoom, (wy-vy0)/zoom);
         //}
         //if (wx==3.0) {
         //    NSLog(@"x,y=(%f,%f)", (wx-vx0)/zoom, (wy-vy0)/zoom);
         //}
         
         CGPoint pt=CGPointMake((wx-vx0)/zoom, self.frame.size.height-(wy-vy0)/zoom);
         [item_array addObject:[NSValue valueWithCGPoint:pt]];
         }
         */
        [self drawPolyline:_context ptlist:item_array];
        idx++;
    }
    //[self drawPolyline:_context ptlist:item_array];
    //CGContextSetFillColorWithColor(_context, [[UIColor lightGrayColor] CGColor]);
    //[self drawFillRect:_context rect:CGRectMake(vx0-50.0, vy0-50.0, 100.0, 100.0)];
}
- (void) handlePanGesture:(UIPanGestureRecognizer*) sender {
    UIPanGestureRecognizer* pan = (UIPanGestureRecognizer*) sender;
    if (pan.state==UIGestureRecognizerStateBegan) {
        start_location=[pan velocityInView:self];
        wpt=CGPointMake(vx0, vy0);
        [self setNeedsDisplay];
    }else if (pan.state==UIGestureRecognizerStateChanged) {
        CGPoint location = [pan velocityInView:self];
        float dx=location.x-start_location.x;
        float dy=location.y-start_location.y;
        vx0=wpt.x+dx;
        vy0=wpt.y+dy;
        [self setNeedsDisplay];
        NSLog(@"pan vx=%f, vy=%f(%f,%f)", vx0, vy0, dx, dy);
    }else if (pan.state==UIGestureRecognizerStateEnded) {
        CGPoint location = [pan velocityInView:self];
        //float dx=location.x-start_location.x;
        //float dy=location.y-start_location.y;
    }
    //CGPoint location = [pan translationInView:self];
}
- (void) handlePinchGesture:(UIPinchGestureRecognizer*) sender {
    UIPinchGestureRecognizer* pinch = (UIPinchGestureRecognizer*)sender;
    NSLog(@"scale=%f", pinch.scale);
    zoom=pinch.scale;
    [self setNeedsDisplay];
    NSLog(@"pinch scale=%f, velocity=%f", zoom, pinch.velocity);
}
-(void)PortraittToLandscapeRotaitProc {
    NSLog(@"W=%F,H=%F", self.frame.size.width, self.frame.size.height);
    float dl=32.0*zoom;
    vx0=vx0+320.0/2.0-self.frame.size.width/2.0;
    vy0=vy0-self.frame.size.width/2.0+dl/2.0;
    [self setNeedsDisplay];
}
-(void)LandscapeToPortraitRotaitProc {
    NSLog(@"W=%F,H=%F", self.frame.size.width, self.frame.size.height);
    vx0=vx0+self.frame.size.height/2.0-320.0/2.0;
    vy0=vy0-320.0/2.0+self.frame.size.height/2.0;
    [self setNeedsDisplay];
}

@end
