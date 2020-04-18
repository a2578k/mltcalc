//
//  SelectMenuView.m
//  PhpEditor
//
//  Created by a2578k on 13/04/23.
//  Copyright (c) 2013年 sogawa seiji. All rights reserved.
//

#import "SelectMenuView.h"
#import <QuartzCore/QuartzCore.h>

@implementation SelectMenuView
@synthesize main_delegate;
@synthesize font_size;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        tview=[[TouchView alloc] initWithFrame:frame];
        tview.delegate=self;
        [self addSubview:tview];
        //self.frame=frame;
        //self.backgroundColor=[UIColor whiteColor];
        //self.layer.borderWidth = 1.0f;    //ボーダーの幅
    }
    return self;
}
#pragma 表示属性設定
-(void)setMenuItem:(NSArray*)arg_array fontSize:(float)arg_size ViewRect:(CGRect)arg_view_rect {
    //float iOSVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    font = [UIFont systemFontOfSize:arg_size];
    font_size=arg_size;
    float max_width=0.0;
    for(NSString *item in arg_array) {
        CGSize size;
        size=[item sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:arg_size]}];
        if (size.width>max_width) {
            max_width=size.width;
        }
    }
    CGRect rect=arg_view_rect;
    rect.size.width=max_width+36.0;
    rect.size.height=[arg_array count] * (font_size+12.0)+6.0;
    //rect.origin.y=rect.origin.y-rect.size.height/2.0;
    //rect.origin.x+=font_size*3;
    // right限界
    if ((rect.origin.x+rect.size.width+font_size*3)>self.frame.size.width) {
        if ((rect.size.width+font_size*3)<rect.origin.x) {
            rect.origin.x=self.frame.size.width-font_size-rect.size.width;
        }else{
            rect.origin.x=self.frame.size.width-rect.size.width;
        }
    }
    // left限界
    if (rect.origin.x < 5.0) {
        rect.origin.x=5.0;
    }
    // top限界
    if (rect.origin.y<5.0) {
        rect.origin.y=5.0;
    }
    // bottom限界
    if ((rect.origin.y+rect.size.height)>arg_view_rect.size.height) {
        rect.size.height=arg_view_rect.size.height;
    }
    //self.frame=rect;
    //WakuView *new_view=[[WakuView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
    //[self addSubview:new_view];
    //rect.origin.y=3.0;
    //rect.origin.x=3.0;
    rect.size.width-=6.0;
    rect.size.height-=6.0;
    //table_view=[[UITableView alloc] initWithFrame:CGRectMake(3.0, 3.0, max_width+20.0, [arg_array count] * (font_size+12.0))];
    table_view=[[UITableView alloc] initWithFrame:rect];
    table_view.delegate=self;
    table_view.dataSource=self;
    table_view.backgroundColor=[UIColor whiteColor];
    table_view.layer.borderWidth = 0.5f;    //ボーダーの幅
    main_delegate=nil;
    menu_array=arg_array;
    [tview addSubview:table_view];
    [table_view reloadData];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [menu_array count];
}

//テーブルセルの高さを設定
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return font_size+12.0;
}
// cell 表示内容
- (UITableViewCell *)tableView:(UITableView *)arg_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [table_view dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSString *label_text=[menu_array objectAtIndex:indexPath.row];
    CGSize size;
    float iOSVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (iOSVersion>=7.0) {
        size=[label_text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:font_size]}];
    }else{
        size = [label_text sizeWithFont:[UIFont systemFontOfSize:font_size] constrainedToSize:CGSizeMake(320.0, 10.0) lineBreakMode:NSLineBreakByWordWrapping];
    }
    cell.textLabel.text=label_text;
    cell.textLabel.font=font;
    CGRect rect=cell.textLabel.frame;
    rect.size.width=size.width;
    rect.size.height=size.height;
    cell.textLabel.frame=rect;
    return cell;
}
// cell 選択
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.main_delegate selectMenu:[menu_array objectAtIndex:indexPath.row]];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */
-(void)resize:(CGSize)size {
    if ((self.frame.origin.y+self.frame.size.height)>size.height) {
        CGRect rect=self.frame;
        rect.size=CGSizeMake(self.frame.size.width, size.height-rect.origin.y);
        self.frame=rect;
        rect.origin.y=3.0;
        rect.origin.x=3.0;
        rect.size.width-=6.0;
        rect.size.height-=6.0;
        table_view.frame=rect;
    }
}
-(void)touviewAction {
    [self removeFromSuperview];
}
@end
