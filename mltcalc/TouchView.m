//
//  TouchView.m
//  Hoken
//
//  Created by a2578k on 13/01/05.
//  Copyright (c) 2013年 a2578k. All rights reserved.
//

#import "TouchView.h"

@implementation TouchView
@synthesize delegate;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor= [[UIColor blackColor] colorWithAlphaComponent:0.3f];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.delegate touviewAction];
}
-(void)touchesMoved:
(NSSet *)touches
          withEvent:(UIEvent *)event {
    
}
-(void)touchesEnded:
(NSSet *)touches
          withEvent:(UIEvent *)event {
    
}
-(void)touchesCancelled:
(NSSet *)touches
              withEvent:(UIEvent *)event {
    
}
-(void)motionBegan:
(UIEventSubtype)motion
         withEvent:(UIEvent *)event {
    
}
-(void)motionEnded:
(UIEventSubtype)motion
         withEvent:(UIEvent *)event {
    
}
-(void)motionCancelled:
(UIEventSubtype)motion
             withEvent:(UIEvent *)event {
    
}
@end
