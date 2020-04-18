//
//  TouchView.h
//  Hoken
//
//  Created by a2578k on 13/01/05.
//  Copyright (c) 2013年 a2578k. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TouchViewProtocol <NSObject>
-(void)touviewAction;
@end

@interface TouchView : UIView {
    id<TouchViewProtocol> delegate;
}
@property (nonatomic, retain) id<TouchViewProtocol> delegate;

@end
