//
//  Command.h
//  mltcalc
//
//  Created by a2578k on 2014/05/15.
//  Copyright (c) 2014年 LoftLabo. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "calc.h"
@interface Command : NSObject {
    NSString *out_path;
    NSMutableArray *fname_array;
    //NSMutableDictionary *fnc_dict;
    NSMutableArray *cmd_hlist;
    NSMutableArray *cal_hlist;
    NSString* fnamestr;
}

-(NSArray*)expr:(NSString*)arg_cmd;
-(NSArray*)check:(NSString*)arg_cmd;
-(void)initialFile:(NSString*)arg_path;
-(void)initialFunctionFile:(NSString*)arg_path;
-(NSArray*)getFnameArray;
-(BOOL)addFunction:(NSString*)arg_txt;
-(void)addFunctionSource:(NSString*)arg_value;
-(void)saveFunction;
-(void)saveFunctionSrc;
-(NSString*)getFunction:(NSString*)arg_txt;
-(NSString*)getFunctionSrc:(NSString*)arg_txt;
-(void)setCmdHistory:(NSString*)arg_cmd;// コマンド履歴に１件
-(NSString*)getCmdHisrory:(int)arg_idx;
-(void)setCalHistory:(NSString*)arg_cmd;// コマンド履歴に１件
-(NSString*)getCalHisrory:(int)arg_idx;
-(NSString*)functionParse:(NSString*)arg_str;
-(void)removeFunction:(NSString*)arg_fname;
-(NSString*)getAllFunctionStr;
BOOL RunCommandList(NSMutableDictionary *arg_dict,TokenControl *rval,CommandList *cmd_list);
@end
