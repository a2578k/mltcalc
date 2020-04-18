//
//  WebViewController.h
//  LinkList
//
//  Created by a2578k on 2013/09/22.
//  Copyright (c) 2013年 sogawa seiji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TitleBarClass.h"
#import "delegate.h"

@interface WebViewController : UIViewController <UIWebViewDelegate,UIScrollViewDelegate,TitleProtocol> {
    UIWebView *web_view;
    TitleBarClass *title_bar;
    NSString *url_str;
    NSURL *url;
    id<MainControlProtocol> main_delegate;
}
@property (nonatomic, retain) id<MainControlProtocol> main_delegate;
@property (nonatomic) NSString *url_str;
@property (nonatomic) NSURL *url;
-(void)setDisp;
@end
