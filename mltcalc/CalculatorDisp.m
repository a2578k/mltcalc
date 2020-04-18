//
//  CalculatorDisp.m
//  TestKeyInput
//
//  Created by a2578k on 2014/05/07.
//  Copyright (c) 2014年 LoftLabo. All rights reserved.
//

#import "CalculatorDisp.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>

@interface EditTextView : UITextView <UIKeyInput> {
    BOOL send_flag;
}
@property BOOL send_flag;

@end

@implementation EditTextView
@synthesize send_flag;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        send_flag=NO;
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
- (void)insertText:(NSString *)text {
    [super insertText:text];
    NSLog(@"%@", text);
    if (send_flag) {
        NSNotification *n =
        [NSNotification notificationWithName:@"DispChng" object:self userInfo:nil];
        // 通知実行！
        [[NSNotificationCenter defaultCenter] postNotification:n];
    }
}

@end

@implementation CalculatorDisp
@synthesize keybd;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        keybd=NO;
        font_size=20;
        NSUserDefaults *defs=[NSUserDefaults standardUserDefaults];
        NSString *font_size_str=[defs objectForKey:@"font_size_str"];
        if (font_size_str!=nil) {
            font_size=[font_size_str floatValue];
        }
        self.layer.cornerRadius = 5;
        self.clipsToBounds = true;
        //self.backgroundColor=[[UIColor alloc] initWithRed:0.0 green:0.945 blue:0.945 alpha:1.0];
        self.backgroundColor=[UIColor grayColor];
        edit_text_view=[[EditTextView alloc] initWithFrame:CGRectMake(2.0, 2.0, frame.size.width-4, frame.size.height-4)];
        //edit_text_view.backgroundColor=[[UIColor alloc] initWithRed:0.4 green:0.5 blue:0.7 alpha:1.0];
        edit_text_view.backgroundColor=[UIColor lightGrayColor];
        //edit_text_view.textColor=[[UIColor alloc] initWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
        edit_text_view.textColor=[UIColor blackColor];
        data_text_view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:edit_text_view];
        edit_text_view.text=@"";
        //edit_text_view.contentOffset=CGPointMake(0.0, 0.0);
        //[edit_text_view setContentOffset:CGPointMake(0.0, 0.0)];
        [edit_text_view setFont:[UIFont systemFontOfSize:font_size]];
        [self addSubview:edit_text_view];
        data_text_view=[[UITextView alloc] initWithFrame:CGRectMake(2.0, 2.0, frame.size.width-4, frame.size.height-4)];
        data_text_view.hidden=YES;
        data_text_view.backgroundColor=[[UIColor alloc] initWithRed:0.4 green:0.5 blue:0.7 alpha:1.0];
        data_text_view.textColor=[UIColor greenColor];
        data_text_view.editable=NO;
        [data_text_view setFont:[UIFont systemFontOfSize:font_size]];
        [self addSubview:data_text_view];
        keyboard_acc=[[KeyboardAccessoryView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, 32.0)];
        keyboard_acc.delegate=self;
        edit_text_view.inputAccessoryView=keyboard_acc;
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc]
                                                  initWithTarget:self action:@selector(handlePinchGesture:)];
        [edit_text_view addGestureRecognizer:pinchGesture];
        UITapGestureRecognizer* doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
        doubleTapGesture.numberOfTapsRequired = 2;
        [data_text_view addGestureRecognizer:doubleTapGesture];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AddWord:) name:@"AddWord" object:nil];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        keybd=NO;
        font_size=20;
        NSUserDefaults *defs=[NSUserDefaults standardUserDefaults];
        NSString *font_size_str=[defs objectForKey:@"font_size_str"];
        if (font_size_str!=nil) {
            font_size=[font_size_str floatValue];
        }
        CGRect frame=self.frame;
        self.layer.cornerRadius = 5;
        self.clipsToBounds = true;
        self.backgroundColor=[UIColor grayColor];
        edit_text_view=[[EditTextView alloc] initWithFrame:CGRectMake(2.0, 2.0, frame.size.width-4, frame.size.height-4)];
        //edit_text_view.backgroundColor=[[UIColor alloc] initWithRed:0.4 green:0.5 blue:0.7 alpha:1.0];
        edit_text_view.backgroundColor=[UIColor lightGrayColor];
        //edit_text_view.textColor=[[UIColor alloc] initWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
        edit_text_view.textColor=[UIColor blackColor];
        data_text_view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        data_text_view.backgroundColor=[UIColor lightGrayColor];
        [self addSubview:edit_text_view];
        edit_text_view.text=@"";
        //edit_text_view.contentOffset=CGPointMake(0.0, 0.0);
        //[edit_text_view setContentOffset:CGPointMake(0.0, 0.0)];
        [edit_text_view setFont:[UIFont systemFontOfSize:font_size]];
        [self addSubview:edit_text_view];
        data_text_view=[[UITextView alloc] initWithFrame:CGRectMake(2.0, 2.0, frame.size.width-4, frame.size.height-4)];
        data_text_view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        data_text_view.hidden=YES;
        data_text_view.backgroundColor=[[UIColor alloc] initWithRed:0.4 green:0.5 blue:0.7 alpha:1.0];
        //edit_text_view.backgroundColor=[[UIColor alloc] initWithRed:0.4 green:0.5 blue:0.7 alpha:1.0];
        data_text_view.textColor=[UIColor greenColor];
        data_text_view.editable=NO;
        [data_text_view setFont:[UIFont systemFontOfSize:font_size]];
        [self addSubview:data_text_view];
        keyboard_acc=[[KeyboardAccessoryView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, 32.0)];
        keyboard_acc.delegate=self;
        edit_text_view.inputAccessoryView=keyboard_acc;
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc]
                                                  initWithTarget:self action:@selector(handlePinchGesture:)];
        [edit_text_view addGestureRecognizer:pinchGesture];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AddWord:) name:@"AddWord" object:nil];
    }
    return self;
    
}
-(void)setAttribute {
    
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */
-(void)noEdit {
    edit_text_view.editable=NO;
    edit_text_view.inputAccessoryView=nil;
}
-(void)edit {
    edit_text_view.editable=YES;
    edit_text_view.inputAccessoryView=keyboard_acc;
}
// キーボード非表示
-(void)hideKeyboad {
    [edit_text_view resignFirstResponder];
}
// キーボード表示
-(void)showKeyboad {
    [edit_text_view becomeFirstResponder];
}
// edit text にテキストをセットする
-(void)setDataText:(NSArray*)arg_text_array {
    NSString *ww=[NSString stringWithFormat:@"%@\n%@", [arg_text_array objectAtIndex:0], [arg_text_array objectAtIndex:1]];
    long ww_len=[ww length];
    NSString *err=[arg_text_array objectAtIndex:2];
    /*
    NSDictionary *stringAttributes1 = @{ NSForegroundColorAttributeName : [UIColor whiteColor],
                                         NSFontAttributeName : [UIFont systemFontOfSize:font_size-4] };
    NSDictionary *stringAttributes2;
    if ([err length]==0) {
        stringAttributes2 = @{ NSForegroundColorAttributeName : [UIColor greenColor],
                                             NSFontAttributeName : [UIFont systemFontOfSize:font_size] };
    }else{
        stringAttributes2 = @{ NSForegroundColorAttributeName : [UIColor greenColor],
                               NSFontAttributeName : [UIFont systemFontOfSize:font_size-4] };
    }
    NSDictionary *stringAttributes3 = @{ NSForegroundColorAttributeName : [UIColor orangeColor],
                                         NSFontAttributeName : [UIFont systemFontOfSize:font_size] };
    NSAttributedString *string1 = [[NSAttributedString alloc] initWithString:[arg_text_array objectAtIndex:0]
                                                                  attributes:stringAttributes1];
    NSAttributedString *string2 = [[NSAttributedString alloc] initWithString:[arg_text_array objectAtIndex:1]
                                                                  attributes:stringAttributes2];
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
    if ([err length]>0) {
        NSAttributedString *string3 = [[NSAttributedString alloc] initWithString:[arg_text_array objectAtIndex:2]
                                                                      attributes:stringAttributes3];
        [mutableAttributedString appendAttributedString:string1];
        [mutableAttributedString appendAttributedString:string2];
        [mutableAttributedString appendAttributedString:string3];
    }else{
        [mutableAttributedString appendAttributedString:string1];
        [mutableAttributedString appendAttributedString:string2];
    }
    [data_text_view setAttributedText:mutableAttributedString];
     */
    if ([err isEqualToString:@""]==NO) {
        ww=[NSString stringWithFormat:@"%@\n%@", ww, err];
        long src_len=[[arg_text_array objectAtIndex:0] length];
        long out_len=[[arg_text_array objectAtIndex:1] length];
        data_text_view.text=ww;
        arg_arrtri=[[NSMutableAttributedString alloc] initWithString:data_text_view.text];
        [arg_arrtri addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]
                           range:NSMakeRange(0, src_len)];
        [arg_arrtri addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:font_size-4] range:NSMakeRange(0, src_len)];
        [arg_arrtri addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor]
                           range:NSMakeRange(src_len+1, out_len)];
        [arg_arrtri addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:font_size-4] range:NSMakeRange(src_len+1, out_len)];
        [arg_arrtri addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor]
                           range:NSMakeRange(ww_len+1, [err length])];
        [arg_arrtri addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:font_size] range:NSMakeRange(ww_len+1, [err length])];
        [data_text_view setAttributedText:arg_arrtri];
    }else{
        data_text_view.text=ww;
        long src_len=[[arg_text_array objectAtIndex:0] length];
        long out_len=[[arg_text_array objectAtIndex:1] length];
        arg_arrtri=[[NSMutableAttributedString alloc] initWithString:data_text_view.text];
        [arg_arrtri addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]
                           range:NSMakeRange(0, src_len)];
        [arg_arrtri addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:font_size-4] range:NSMakeRange(0, src_len)];
        [arg_arrtri addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor]
                           range:NSMakeRange(src_len+1, out_len)];
        [arg_arrtri addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:font_size] range:NSMakeRange(src_len+1, out_len)];
        [data_text_view setAttributedText:arg_arrtri];
    }
}
// edit textからテキストを取得する
-(NSString*)getText {
    return edit_text_view.text;
}
// edit text にテキストをセットする
-(void)setText:(NSString*)arg_data_text {
    edit_text_view.text=arg_data_text;
}
// data textを表示する
-(void)showDataTextView {
    //CGRect recta=edit_text_view.frame;
    //CGRect rectb=data_text_view.frame;
    data_text_view.hidden=NO;
    edit_text_view.send_flag=YES;
    [data_text_view setFont:[UIFont systemFontOfSize:font_size]];
}
// data textを非表示にする
-(void)hideDataTextView {
    data_text_view.hidden=YES;
    edit_text_view.send_flag=NO;
}
// resize
-(void)resize {
    CGRect rect=self.frame;
    CGPoint pt=edit_text_view.contentOffset;
    CGRect trect=edit_text_view.frame;
    CGRect drect=data_text_view.frame;
    NSLog(@"t_x=%f,t_y=%f", trect.origin.x, trect.origin.y);
    //edit_text_view.contentOffset=CGPointMake(0.0, 0.0);
    edit_text_view.frame=CGRectMake(2.0, 2.0, rect.size.width-4, rect.size.height-4);
    edit_text_view.contentSize=CGSizeMake(rect.size.width, rect.size.height);
    data_text_view.frame=CGRectMake(2.0, 2.0, rect.size.width-4, rect.size.height-4);
    data_text_view.contentSize=CGSizeMake(rect.size.width, rect.size.height);
    if (pt.y<0.0) {
        CGRect trect=edit_text_view.frame;
        edit_text_view.frame=trect;
        [edit_text_view setContentOffset:CGPointMake(0.0, 0.0)];
    }
    [self setNeedsDisplay];
}
-(void)ChgChar {
    
}
-(void)BackChar {
    
}
-(void)crtDown {
    
}
-(void)crtUp {
    
}
-(void)crtLeft {
    
}
-(void)crtRight {
    
}
-(void)crtDelete {
    
}
- (id)currentRate {
    return edit_text_view.delegate;
}
-(id)getDelegate {
    return edit_text_view.delegate;
}
-(void)setDelegate:(id)arg_id {
    keyboard_acc.delegate=arg_id;
    edit_text_view.delegate=arg_id;
}
- (void)AddWord:(NSString*)arg_str {
    // 通知の送信側から送られた値を取得する
    //NSString *value = [[notification userInfo] objectForKey:@"word"];
    //dispatch_async(dispatch_get_main_queue(), ^{
        data_text_view.text=[data_text_view.text stringByAppendingString:arg_str];
    //});
}
- (void)AddCmd:(NSString*)arg_str {
    if (data_text_view.hidden==NO) {
        edit_text_view.text=@"";
        data_text_view.hidden=YES;
    }
    edit_text_view.text=[edit_text_view.text stringByAppendingString:arg_str];
}
-(void)deleteWord {
    NSArray *carry=[NSArray arrayWithObjects:@"(",@")",@"+",@"-",@"*", @"/",nil];
    long lpt=-1;
    NSString *hword=@"";
    for(NSString *sword in carry) {
        NSRange trng=[edit_text_view.text rangeOfString:sword options:NSBackwardsSearch range:NSMakeRange([edit_text_view.text length], [edit_text_view.text length])];
        if (trng.location!=-1) {
            if (lpt>trng.location) {
                lpt=trng.location;
                hword=sword;
            }
        }
    }
}
-(BOOL)isEdit {
    if (data_text_view.hidden) {
        return YES;
    }else{
        return NO;
    }
}
-(void)deleteChar {
    if ([edit_text_view.text length]==0) {
        return;
    }
    edit_text_view.text=[edit_text_view.text substringWithRange:NSMakeRange(0, [edit_text_view.text length]-1)];
}
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)sender {
    CGFloat factor = [(UIPinchGestureRecognizer *)sender scale];
    [edit_text_view setFont:[UIFont systemFontOfSize:font_size*factor]];
    if (sender.state == UIGestureRecognizerStateEnded) {
        NSUserDefaults *defs=[NSUserDefaults standardUserDefaults];
        font_size=font_size*factor;
        /*
        if (font_size<8) {
            font_size=8;
            [edit_text_view setFont:[UIFont systemFontOfSize:font_size]];
        }
        if (font_size>30) {
            font_size=30;
            [edit_text_view setFont:[UIFont systemFontOfSize:font_size]];
        }
         */
        [defs setObject:[NSString stringWithFormat:@"%f", font_size] forKey:@"font_size_str"];
    }
 }
-(void)pack {
    edit_text_view.text=[NSString stringWithFormat:@"(%@)", edit_text_view.text];
}
- (void) handleDoubleTapGesture:(UITapGestureRecognizer*)sender {
    if (!keybd) {
        [self hideDataTextView];
        [self showKeyboad];
    }else{
        [self hideKeyboad];
    }
}
-(void)debug {
    CGRect trect=edit_text_view.frame;
    CGRect drect=data_text_view.frame;
    NSLog(@"");
}
@end
