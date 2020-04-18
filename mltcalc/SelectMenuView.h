//
//  SelectMenuView.h
//  PhpEditor
//
//  Created by a2578k on 13/04/23.
//  Copyright (c) 2013年 sogawa seiji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TouchView.h"
@protocol SelectMenuProtocol <NSObject>
-(void)selectMenu:(NSString*)arg_str;
@end

@interface SelectMenuView : UIView <UITableViewDelegate,UITableViewDataSource,TouchViewProtocol> {
    TouchView *tview;
    UITableView *table_view;
    NSArray *menu_array;
    id<SelectMenuProtocol> main_delegate;
    UIFont *font;
    float font_size;
}
@property (nonatomic, retain) id<SelectMenuProtocol> main_delegate;
@property float font_size;
-(void)setMenuItem:(NSArray*)arg_array fontSize:(float)arg_size ViewRect:(CGRect)arg_view_rect;
-(void)resize:(CGSize)size;
@end
