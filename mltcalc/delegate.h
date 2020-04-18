//
//  delegate.h
//  mltcalc
//
//  Created by a2578k on 2014/07/06.
//  Copyright (c) 2014年 LoftLabo. All rights reserved.
//

#ifndef mltcalc_delegate_h
#define mltcalc_delegate_h

@protocol TabBarProtocol <NSObject>
-(void)select_web_view;
-(void)select_linklist_view;
-(void)select_iadcontroll_view;
@end
@protocol MainControlProtocol <NSObject>
-(void)copyAction:(NSString*)arg_value;
-(void)addFunction:(NSString*)arg_value;

@end


#endif
