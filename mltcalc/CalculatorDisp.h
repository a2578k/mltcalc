//
//  CalculatorDisp.h
//  TestKeyInput
//
//  Created by a2578k on 2014/05/07.
//  Copyright (c) 2014年 LoftLabo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeyboardAccessoryView.h"
@class EditTextView;

@interface CalculatorDisp : UIView <KeyboardProtocol> {
    KeyboardAccessoryView *keyboard_acc;
    EditTextView *edit_text_view;
    UITextView *data_text_view;
    NSMutableAttributedString *arg_arrtri;
    float font_size;
    BOOL keybd; 
}
@property BOOL keybd;
-(void)hideKeyboad;                          // キーボード表示
-(void)showKeyboad;                          // キーボード非表示
-(void)setText:(NSString*)arg_data_text;     // edit text にテキストをセットする
-(NSString*)getText;                         // edit textからテキストを取得する
-(void)setDataText:(NSArray*)arg_text_array; // data textにテキストをセットする
-(void)showDataTextView;                     // data textを表示する
-(void)hideDataTextView;                     // data textを非表示にする
-(void)resize;                               // resize
-(void)setDelegate:(id)arg_id;
-(id)getDelegate;
- (void)AddWord:(NSString*)arg_str;
- (void)AddCmd:(NSString*)arg_str;
-(void)deleteChar;
-(void)noEdit;
-(void)edit;
-(void)deleteWord;
-(BOOL)isEdit;
-(void)pack;
-(void)debug;
@end
