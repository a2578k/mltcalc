//
//  Command.m
//  mltcalc
//
//  Created by a2578k on 2014/05/15.
//  Copyright (c) 2014年 LoftLabo. All rights reserved.
//

#import "Command.h"
#include <signal.h>
//#include "global.h"
//#include "proto.h"
extern FILE *yyin;
extern FILE *yyout;
extern FILE *mlout;
extern int linenumber;
extern BOOL break_flag;
FILE *app_out;
FILE *error_out;
extern int yyparse(void);
extern int eror_flag;
char   is_std_in;
extern BOOL deg_or_rad_falg;
extern int yylex_destroy (void );
CommandList *gl_cmd_list;
CommandList *gl_cmd_list_end;
ArgumentList *gl_fnc_list;
NSMutableDictionary *gl_vdict;
NSMutableDictionary *gl_fnc_vdict;
NSMutableDictionary *gl_fnc_cmdlst;
NSMutableDictionary *gl_fnc_srclst;
TokenControl *return_value;
MemoryControll *gl_memctl=NULL;
MemoryControll *gl_graph_list=NULL;

MemoryControll *addMemory(MemoryControll *arg_ctl, void *arg_mem) {
    MemoryControll *ret_val=(MemoryControll*)malloc(sizeof(MemoryControll));
    if (ret_val==NULL) {
        fprintf(stderr, "addMemory malloc error\n");
        return NULL;
    }
    ret_val->next=arg_ctl;
    ret_val->item=arg_mem;
    return ret_val;
    
}
void deleteMemory(MemoryControll *arg_ctl) {
    MemoryControll *wk_item=arg_ctl;
    while(wk_item!=NULL) {
        if (wk_item->item!=NULL) {
            free(wk_item->item);
        }
        wk_item=wk_item->next;
    }
}
void deleteMomoryControll(MemoryControll *arg_ctl) {
    MemoryControll *wk_item=arg_ctl;
    MemoryControll *next_item=NULL;
    while(wk_item!=NULL) {
        next_item=wk_item->next;
        free(wk_item);
        wk_item=next_item;
    }
}
void *m_memalloc(size_t arg_size) {
    void *ret_val=(char*)malloc(arg_size);
    gl_memctl=addMemory(gl_memctl,ret_val);
    return ret_val;
}
void testvalue(int argint) {
    NSLog(@"%d", argint);
    //printf("%d", argint);
}
char *strMemCopy(char *srg_str) {
    char *ret_val=(char*)m_memalloc((int)strlen(srg_str)+1);
    if (ret_val==NULL) {
        fprintf(stderr, "strMemCopy malloc error\n");
        return NULL;
    }
    strcpy (ret_val,srg_str);
    return ret_val;
}
char *dstrMemCopy(char *srg_str) {
    char *ret_val=(char*)m_memalloc((int)strlen(srg_str)+1);
    if (ret_val==NULL) {
        fprintf(stderr, "strMemCopy malloc error\n");
        return NULL;
    }
    char *dstr=ret_val;
    while(*srg_str!=0) {
        if (*srg_str=='\\') {
            srg_str++;
            if (*srg_str=='n') {
                *dstr='\n';
            }
            if (*srg_str=='b') {
                *dstr='\b';
            }
            if (*srg_str=='r') {
                *dstr='\r';
            }
            srg_str++;
            dstr++;
            continue;
        }
        if (*srg_str=='"') {
            srg_str++;
            continue;
        }
        *dstr=*srg_str;
        dstr++;
        *dstr=0;
        srg_str++;
    }
    *dstr=0;
    return ret_val;
}
void AddGraphData(char *arg_color_name, ExprControl *arg_item) {
    MemoryControll *new_list_item=(MemoryControll*)m_memalloc(sizeof(MemoryControll));
    if (new_list_item==NULL) {
        fprintf(stderr, "CreateGraphData malloc error\n");
        return;
    }
    GraphData *new_item=(GraphData*)m_memalloc(sizeof(GraphData));
    new_item->exp_item=arg_item;
    new_item->color_name=arg_color_name;
    new_list_item->next=gl_graph_list;
    new_list_item->item=new_item;
    gl_graph_list=new_list_item;
}
GraphData *GetGraphData(int arg_idx) {
    MemoryControll *ret_item=gl_graph_list;
    if (ret_item==NULL) {
        return NULL;
    }
    for(int i=0; i<arg_idx; i++) {
        if (ret_item->next==NULL) {
            return NULL;
        }
        ret_item=ret_item->next;
    }
    return (GraphData*)ret_item->item;
}
double strToDouble(char *arg_str) {
    NSString *str = [NSString stringWithCString: arg_str encoding:NSUTF8StringEncoding];
    return [str doubleValue];
}
TokenControl *CreateChartItem(char ch) {
    TokenControl *ret_val=(TokenControl*)m_memalloc(sizeof(TokenControl));
    ret_val->type=ch;
    ret_val->data.f_value=(double*)m_memalloc(sizeof(double));
    return ret_val;
}
TokenControl *CreateFloatItem(double arg_f) {
    TokenControl *ret_val=(TokenControl*)m_memalloc(sizeof(TokenControl));
    ret_val->type='f';
    ret_val->vname=NULL;
    ret_val->data.f_value=(double*)m_memalloc(sizeof(double));
    *(ret_val->data.f_value)=arg_f;
    return ret_val;
}
TokenControl *CreateArrayItem() {
    TokenControl *ret_val=(TokenControl*)m_memalloc(sizeof(TokenControl));
    ret_val->type='H';
    ret_val->vname=NULL;
    ret_val->data.f_value=(double*)m_memalloc(sizeof(double));
    return ret_val;
}
int CreateArrayValueSubProc(NSMutableDictionary *dict) {
    for(int i=0; ; i++) {
        NSString *wkey=[NSString stringWithFormat:@"%d", i];
        if ([dict objectForKey:wkey]==nil) {
            return i;
        }
    }
}
void CreateArrayValue(TokenControl *arg_token) {
    ArgumentList *witem=arg_token->data.arg_list;
    NSMutableDictionary *cdict=nil;
    NSMutableArray *stackarr=[[NSMutableArray alloc] init];
    //arg_token->data.arg_list=NULL;
    arg_token->type='v';
    if (arg_token->vname==NULL) {
        arg_token->vname=NewArrayName();
    }
    while(witem!=NULL) {
        ExprControl *aritem=(ExprControl*)witem->item;
        if (aritem->a_array[0]->type=='s') {
            NSArray *key=[cdict allKeys];
            NSString* str = [NSString stringWithCString: arg_token->data.s_value encoding:NSUTF8StringEncoding];
            [cdict setObject:str forKey:[NSString stringWithFormat:@"%d", (int)[key count]]];
            //printf("%s", aritem->a_array[0]->data.s_value);
        }else if (aritem->a_array[0]->type=='[') {
            if (cdict==nil) {
                cdict=[[NSMutableDictionary alloc] init];
                NSString* str = [NSString stringWithCString: arg_token->vname encoding:NSUTF8StringEncoding];
                [gl_vdict setObject:cdict forKey:str];
            }else{
                int nn=CreateArrayValueSubProc(cdict);
                NSMutableDictionary *newcdict=[[NSMutableDictionary alloc] init];
                [cdict setObject:newcdict forKey:[NSString stringWithFormat:@"%d", nn]];
                [stackarr addObject:newcdict];
                cdict=newcdict;
            }
        }else if (aritem->a_array[0]->type==']') {
            cdict=[stackarr lastObject];
            [stackarr removeLastObject];
        }else if (aritem->type=='v') {
            double v=GetValue(aritem->a_array[0]);
            int nn=CreateArrayValueSubProc(cdict);
            [cdict setObject:[NSNumber numberWithDouble:v] forKey:[NSString stringWithFormat:@"%d", nn]];
            //printf("%f", v);
        }else if (aritem->a_array[0]->type=='f') {
            double v=*(aritem->a_array[0]->data.f_value);
            int nn=CreateArrayValueSubProc(cdict);
            [cdict setObject:[NSNumber numberWithDouble:v] forKey:[NSString stringWithFormat:@"%d", nn]];
            //printf("%f", v);
        }else{
            NSLog(@"type error");
        }
        witem=witem->next;
    }
   
}
TokenControl *CreateIntItem(void) {
    TokenControl *ret_val=(TokenControl*)m_memalloc(sizeof(TokenControl));
    ret_val->type='i';
    ret_val->vname=NULL;
    ret_val->data.i_value=(int*)m_memalloc(sizeof(int));
    return ret_val;
}
TokenControl *CreateValueItem(char *vname) {
    TokenControl *ret_val=(TokenControl*)m_memalloc(sizeof(TokenControl));
    ret_val->type='v';
    ret_val->vname=NULL;
    ret_val->data.s_value=strMemCopy(vname);
    return ret_val;
}
TokenControl *CreateStringItem(char *arg_str) {
    TokenControl *ret_val=(TokenControl*)m_memalloc(sizeof(TokenControl));
    ret_val->type='v';
    ret_val->vname=NULL;
    ret_val->data.s_value=strMemCopy(arg_str);
    return ret_val;
}
TokenControl *CreateDblequotItem(char *arg_str) {
    TokenControl *ret_val=(TokenControl*)m_memalloc(sizeof(TokenControl));
    ret_val->type='s';
    ret_val->vname=NULL;
    arg_str++;
    ret_val->data.s_value=dstrMemCopy(arg_str);
    return ret_val;
}
TokenControl *CreateAddressItem(CommandList *arg_addr) {
    TokenControl *ret_val=(TokenControl*)m_memalloc(sizeof(TokenControl));
    ret_val->type='a';
    ret_val->vname=NULL;
    ret_val->data.c_list=arg_addr;
    return ret_val;
}
TokenControl *CreateArgumentItem(char *vname,ArgumentList *arg_list) {
    TokenControl *ret_val=(TokenControl*)m_memalloc(sizeof(TokenControl));
    ret_val->type='h';
    ret_val->vname=vname;
    ret_val->data.arg_list=arg_list;
    return ret_val;
}
CommandList *CreateCommandList() {
    CommandList *ret_val=(CommandList*)m_memalloc(sizeof(CommandList));
    if (ret_val==NULL) {
        fprintf(stderr, "CreateCommandList malloc error\n");
        return NULL;
    }
    ret_val->next=NULL;
    ret_val->item=NULL;
    return ret_val;
}
CommandList *AddCommandList(CommandList *cmd_list,void *arg_item) {
    CommandList *ret_val=(CommandList*)m_memalloc(sizeof(CommandList));
    if (ret_val==NULL) {
        fprintf(stderr, "CreateCommandList malloc error\n");
        return NULL;
    }
    //char *ww=(char*)arg_item;
    ret_val->item=arg_item;
    ret_val->next=NULL;
    //cmd_list->item=arg_item;
    cmd_list->next=ret_val;
    return ret_val;
}
CommandList *AddCommandList2(CommandList *cmd_list,CommandList *cmd_list2) {
    CommandList *ret_list=cmd_list;
    CommandList *witem=cmd_list2;
    while(witem!=NULL) {
        ExprControl *eitem=witem->item;
        if (eitem==NULL) {
            witem=witem->next;
            continue;
        }
        ret_list=AddCommandList(ret_list, eitem);
        witem=witem->next;
    }
    return ret_list;
}
ExprControl *CreateExprControl(TokenControl *arg_token) {
    ExprControl *ret_val=(ExprControl*)m_memalloc(sizeof(ExprControl));
    if (ret_val==NULL) {
        fprintf(stderr, "CreateExprControl malloc error\n");
        return NULL;
    }
    ret_val->type='t';
    ret_val->eqflg=' ';
    ret_val->arglist=NULL;
    ret_val->a_array[0]=arg_token;
    ret_val->clist_ctl.start_pt=NULL;
    ret_val->clist_ctl.end_pt=NULL;
    return ret_val;
}
ExprControl *AccessArrayControl(TokenControl *arg_token,ArgumentList *arg_list) {
    ExprControl *ret_val=(ExprControl*)m_memalloc(sizeof(ExprControl));
    if (ret_val==NULL) {
        fprintf(stderr, "CreateExprControl malloc error\n");
        return NULL;
    }
    ret_val->type='h';
    ret_val->eqflg=' ';
    ret_val->arglist=arg_list;
    ret_val->a_array[0]=CreateArgumentItem(arg_token->data.s_value, arg_list);
    ret_val->clist_ctl.start_pt=NULL;
    ret_val->clist_ctl.end_pt=NULL;
    return ret_val;
}
ExprControl *CreateArrayControl(TokenControl *arg_token,ArgumentList *arg_list) {
    ExprControl *ret_val=(ExprControl*)m_memalloc(sizeof(ExprControl));
    if (ret_val==NULL) {
        fprintf(stderr, "CreateExprControl malloc error\n");
        return NULL;
    }
    ret_val->type='h';
    ret_val->eqflg=' ';
    ret_val->arglist=arg_list;
    ret_val->a_array[0]=arg_token;
    ret_val->clist_ctl.start_pt=NULL;
    ret_val->clist_ctl.end_pt=NULL;
    return ret_val;    
}
ExprControl *CreateExprNextControl(ExprControl *arg_exp) {
    ExprControl *ret_val=(ExprControl*)m_memalloc(sizeof(ExprControl));
    if (ret_val==NULL) {
        fprintf(stderr, "CreateExprNextControl malloc error\n");
        return NULL;
    }
    ret_val->type='t';
    ret_val->eqflg=' ';
    ret_val->arglist=NULL;
    ret_val->a_array[0]=arg_exp->a_array[0];
    if (arg_exp->clist_ctl.start_pt==NULL) {
        ret_val->clist_ctl.start_pt=CreateCommandList();
        ret_val->clist_ctl.end_pt=ret_val->clist_ctl.start_pt;
        ret_val->clist_ctl.start_pt->item=ret_val;
    }else{
        ret_val->clist_ctl.start_pt=arg_exp->clist_ctl.start_pt;
        ret_val->clist_ctl.end_pt=AddCommandList(arg_exp->clist_ctl.end_pt,ret_val);
    }
    return ret_val;
}
ExprControl *AddVoidCmdList(char op,ExprControl *arg_item1) {
    ExprControl *ret_val=(ExprControl*)m_memalloc(sizeof(ExprControl));
    if (ret_val==NULL) {
        fprintf(stderr, "AddVoidCmdList malloc error\n");
        return NULL;
    }
    if (arg_item1==NULL) {
        fprintf(stderr, "argument error\n");
        return NULL;
    }
    ret_val->type=op;
    ret_val->eqflg=' ';
    ret_val->arglist=arg_item1->arglist;
    ret_val->a_array[0]=arg_item1->a_array[0];
    if (arg_item1->clist_ctl.start_pt==NULL) {
        ret_val->clist_ctl.start_pt=CreateCommandList();
        ret_val->clist_ctl.end_pt=ret_val->clist_ctl.start_pt;
        ret_val->clist_ctl.start_pt->item=ret_val;
    }else{
        ret_val->clist_ctl.start_pt=CreateCommandList();
        ret_val->clist_ctl.end_pt=ret_val->clist_ctl.start_pt;
        ret_val->clist_ctl.end_pt=AddCommandList2(ret_val->clist_ctl.end_pt, arg_item1->clist_ctl.start_pt);
        ret_val->clist_ctl.end_pt=AddCommandList(ret_val->clist_ctl.end_pt, ret_val);
    }
    return ret_val;
}
ExprControl *AddVoidCmd2List(char op, ExprControl *arg_item1,ExprControl *arg_item2) {
    ExprControl *ret_val=(ExprControl*)m_memalloc(sizeof(ExprControl));
    if (ret_val==NULL) {
        fprintf(stderr, "CreateCommandList malloc error\n");
        return NULL;
    }
    ret_val->type=op;
    ret_val->eqflg=arg_item2->eqflg;
    ret_val->arglist=arg_item2->arglist;
    ret_val->a_array[0]=arg_item1->a_array[0];
    ret_val->a_array[1]=arg_item2->a_array[0];
    if (arg_item2->clist_ctl.start_pt==NULL) {
        if (arg_item1->clist_ctl.start_pt==NULL) {
            ret_val->clist_ctl.start_pt=CreateCommandList();
            ret_val->clist_ctl.end_pt=ret_val->clist_ctl.start_pt;
            ret_val->clist_ctl.start_pt->item=ret_val;
        }else{
            ret_val->clist_ctl.start_pt=arg_item2->clist_ctl.start_pt;
            ret_val->clist_ctl.end_pt=AddCommandList(arg_item2->clist_ctl.end_pt,ret_val);
        }
    }else{
        if ((arg_item1->clist_ctl.start_pt!=NULL)&&((int)arg_item1->clist_ctl.end_pt>(int)arg_item2->clist_ctl.end_pt)) {
            ret_val->clist_ctl.start_pt=arg_item1->clist_ctl.start_pt;
            ret_val->clist_ctl.end_pt=AddCommandList(arg_item1->clist_ctl.end_pt,ret_val);
        }else{
            ret_val->clist_ctl.start_pt=arg_item2->clist_ctl.start_pt;
            ret_val->clist_ctl.end_pt=AddCommandList(arg_item2->clist_ctl.end_pt,ret_val);
        }
    }
    return ret_val;
}
ExprControl *AddVoidCmd3List(char op, ExprControl *arg_item1,ExprControl *arg_item2,ExprControl *arg_item3) {
    ExprControl *ret_val=arg_item1;
    //ExprControl *ret_val=(ExprControl*)m_memalloc(sizeof(ExprControl));
    if (ret_val==NULL) {
        fprintf(stderr, "CreateCommandList malloc error\n");
        return NULL;
    }
    ret_val->type=op;
    ret_val->eqflg=' ';
    ret_val->arglist=NULL;
    ret_val->a_array[0]=arg_item1->a_array[0];
    ret_val->a_array[1]=arg_item2->a_array[0];
    ret_val->a_array[2]=arg_item3->a_array[0];
    if (arg_item2->clist_ctl.start_pt==NULL) {
        if (arg_item3->clist_ctl.start_pt==NULL) {
            ret_val->clist_ctl.start_pt=CreateCommandList();
            ret_val->clist_ctl.end_pt=ret_val->clist_ctl.start_pt;
            ret_val->clist_ctl.start_pt->item=ret_val;
        }else{
            ret_val->clist_ctl.start_pt=arg_item3->clist_ctl.start_pt;
            ret_val->clist_ctl.end_pt=AddCommandList(arg_item3->clist_ctl.end_pt,ret_val);
        }
    }else{
        ret_val->clist_ctl.start_pt=CreateCommandList();
        ret_val->clist_ctl.end_pt=ret_val->clist_ctl.start_pt;
        ret_val->clist_ctl.end_pt=AddCommandList2(ret_val->clist_ctl.end_pt, arg_item2->clist_ctl.start_pt);
        ret_val->clist_ctl.end_pt=AddCommandList2(ret_val->clist_ctl.end_pt, arg_item3->clist_ctl.start_pt);
        ret_val->clist_ctl.end_pt=AddCommandList(ret_val->clist_ctl.end_pt, ret_val);
    }
    return ret_val;
}
ExprControl *AddIfCmd3List(ExprControl *arg_item1,ExprControl *arg_item2,ExprControl *arg_item3) {
    ExprControl *ret_val=(ExprControl*)m_memalloc(sizeof(ExprControl));
    if (ret_val==NULL) {
        fprintf(stderr, "CreateCommandList malloc error\n");
        return NULL;
    }
    ret_val->type='I';
    ret_val->eqflg=' ';
    ret_val->arglist=NULL;
    ret_val->a_array[0]=arg_item1->a_array[0];
    ret_val->a_array[1]=CreateAddressItem(arg_item1->clist_ctl.start_pt);
    ret_val->a_array[2]=CreateAddressItem(arg_item2->clist_ctl.start_pt);
    if (arg_item3==NULL) {
        ret_val->a_array[3]=NULL;
    }else{
        ret_val->a_array[3]=CreateAddressItem(arg_item3->clist_ctl.start_pt);
    }
    ret_val->clist_ctl.start_pt=NULL;
    ret_val->clist_ctl.end_pt=NULL;
    ret_val->arglist=NULL;
    return ret_val;
}
ExprControl *AddWhileCmdList(ExprControl *arg_item1,ExprControl *arg_item2) {
    ExprControl *ret_val=(ExprControl*)m_memalloc(sizeof(ExprControl));
    if (ret_val==NULL) {
        fprintf(stderr, "AddWhileCmdList malloc error\n");
        return NULL;
    }
    ret_val->type='W';
    ret_val->eqflg=' ';
    ret_val->arglist=NULL;
    ret_val->a_array[0]=arg_item1->a_array[0];
    ret_val->a_array[1]=CreateAddressItem(arg_item1->clist_ctl.start_pt);
    ret_val->a_array[2]=CreateAddressItem(arg_item2->clist_ctl.start_pt);
    ret_val->clist_ctl.start_pt=NULL;
    ret_val->clist_ctl.end_pt=NULL;
    /*
     if (arg_item1->clist_ctl.start_pt==NULL) {
     ret_val->clist_ctl.start_pt=CreateCommandList();
     ret_val->clist_ctl.end_pt=ret_val->clist_ctl.start_pt;
     ret_val->clist_ctl.end_pt=AddCommandList(ret_val->clist_ctl.end_pt,ret_val);
     }else{
     ret_val->clist_ctl.start_pt=arg_item1->clist_ctl.start_pt;
     ret_val->clist_ctl.end_pt=AddCommandList(arg_item1->clist_ctl.end_pt,ret_val);
     }
     */
    return ret_val;
}
ExprControl *AddForCmdList(ExprControl *arg_item1,ExprControl *arg_item2,ExprControl *arg_item3,ExprControl *arg_item4) {
    ExprControl *ret_val=(ExprControl*)m_memalloc(sizeof(ExprControl));
    if (ret_val==NULL) {
        fprintf(stderr, "AddForCmdList malloc error\n");
        return NULL;
    }
    ret_val->type='F';
    ret_val->eqflg=' ';
    ret_val->arglist=NULL;
    ret_val->a_array[0]=arg_item2->a_array[0];
    ret_val->a_array[1]=CreateAddressItem(arg_item1->clist_ctl.start_pt);
    ret_val->a_array[2]=CreateAddressItem(arg_item2->clist_ctl.start_pt);
    ret_val->a_array[3]=CreateAddressItem(arg_item3->clist_ctl.start_pt);
    ret_val->a_array[4]=CreateAddressItem(arg_item4->clist_ctl.start_pt);
    ret_val->clist_ctl.start_pt=NULL;
    ret_val->clist_ctl.end_pt=NULL;
    return ret_val;
}
ExprControl *AddCallFunctionCmd3List(char op, ExprControl *arg_item1,TokenControl *arg_item2,ExprControl *arg_item3) {
    ExprControl *ret_val=(ExprControl*)m_memalloc(sizeof(ExprControl));
    if (ret_val==NULL) {
        fprintf(stderr, "AddForCmdList malloc error\n");
        return NULL;
    }
    ret_val->type='c';
    ret_val->eqflg=' ';
    ret_val->a_array[0]=arg_item1->a_array[0];
    ret_val->a_array[1]=arg_item2;
    if (arg_item3==NULL) {
        ret_val->arglist=NULL;
    }else{
        ret_val->arglist=arg_item3->arglist;
    }
    if ((arg_item3==NULL)||(arg_item3->clist_ctl.start_pt==NULL)) {
        ret_val->clist_ctl.start_pt=CreateCommandList();
        ret_val->clist_ctl.end_pt=ret_val->clist_ctl.start_pt;
        ret_val->clist_ctl.start_pt->item=ret_val;
    }else{
        ret_val->clist_ctl.start_pt=arg_item3->clist_ctl.start_pt;
        ret_val->clist_ctl.end_pt=AddCommandList(arg_item3->clist_ctl.end_pt,ret_val);
    }
    return ret_val;
}
//AddRegistFunctionCmd3List function 登録
// arg_item1 名前
// arg_item2 引数
// arg_item3 処理手順
ExprControl *AddRegistFunctionCmd3List(TokenControl *arg_item1,ExprControl *arg_item2,ExprControl *arg_item3) {
    ExprControl *ret_val=(ExprControl*)m_memalloc(sizeof(ExprControl));
    if (ret_val==NULL) {
        fprintf(stderr, "AddForCmdList malloc error\n");
        return NULL;
    }
    ret_val->type='d';
    ret_val->eqflg=' ';
    ret_val->clist_ctl.start_pt=NULL;
    ret_val->clist_ctl.end_pt=NULL;
    FunctionControl *fcnt=(FunctionControl*)m_memalloc(sizeof(FunctionControl));
    if (fcnt==NULL) {
        fprintf(stderr, "AddRegistFunctionCmd3List malloc error\n");
        return NULL;
    }
    fcnt->name=arg_item1->data.s_value;
    if (arg_item2!=NULL) {
        fcnt->arg_list=arg_item2->arglist;
    }
    fcnt->cmd_list=arg_item3->clist_ctl.start_pt;
    int reg_cnt=AddVoidArgumentList(gl_fnc_list,fcnt);
    NSString* str = [NSString stringWithCString: fcnt->name encoding:NSUTF8StringEncoding];
    [gl_fnc_cmdlst setObject:[NSNumber numberWithInt:reg_cnt] forKey:str];
    return ret_val;
}
void DebugValue(ExprControl *arg_expr) {
    printf("%c", arg_expr->type);
}
void DebugArgList(ExprControl *arg_expr) {
    ArgumentList *witem=arg_expr->arglist;
    while(witem!=NULL) {
        ExprControl *aritem=(ExprControl*)witem->item;
        if (aritem->a_array[0]->type=='s') {
            printf("%s", aritem->a_array[0]->data.s_value);
        }else {
            double v=GetValue(aritem->a_array[0]);
            printf("%f", v);
        }
        witem=witem->next;
    }
    
}
void DebugCommandList(CommandList *cmd_list) {
    CommandList *witem=cmd_list;
    while(witem!=NULL) {
        ExprControl *eitem=witem->item;
        if (eitem==NULL) {
            witem=witem->next;
            continue;
        }
        if (eitem->type=='p') {
            if (eitem->arglist!=NULL) {
                ArgumentList *witem=eitem->arglist;
                while(witem!=NULL) {
                    ExprControl *aritem=(ExprControl*)witem->item;
                    if (aritem->type=='s') {
                        printf("%s", aritem->a_array[0]->data.s_value);
                    }else{
                        double v=GetValue(aritem->a_array[0]);
                        printf("%f", v);
                    }
                    witem=witem->next;
                }
            }else{
                printf("%c %f\n", eitem->type, *(eitem->a_array[0]->data.f_value));
            }
        }else if (eitem->type=='+') {
            printf("%c %f %f %f\n", eitem->type, *(eitem->a_array[0]->data.f_value),*(eitem->a_array[1]->data.f_value),*(eitem->a_array[2]->data.f_value));
        }else if (eitem->type=='-') {
            printf("%c %f %f %f\n", eitem->type, *(eitem->a_array[0]->data.f_value),*(eitem->a_array[1]->data.f_value),*(eitem->a_array[2]->data.f_value));
        }else if (eitem->type=='*') {
            printf("%c %f %f %f\n", eitem->type, *(eitem->a_array[0]->data.f_value),*(eitem->a_array[1]->data.f_value),*(eitem->a_array[2]->data.f_value));
        }else if (eitem->type=='/') {
            printf("%c %f %f %f\n", eitem->type, *(eitem->a_array[0]->data.f_value),*(eitem->a_array[1]->data.f_value),*(eitem->a_array[2]->data.f_value));
        }else if (eitem->type=='=') {
            printf("%c %s %f\n", eitem->type, eitem->a_array[0]->data.s_value,*(eitem->a_array[1]->data.f_value));
        }else if (eitem->type=='a') {
            if (eitem->arglist!=NULL) {
                ArgumentList *witem=eitem->arglist;
                while(witem!=NULL) {
                    ExprControl *aritem=(ExprControl*)witem->item;
                    if (aritem->type=='s') {
                        printf("%s", aritem->a_array[0]->data.s_value);
                    }else if (aritem->type=='v') {
                        double v=GetValue(aritem->a_array[0]);
                        printf("%f", v);
                    }
                    witem=witem->next;
                }
                printf("\n");
            }else{
                printf("%c %f\n", eitem->type, *(eitem->a_array[0]->data.f_value));
            }
        }else if (eitem->type=='c') {
            printf("call %s\n", eitem->a_array[1]->data.s_value);
            if (eitem->arglist!=NULL) {
                ArgumentList *witem=eitem->arglist;
                while(witem!=NULL) {
                    ExprControl *aritem=(ExprControl*)witem->item;
                    if (aritem->type=='s') {
                        printf("%s", aritem->a_array[0]->data.s_value);
                    }else{
                        double v=GetValue(aritem->a_array[0]);
                        printf("%f", v);
                    }
                    witem=witem->next;
                }
                printf("\n");
            }
        }
        witem=witem->next;
    }
}
void *GetArgumentList(ArgumentList *cmd_list,int arg_idx) {
    ArgumentList *ret_item=cmd_list;
    if (cmd_list==NULL) {
        return NULL;
    }
    for(int i=0; i<arg_idx; i++) {
        if (ret_item->next==NULL) {
            return NULL;
        }
        ret_item=ret_item->next;
    }
    return (void*)ret_item->item;
}
ExprControl *CopyExprControl(ExprControl *arg_item) {
    ExprControl *ret_val=(ExprControl*)m_memalloc(sizeof(ExprControl));
    ret_val->a_array[0]=arg_item->a_array[0];
    ret_val->a_array[1]=arg_item->a_array[1];
    ret_val->a_array[2]=arg_item->a_array[2];
    ret_val->a_array[3]=arg_item->a_array[3];
    ret_val->a_array[4]=arg_item->a_array[4];
    ret_val->type=arg_item->type;
    ret_val->clist_ctl.start_pt=NULL;
    ret_val->clist_ctl.end_pt=NULL;
    return ret_val;
}
ExprControl *AddListCommandList(ExprControl *arg_item1,ExprControl *arg_item2) {
    ExprControl *ret_val=(ExprControl*)m_memalloc(sizeof(ExprControl));
    if (arg_item2==NULL) {
        return NULL;
    }
    if (arg_item1==NULL) {
        ret_val->type='l';
        if (arg_item2->clist_ctl.start_pt==NULL) {
            ret_val->clist_ctl.start_pt=CreateCommandList();
            ret_val->clist_ctl.end_pt=ret_val->clist_ctl.start_pt;
            ret_val->clist_ctl.end_pt=AddCommandList(ret_val->clist_ctl.end_pt,arg_item2);
        }else{
            ret_val->clist_ctl.start_pt=arg_item2->clist_ctl.start_pt;
            ret_val->clist_ctl.end_pt=arg_item2->clist_ctl.end_pt;
        }
        return ret_val;
    }
    *ret_val=*arg_item1;
    if (arg_item1->clist_ctl.start_pt==NULL) {
        if (arg_item2->clist_ctl.start_pt==NULL) {
            ret_val->clist_ctl.start_pt=CreateCommandList();
            ret_val->clist_ctl.end_pt=ret_val->clist_ctl.start_pt;
            ret_val->clist_ctl.end_pt=AddCommandList(ret_val->clist_ctl.end_pt,arg_item2);
        }else{
            ret_val->clist_ctl.start_pt=arg_item1->clist_ctl.start_pt;
            ret_val->clist_ctl.end_pt=AddCommandList(arg_item1->clist_ctl.end_pt,arg_item2);
        }
    }else if (arg_item2->clist_ctl.start_pt==NULL) {
        ret_val->clist_ctl.start_pt=arg_item1->clist_ctl.start_pt;
        ret_val->clist_ctl.end_pt=AddCommandList(arg_item1->clist_ctl.end_pt,arg_item2);
    }else{
        ret_val->clist_ctl.start_pt=arg_item1->clist_ctl.start_pt;
        ret_val->clist_ctl.end_pt=arg_item1->clist_ctl.end_pt;
        CommandList *add_list;
        add_list=arg_item2->clist_ctl.start_pt;
        while(add_list!=NULL) {
            if (add_list->item==NULL) {
                add_list=add_list->next;
                continue;
            }
            ExprControl *eitem=(ExprControl*)add_list->item;
            ret_val->clist_ctl.end_pt=AddCommandList(ret_val->clist_ctl.end_pt,eitem);
            add_list=add_list->next;
        }
    }
    return ret_val;
}
void CopyValue(NSMutableDictionary *set_dict, TokenControl *arg_set_value, NSMutableDictionary *get_dict,TokenControl *arg_get_value) {
    if (arg_set_value->type=='v') {
        if (arg_get_value->type=='f') {
            NSString* str = [NSString stringWithCString: arg_set_value->data.s_value encoding:NSUTF8StringEncoding];
            double fvalu=*(arg_get_value->data.f_value);
            [set_dict setObject:[NSNumber numberWithDouble:fvalu] forKey:str];
        }else if (arg_get_value->type=='v') {
            NSString* str = [NSString stringWithCString: arg_set_value->data.s_value encoding:NSUTF8StringEncoding];
            double fvalu;
            NSNumber *vnum=[get_dict objectForKey:str];
            if (vnum==nil) {
                fvalu=0;
            }else{
                fvalu=[vnum doubleValue];
            }
            [set_dict setObject:[NSNumber numberWithDouble:fvalu] forKey:str];
        }
    }else if (arg_set_value->type=='f') {
        if (arg_get_value->type=='f') {
            double fvalu=*(arg_get_value->data.f_value);
            *(arg_set_value->data.f_value)=fvalu;
        }else if (arg_get_value->type=='v') {
            NSString* str = [NSString stringWithCString: arg_set_value->data.s_value encoding:NSUTF8StringEncoding];
            double fvalu;
            NSNumber *vnum=[get_dict objectForKey:str];
            if (vnum==nil) {
                fvalu=0;
            }else{
                fvalu=[vnum doubleValue];
            }
            [set_dict setObject:[NSNumber numberWithDouble:fvalu] forKey:str];
        }
    }
}
int IsValueString(TokenControl *arg_value) {
    if (arg_value->type=='s') {
        return 1;
    }else if (arg_value->type=='v') {
        NSString* str = [NSString stringWithCString: arg_value->data.s_value encoding:NSUTF8StringEncoding];
        NSObject *vobj=[gl_vdict objectForKey:str];
        if ([vobj isKindOfClass:[NSString class]]) {
            return 1;
        }
    }else if (arg_value->type=='h') {
        NSString* str = [NSString stringWithCString: arg_value->vname encoding:NSUTF8StringEncoding];
        ArgumentList *witem=arg_value->data.arg_list;
        NSMutableDictionary *cdict=[gl_vdict objectForKey:str];
        while(witem!=NULL) {
            ExprControl *aritem=(ExprControl*)witem->item;
            if (aritem->type=='v') {
                NSArray *key=[cdict allKeys];
                double v=GetValue(aritem->a_array[0]);
                [cdict setObject:[NSNumber numberWithDouble:v] forKey:[NSString stringWithFormat:@"%d", (int)[key count]]];
                printf("%f", v);
            }else if (aritem->a_array[0]->type=='f') {
                double v=*(aritem->a_array[0]->data.f_value);
                NSObject *obj=[cdict objectForKey:[NSString stringWithFormat:@"%d", (int)v]];
                if ([obj isKindOfClass:[NSMutableDictionary class]]) {
                    cdict=(NSMutableDictionary*)obj;
                }else if ([obj isKindOfClass:[NSNumber class]]) {
                    return 0;
                }else if ([obj isKindOfClass:[NSString class]]) {
                    return 1;
                }else{
                    fprintf(stderr, "GetArrayValue type error %s", arg_value->vname);
                    break;
                }
            }else{
                NSLog(@"type error");
            }
            witem=witem->next;
        }
    }
    return 0;
}
int IsArray(TokenControl *arg_value) {
    if (arg_value->type=='h') {
        return 1;
    }else if (arg_value->type=='H') {
        return 1;
    }else if (arg_value->vname!=NULL) {
        return 1;
    }else if (arg_value->type=='v') {
        NSString* str = [NSString stringWithCString: arg_value->data.s_value encoding:NSUTF8StringEncoding];
        NSObject *vobj=[gl_vdict objectForKey:str];
        if ([vobj isKindOfClass:[NSMutableDictionary class]]) {
            return 1;
        }
    }
    return 0;
}
void PrintArraySubProc(NSMutableString *out_str, NSMutableDictionary *cdict) {
    [out_str appendString:@"["];
    NSString *separet=@"";
    NSArray *key=[cdict allKeys];
    NSArray *result = [key sortedArrayUsingSelector:@selector(compare:)];
    for(NSString *kstr in result) {
        NSObject *obj=[cdict objectForKey:kstr];
        if ([obj isKindOfClass:[NSString class]]) {
            [out_str appendFormat:@"%@%@",separet,(NSString*)obj];
        }else if ([obj isKindOfClass:[NSNumber class]]) {
            [out_str appendFormat:@"%@%g",separet,[(NSNumber*)obj doubleValue]];
        }else if ([obj isKindOfClass:[NSMutableDictionary class]]) {
            PrintArraySubProc(out_str, (NSMutableDictionary*)obj);
        }
        separet=@",";
    }
    [out_str appendString:@"]"];
}
void PrintArray(TokenControl *arg_value) {
    if (arg_value->type=='h') {
        if (IsValueString(arg_value)) {
            char *str=GetValueString(arg_value);
            fprintf(app_out, "%s", str);
        }else{
            double v=GetArrayValue(arg_value);
            if (v==floor(v)) {
                long long vl=(long long)v;
                if (vl==LLONG_MAX) {
                    fprintf(stderr, "overflow error\n");
                }
                fprintf(app_out, "%qi", vl);
            }else{
                char buff[64];
                int nf=floor(log10(v));
                sprintf(buff, "%%.%df", 15-nf);
                fprintf(app_out, buff, v);
            }
        }
        return;
    }
    NSMutableString *out_str=[[NSMutableString alloc] init];
    NSString* str;
    if (arg_value->vname!=NULL) {
        str= [NSString stringWithCString: arg_value->vname encoding:NSUTF8StringEncoding];
    }else{
        str= [NSString stringWithCString: arg_value->data.s_value encoding:NSUTF8StringEncoding];
    }
    NSMutableDictionary *cdict=[gl_vdict objectForKey:str];
    if (cdict==nil) {
        return;
    }
    PrintArraySubProc(out_str,cdict);
    const char *wcpr=[(NSString*)out_str UTF8String];
    fprintf(app_out, "%s", wcpr);
}
char *GetValueString(TokenControl *arg_value) {
    if (arg_value->type=='s') {
        return arg_value->data.s_value;
    }else if (arg_value->type=='v') {
        NSString* str = [NSString stringWithCString: arg_value->data.s_value encoding:NSUTF8StringEncoding];
        NSObject *vobj=[gl_vdict objectForKey:str];
        if ([vobj isKindOfClass:[NSString class]]) {
            const char *wcpr=[(NSString*)vobj UTF8String];
            return (char*)wcpr;
        }
    }else if (arg_value->type=='h') {
    }
    return NULL;
}
double GetValue(TokenControl *arg_value) {
    if (arg_value->type=='f') {
        return *(arg_value->data.f_value);
    }else if (arg_value->type=='v') {
        NSString* str = [NSString stringWithCString: arg_value->data.s_value encoding:NSUTF8StringEncoding];
        NSNumber *vnum=[gl_vdict objectForKey:str];
        if (vnum==nil) {
            return 0;
        }else{
            return [vnum doubleValue];
        }
    }else if (arg_value->type=='a') {
        return 0;
    }else if (arg_value->type=='t') {
        return 0;
    }else if (arg_value->type=='h') {
        return GetArrayValue(arg_value);
    }else{
        fprintf(stderr, "GetValue %c", arg_value->type);
        return 0;
    }
}
double GetArrayValue(TokenControl *arg_value) {
    NSString* ser_name_str;
    if (arg_value->vname==NULL) {
        if (arg_value->data.s_value==NULL) {
            return 0;
        }
        ser_name_str = [NSString stringWithCString: arg_value->data.s_value encoding:NSUTF8StringEncoding];
    }else{
        ser_name_str = [NSString stringWithCString: arg_value->vname encoding:NSUTF8StringEncoding];
    }
    ArgumentList *witem=arg_value->data.arg_list;
    NSMutableDictionary *cdict=[gl_vdict objectForKey:ser_name_str];
    while(witem!=NULL) {
        ExprControl *aritem=(ExprControl*)witem->item;
        if (aritem->type=='v') {
            NSArray *key=[cdict allKeys];
            double v=GetValue(aritem->a_array[0]);
            [cdict setObject:[NSNumber numberWithDouble:v] forKey:[NSString stringWithFormat:@"%d", (int)[key count]]];
            printf("%f", v);
        }else if (aritem->a_array[0]->type=='f') {
            double v=*(aritem->a_array[0]->data.f_value);
            NSObject *obj=[cdict objectForKey:[NSString stringWithFormat:@"%d", (int)v]];
            if ([obj isKindOfClass:[NSMutableDictionary class]]) {
                cdict=(NSMutableDictionary*)obj;
            }else if ([obj isKindOfClass:[NSNumber class]]) {
                NSNumber *vnum=(NSNumber*)obj;
                return [vnum doubleValue];
            }else if ([obj isKindOfClass:[NSNumber class]]) {
                break;
            }else{
                fprintf(stderr, "GetArrayValue type error %s", arg_value->vname);
                break;
            }
        }else if (aritem->a_array[0]->type=='s') {
            NSString *iname = [NSString stringWithCString: aritem->a_array[0]->data.s_value encoding:NSUTF8StringEncoding];
            NSObject *obj=[cdict objectForKey:iname];
            if ([obj isKindOfClass:[NSMutableDictionary class]]) {
                cdict=(NSMutableDictionary*)obj;
            }else if ([obj isKindOfClass:[NSNumber class]]) {
                NSNumber *vnum=(NSNumber*)obj;
                return [vnum doubleValue];
            }
        }else{
            NSLog(@"type error");
        }
        witem=witem->next;
    }
    return 0;
}
void SetValue2(TokenControl *arg_set_value,double  arg_value) {
    if (arg_set_value->type=='v') {
        NSString* str = [NSString stringWithCString: arg_set_value->data.s_value encoding:NSUTF8StringEncoding];
        [gl_vdict setObject:[NSNumber numberWithDouble:arg_value] forKey:str];
    }else if (arg_set_value->type=='h') {
        SetArrayValue2(arg_set_value,arg_value);
    }
}
void SetValue(TokenControl *arg_set_value,TokenControl *arg_get_value) {
    if (arg_set_value->type=='v') {
        if (arg_get_value->type=='f') {
            NSString* str = [NSString stringWithCString: arg_set_value->data.s_value encoding:NSUTF8StringEncoding];
            double fvalu=*(arg_get_value->data.f_value);
            [gl_vdict setObject:[NSNumber numberWithDouble:fvalu] forKey:str];
        }else if (arg_get_value->type=='v') {
            if (IsArray(arg_get_value)) {
                SetArrayValue(arg_set_value,arg_get_value);
                return;
            }
            NSString* str = [NSString stringWithCString: arg_set_value->data.s_value encoding:NSUTF8StringEncoding];
            double fvalu;
            fvalu=GetValue(arg_get_value);
            [gl_vdict setObject:[NSNumber numberWithDouble:fvalu] forKey:str];
        }else if (arg_get_value->type=='s') {
            NSString* namestr = [NSString stringWithCString: arg_set_value->data.s_value encoding:NSUTF8StringEncoding];
            char* cp = arg_get_value->data.s_value;
            NSString* str = [NSString stringWithCString: cp encoding:NSUTF8StringEncoding];
            [gl_vdict setObject:str forKey:namestr];
        }
    }else if (arg_set_value->type=='h') {
        SetArrayValue(arg_set_value,arg_get_value);
    }
}
void SetArrayValue(TokenControl *arg_set_value,TokenControl *arg_get_value) {
    NSString* ser_name_str;
    if (arg_set_value->vname==NULL) {
        if (arg_set_value->data.s_value==NULL) {
            return;
        }
        ser_name_str = [NSString stringWithCString: arg_set_value->data.s_value encoding:NSUTF8StringEncoding];
        arg_set_value->vname=arg_set_value->data.s_value;
    }else{
        ser_name_str = [NSString stringWithCString: arg_set_value->vname encoding:NSUTF8StringEncoding];
    }
    ArgumentList *witem=arg_set_value->data.arg_list;
    NSMutableDictionary *cdict=[gl_vdict objectForKey:ser_name_str];
    if (cdict==nil) {
        cdict=[[NSMutableDictionary alloc] init];
        [gl_vdict setObject:cdict forKey:ser_name_str];
    }
    if (arg_get_value->type=='v') {
        if (arg_set_value->type!='h') {
            NSString* sstr;
            if (arg_get_value->vname==NULL) {
                if (arg_get_value->data.s_value==NULL) {
                    return;
                }
                sstr = [NSString stringWithCString: arg_get_value->data.s_value encoding:NSUTF8StringEncoding];
            }else{
                sstr= [NSString stringWithCString: arg_get_value->vname encoding:NSUTF8StringEncoding];
            }
            NSMutableDictionary *sdict=[gl_vdict objectForKey:sstr];
            if (sdict==nil) {
                fprintf(stderr, "SetArrayValue array data error %s", arg_set_value->vname);
            }else{
                [gl_vdict setObject:sdict forKey:ser_name_str];
            }
            return;
        }
    }
    if (cdict==nil) {
        return;
    }
    int vn=-1;
    NSString *item_name=nil;
    while(witem!=NULL) {
        ExprControl *aritem=(ExprControl*)witem->item;
        if (aritem->type=='v') {
            double v=GetValue(aritem->a_array[0]);
            NSObject *obj=[cdict objectForKey:[NSString stringWithFormat:@"%d", (int)v]];
            if ([obj isKindOfClass:[NSMutableDictionary class]]) {
                cdict=(NSMutableDictionary*)obj;
            }else if ([obj isKindOfClass:[NSNumber class]]) {
                vn=v;
                break;
            }else if ([obj isKindOfClass:[NSNumber class]]) {
                break;
            }else{
                break;
            }
        }else if (aritem->a_array[0]->type=='f') {
            double v=*(aritem->a_array[0]->data.f_value);
            NSObject *obj=[cdict objectForKey:[NSString stringWithFormat:@"%d", (int)v]];
            if ([obj isKindOfClass:[NSMutableDictionary class]]) {
                cdict=(NSMutableDictionary*)obj;
            }else if ([obj isKindOfClass:[NSNumber class]]) {
                vn=v;
                break;
            }else if ([obj isKindOfClass:[NSNumber class]]) {
                break;
            }else{
                break;
            }
        }else if (aritem->a_array[0]->type=='s') {
            item_name = [NSString stringWithCString: aritem->a_array[0]->data.s_value encoding:NSUTF8StringEncoding];
            NSObject *obj=[cdict objectForKey:item_name];
            if (obj==nil) {
                if (witem->next!=NULL) {
                    NSMutableDictionary *newdict=[[NSMutableDictionary alloc] init];
                    [cdict setObject:newdict forKey:item_name];
                    cdict=newdict;
                }
                vn=0;
            }else if ([obj isKindOfClass:[NSMutableDictionary class]]) {
                cdict=(NSMutableDictionary*)obj;
            }else if ([obj isKindOfClass:[NSNumber class]]) {
                vn=0;
                break;
            }else{
                vn=0;
                break;
            }
        }else{
            NSLog(@"type error");
        }
        witem=witem->next;
    }
    if (vn==-1) {
        return;
    }
    NSString* keystr = [NSString stringWithFormat:@"%d", (int)vn];
    if (item_name!=nil) {
        keystr=item_name;
    }
    if (arg_get_value->type=='f') {
        double fvalu=*(arg_get_value->data.f_value);
        [cdict setObject:[NSNumber numberWithDouble:fvalu] forKey:keystr];
    }else if (arg_get_value->type=='v') {
        if (IsArray(arg_get_value)) {
            NSString* sstr;
            if (arg_get_value->vname==NULL) {
                if (arg_get_value->data.s_value==NULL) {
                    return;
                }
                sstr = [NSString stringWithCString: arg_get_value->data.s_value encoding:NSUTF8StringEncoding];
            }else{
                sstr= [NSString stringWithCString: arg_get_value->vname encoding:NSUTF8StringEncoding];
            }
            NSObject *getobj=[gl_vdict objectForKey:sstr];
            if (getobj!=nil) {
                [cdict setObject:getobj forKey:keystr];
            }
            
        }else{
            double fvalu=GetValue(arg_get_value);
            [cdict setObject:[NSNumber numberWithDouble:fvalu] forKey:keystr];
        }
    }else if (arg_get_value->type=='h') {
        NSString* sstr = [NSString stringWithCString: arg_get_value->vname encoding:NSUTF8StringEncoding];
        NSMutableDictionary *sdict=[gl_vdict objectForKey:sstr];
        if (sdict!=nil) {
            NSObject *select_obj=nil;
            ArgumentList *witem=arg_get_value->data.arg_list;
            while(witem!=NULL) {
                ExprControl *aritem=(ExprControl*)witem->item;
                if (aritem->type=='v') {
                    double v=GetValue(aritem->a_array[0]);
                    select_obj=[NSNumber numberWithDouble:v];
                }else if (aritem->a_array[0]->type=='f') {
                    double v=*(aritem->a_array[0]->data.f_value);
                    NSObject *obj=[sdict objectForKey:[NSString stringWithFormat:@"%d", (int)v]];
                    if ([obj isKindOfClass:[NSMutableDictionary class]]) {
                        sdict=(NSMutableDictionary*)obj;
                    }else if ([obj isKindOfClass:[NSNumber class]]) {
                        select_obj=obj;
                    }else if ([obj isKindOfClass:[NSString class]]) {
                        select_obj=obj;
                        break;
                    }else{
                        fprintf(stderr, "GetArrayValue type error %s", arg_set_value->vname);
                        break;
                    }
                }else{
                    NSLog(@"type error");
                }
                witem=witem->next;
            }
            if (select_obj!=nil) {
                [cdict setObject:select_obj forKey:keystr];
            }
        }
    }else if (arg_get_value->type=='s') {
        char* cp = arg_get_value->data.s_value;
        NSString* str = [NSString stringWithCString: cp encoding:NSUTF8StringEncoding];
        [cdict setObject:str forKey:keystr];
    }
}
void SetArrayValue2(TokenControl *arg_set_value,double  arg_value) {
    NSString* str = [NSString stringWithCString: arg_set_value->vname encoding:NSUTF8StringEncoding];
    ArgumentList *witem=arg_set_value->data.arg_list;
    NSMutableDictionary *cdict=[gl_vdict objectForKey:str];
    int vn=-1;
    while(witem!=NULL) {
        ExprControl *aritem=(ExprControl*)witem->item;
        if (aritem->type=='v') {
            double v=GetValue(aritem->a_array[0]);
            NSObject *obj=[cdict objectForKey:[NSString stringWithFormat:@"%d", (int)v]];
            if ([obj isKindOfClass:[NSMutableDictionary class]]) {
                cdict=(NSMutableDictionary*)obj;
            }else if ([obj isKindOfClass:[NSNumber class]]) {
                vn=v;
                break;
            }else if ([obj isKindOfClass:[NSNumber class]]) {
                break;
            }else{
                break;
            }
        }else if (aritem->a_array[0]->type=='f') {
            double v=*(aritem->a_array[0]->data.f_value);
            NSObject *obj=[cdict objectForKey:[NSString stringWithFormat:@"%d", (int)v]];
            if ([obj isKindOfClass:[NSMutableDictionary class]]) {
                cdict=(NSMutableDictionary*)obj;
            }else if ([obj isKindOfClass:[NSNumber class]]) {
                vn=v;
                break;
            }else if ([obj isKindOfClass:[NSNumber class]]) {
                break;
            }else{
                break;
            }
        }else{
            NSLog(@"type error");
        }
        witem=witem->next;
    }
    if (vn==-1) {
        return;
    }
    NSString* keystr = [NSString stringWithFormat:@"%d", (int)vn];
    [cdict setObject:[NSNumber numberWithDouble:arg_value] forKey:keystr];
}
FunctionControl *GetFunctionData(char *arg_name) {
    NSString* str = [NSString stringWithCString: arg_name encoding:NSUTF8StringEncoding];
    NSNumber *vnum=[gl_fnc_cmdlst objectForKey:str];
    if (vnum==nil) {
        return NULL;
    }
    return (FunctionControl*)GetArgumentList(gl_fnc_list,[vnum intValue]);
}
long long ft(int arg_val) {
    long long rt=1;
    for(int v1=(int)1;v1<=arg_val;v1++) {
        rt*=v1;
        if (log10(rt)>20.0) {
            fprintf(stderr, "overflow error\n");
            rt=-1;
            break;
        }
    }
    return rt;
}
long long ftA(int arg_val, int r) {
    long long rt=1;
    for(int v1=(int)arg_val;v1>=0;v1--) {
        if (r<=0) {
            break;
        }
        rt*=v1;
        if (log10(rt)>20.0) {
            fprintf(stderr, "overflow error\n");
            rt=-1;
            break;
        }
        r--;
    }
    return rt;
}
double floor2(double vl) {
    if (vl>0) {
        return floor(vl);
    }else{
        double rt=-1*(floor(vl*-1));
        return rt;
    }
}
BOOL RunCommandList(NSMutableDictionary *arg_dict,TokenControl *rval,CommandList *cmd_list) {
    CommandList *witem=cmd_list;
    BOOL deg_or_rad_falg_bak=deg_or_rad_falg;
    BOOL loopflag=YES;
    while(witem!=NULL) {
        if (loopflag==NO) {
            break;
        }
        if (break_flag) {
            break;
        }
        ExprControl *eitem=witem->item;
        if (eitem==NULL) {
            witem=witem->next;
            continue;
        }
        switch(eitem->type) {
            case '+':
            {
                if (eitem->a_array[0]==NULL||eitem->a_array[1]==NULL||eitem->a_array[2]==NULL) {
                    fprintf(stderr, "ArgumentList error\n");
                    break;
                }
                if (IsArray(eitem->a_array[1])||IsArray(eitem->a_array[2])) {
                    if (IsArray(eitem->a_array[1])&&IsArray(eitem->a_array[2])) {
                        char *new_name=NewArrayName();
                        ArrayAdd(eitem->a_array[0], new_name, eitem->a_array[1], eitem->a_array[2]);
                    }else{
                        fprintf(stderr, "ArgumentList array error\n");
                    }
                }else{
                    double v1=GetValue(eitem->a_array[1]);
                    double v2=GetValue(eitem->a_array[2]);
                    //double vw=v1 + v2;
                    *(eitem->a_array[0]->data.f_value)=v1 + v2;
                }
            }
                break;
            case '-':
            {
                if (eitem->a_array[0]==NULL||eitem->a_array[1]==NULL||eitem->a_array[2]==NULL) {
                    fprintf(stderr, "ArgumentList error\n");
                    break;
                }
                if (IsArray(eitem->a_array[1])||IsArray(eitem->a_array[2])) {
                    if (IsArray(eitem->a_array[1])&&IsArray(eitem->a_array[2])) {
                        char *new_name=NewArrayName();
                        ArraySub(eitem->a_array[0], new_name, eitem->a_array[1], eitem->a_array[2]);
                    }else{
                        fprintf(stderr, "ArgumentList array error\n");
                    }
                }else{
                    double v1=GetValue(eitem->a_array[1]);
                    double v2=GetValue(eitem->a_array[2]);
                    *(eitem->a_array[0]->data.f_value)=v1 - v2;
                }
            }
                break;
            case '*':
            {
                if (eitem->a_array[0]==NULL||eitem->a_array[1]==NULL||eitem->a_array[2]==NULL) {
                    fprintf(stderr, "ArgumentList error\n");
                    break;
                }
                if (IsArray(eitem->a_array[1])||IsArray(eitem->a_array[2])) {
                    if (IsArray(eitem->a_array[1])&&IsArray(eitem->a_array[2])) {
                        char *new_name=NewArrayName();
                        ArrayMlt(eitem->a_array[0], new_name, eitem->a_array[1], eitem->a_array[2]);
                    }else{
                        fprintf(stderr, "ArgumentList array error\n");
                    }
                }else{
                    double v1=GetValue(eitem->a_array[1]);
                    double v2=GetValue(eitem->a_array[2]);
                    *(eitem->a_array[0]->data.f_value)=v1 * v2;
                }
            }
                break;
            case '/':
            {
                if (eitem->a_array[0]==NULL||eitem->a_array[1]==NULL||eitem->a_array[2]==NULL) {
                    fprintf(stderr, "ArgumentList error\n");
                    break;
                }
                if (IsArray(eitem->a_array[1])||IsArray(eitem->a_array[1])) {
                    fprintf(stderr, "ArgumentList array error\n");
                }else{
                    double v1=GetValue(eitem->a_array[1]);
                    double v2=GetValue(eitem->a_array[2]);
                    if (v2==0.0) {
                        fprintf(stderr, "Division error\n");
                    }
                    *(eitem->a_array[0]->data.f_value)=v1 / v2;
                }
            }
                break;
            case '^':
            {
                if (eitem->a_array[0]==NULL||eitem->a_array[1]==NULL||eitem->a_array[2]==NULL) {
                    fprintf(stderr, "ArgumentList error\n");
                    break;
                }
                if (IsArray(eitem->a_array[1])||IsArray(eitem->a_array[1])) {
                    fprintf(stderr, "ArgumentList array error\n");
                }else{
                    double v1=GetValue(eitem->a_array[1]);
                    double v2=GetValue(eitem->a_array[2]);
                    *(eitem->a_array[0]->data.f_value)=pow(v1, v2);
                }
            }
                break;
            case '%':
            {
                if (eitem->a_array[0]==NULL||eitem->a_array[1]==NULL||eitem->a_array[2]==NULL) {
                    fprintf(stderr, "ArgumentList error\n");
                    break;
                }
                if (IsArray(eitem->a_array[1])||IsArray(eitem->a_array[1])) {
                    fprintf(stderr, "ArgumentList array error\n");
                }else{
                    double v1=GetValue(eitem->a_array[1]);
                    double v2=GetValue(eitem->a_array[2]);
                    *(eitem->a_array[0]->data.f_value)=(double)((int)v1 % (int)v2);
                }
            }
                break;
            case 'A':
            {
                if (eitem->a_array[0]==NULL||eitem->a_array[1]==NULL||eitem->a_array[2]==NULL) {
                    fprintf(stderr, "ArgumentList error\n");
                    break;
                }
                if (IsArray(eitem->a_array[1])||IsArray(eitem->a_array[1])) {
                    fprintf(stderr, "ArgumentList array error\n");
                }else{
                    double v1=GetValue(eitem->a_array[1]);
                    double v2=GetValue(eitem->a_array[2]);
                    if (v1 && v2) {
                        *(eitem->a_array[0]->data.f_value)=1;
                    }else{
                        *(eitem->a_array[0]->data.f_value)=0;
                    }
                }
            }
                break;
            case 'O':
            {
                if (eitem->a_array[0]==NULL||eitem->a_array[1]==NULL||eitem->a_array[2]==NULL) {
                    fprintf(stderr, "ArgumentList error\n");
                    break;
                }
                if (IsArray(eitem->a_array[1])||IsArray(eitem->a_array[1])) {
                    fprintf(stderr, "ArgumentList array error\n");
                }else{
                    double v1=GetValue(eitem->a_array[1]);
                    double v2=GetValue(eitem->a_array[2]);
                    if (v1 || v2) {
                        *(eitem->a_array[0]->data.f_value)=1;
                    }else{
                        *(eitem->a_array[0]->data.f_value)=0;
                    }
                }
            }
                break;
            case 'N':
            {
                if (eitem->a_array[0]==NULL||eitem->a_array[1]==NULL) {
                    fprintf(stderr, "ArgumentList error\n");
                    break;
                }
                if (IsArray(eitem->a_array[1])) {
                    fprintf(stderr, "ArgumentList array error\n");
                }else{
                    double v2=GetValue(eitem->a_array[1]);
                    if (v2) {
                        *(eitem->a_array[0]->data.f_value)=0;
                    }else{
                        *(eitem->a_array[0]->data.f_value)=1;
                    }
               }
            }
                break;
            case 'E':
            {
                if (eitem->a_array[0]==NULL||eitem->a_array[1]==NULL||eitem->a_array[2]==NULL) {
                    fprintf(stderr, "ArgumentList error\n");
                    break;
                }
                if (IsArray(eitem->a_array[1])||IsArray(eitem->a_array[1])) {
                    fprintf(stderr, "ArgumentList array error\n");
                }else{
                    double v1=GetValue(eitem->a_array[1]);
                    double v2=GetValue(eitem->a_array[2]);
                    if (v1 == v2) {
                        *(eitem->a_array[0]->data.f_value)=1;
                    }else{
                        *(eitem->a_array[0]->data.f_value)=0;
                    }
                }
            }
                break;
            case 'J':
            {
                if (eitem->a_array[0]==NULL) {
                    fprintf(stderr, "ArgumentList error\n");
                    break;
                }
                if (IsArray(eitem->a_array[0])) {
                    fprintf(stderr, "ArgumentList array error\n");
                }else{
                    double v1=GetValue(eitem->a_array[0]);
                    eitem->a_array[0]->bf_value=v1;
                    SetValue2(eitem->a_array[0], v1-1);
                }
            }
                break;
            case 'K':
            {
                if (eitem->a_array[0]==NULL) {
                    fprintf(stderr, "ArgumentList error\n");
                    break;
                }
                if (IsArray(eitem->a_array[0])) {
                    fprintf(stderr, "ArgumentList array error\n");
                }else{
                    double v1=GetValue(eitem->a_array[0]);
                    eitem->a_array[0]->bf_value=v1;
                    SetValue2(eitem->a_array[0], v1+1);
                }
            }
                break;
            case 'j':
            {
                if (eitem->a_array[0]==NULL) {
                    fprintf(stderr, "ArgumentList error\n");
                    break;
                }
                if (IsArray(eitem->a_array[0])) {
                    fprintf(stderr, "ArgumentList array error\n");
                }else{
                    double v1=GetValue(eitem->a_array[0]);
                    SetValue2(eitem->a_array[0], v1-1);
                }
            }
                break;
            case 'k':
            {
                if (eitem->a_array[0]==NULL) {
                    fprintf(stderr, "ArgumentList error\n");
                    break;
                }
                if (IsArray(eitem->a_array[0])) {
                    fprintf(stderr, "ArgumentList array error\n");
                }else{
                    double v1=GetValue(eitem->a_array[0]);
                    SetValue2(eitem->a_array[0], v1+1);
                }
            }
                break;
            case 'p':
            {
                if (eitem->arglist!=NULL) {
                    ArgumentList *witem=eitem->arglist;
                    while(witem!=NULL) {
                        if (witem->item==NULL) {
                            witem=witem->next;
                            continue;
                        }
                        ExprControl *aritem=(ExprControl*)witem->item;
                        if (aritem->type=='s') {
                            fprintf(app_out, "%s", aritem->a_array[0]->data.s_value);
                        }else if (IsArray(aritem->a_array[0])) {
                            PrintArray(aritem->a_array[0]);
                        }else{
                            if (IsValueString(aritem->a_array[0])) {
                                if (aritem->a_array[0]->type=='s') {
                                    fprintf(app_out, "%s", aritem->a_array[0]->data.s_value);
                                }else{
                                    char *str=GetValueString(aritem->a_array[0]);
                                    fprintf(app_out, "%s", str);
                                }
                            }else{
                                double v=GetValue(aritem->a_array[0]);
                                if (v==floor(v)) {
                                    long long vl=(long long)v;
                                    if (vl==LLONG_MAX) {
                                        fprintf(stderr, "overflow error\n");
                                    }
                                    fprintf(app_out, "%qi", vl);
                                }else{
                                    char buff[64];
                                    int nf=floor(log10(v));
                                    sprintf(buff, "%%.%df", 15-nf);
                                    fprintf(app_out, buff, v);
                                }
                            }
                        }
                        witem=witem->next;
                    }
                }else{
                    if (eitem->a_array[0]==NULL) {
                        fprintf(stderr, "ArgumentList error\n");
                        break;
                    }
                    double v=GetValue(eitem->a_array[0]);
                    if (v==floor(v)) {
                        long long vl=(long long)v;
                        if (vl==LLONG_MAX) {
                            fprintf(stderr, "overflow error\n");
                        }
                        fprintf(app_out, "%qi", vl);
                    }else{
                        fprintf(app_out, "%f", v);
                    }
                }
                if (eitem->a_array[0]==NULL) {
                    fprintf(stderr, "ArgumentList error\n");
                    break;
                }
                //if (eitem->a_array[0]->type!='f') {
                //    fprintf(stderr, "ArgumentList item type error\n");
                //    break;
                //}
                //float v0=GetValue(eitem->a_array[0]);
                //fprintf(app_out, "%f", v0);
            }
                break;
            case '>':
            {
                if (eitem->a_array[0]==NULL||eitem->a_array[1]==NULL||eitem->a_array[2]==NULL) {
                    fprintf(stderr, "ArgumentList error\n");
                    break;
                }
                double v1=GetValue(eitem->a_array[1]);
                double v2=GetValue(eitem->a_array[2]);
                if (v1 > v2) {
                    *(eitem->a_array[0]->data.f_value)=1;
                }else{
                    *(eitem->a_array[0]->data.f_value)=0;
                }
            }
                break;
            case '<':
            {
                if (eitem->a_array[0]==NULL||eitem->a_array[1]==NULL||eitem->a_array[2]==NULL) {
                    fprintf(stderr, "ArgumentList error\n");
                    break;
                }
                double v1=GetValue(eitem->a_array[1]);
                double v2=GetValue(eitem->a_array[2]);
                if (v1 < v2) {
                    *(eitem->a_array[0]->data.f_value)=1;
                }else{
                    *(eitem->a_array[0]->data.f_value)=0;
                }
            }
                break;
            case 'G':
            {
                if (eitem->a_array[0]==NULL||eitem->a_array[1]==NULL||eitem->a_array[2]==NULL) {
                    fprintf(stderr, "ArgumentList error\n");
                    break;
                }
                double v1=GetValue(eitem->a_array[1]);
                double v2=GetValue(eitem->a_array[2]);
                if (v1 >= v2) {
                    *(eitem->a_array[0]->data.f_value)=1;
                }else{
                    *(eitem->a_array[0]->data.f_value)=0;
                }
            }
                break;
            case 'L':
            {
                if (eitem->a_array[0]==NULL||eitem->a_array[1]==NULL||eitem->a_array[2]==NULL) {
                    fprintf(stderr, "ArgumentList error\n");
                    break;
                }
                double v1=GetValue(eitem->a_array[1]);
                double v2=GetValue(eitem->a_array[2]);
                if (v1 <= v2) {
                    *(eitem->a_array[0]->data.f_value)=1;
                }else{
                    *(eitem->a_array[0]->data.f_value)=0;
                }
            }
                break;
            case '=':
            {
                if (eitem->a_array[0]==NULL||eitem->a_array[1]==NULL) {
                    fprintf(stderr, "ArgumentList error\n");
                    break;
                }
                //if (eitem->a_array[0]->type!='f'||eitem->a_array[1]->type!='f') {
                //    fprintf(stderr, "ArgumentList item type error\n");
                //    break;
                //}
                if (IsArray(eitem->a_array[0])) {
                    if (eitem->eqflg=='e') {
                        SetValue2(eitem->a_array[0], eitem->a_array[1]->bf_value);
                    }else{
                        SetValue(eitem->a_array[0], eitem->a_array[1]);
                    }
                }else if (eitem->a_array[0]->type=='v') {
                    if (eitem->eqflg=='e') {
                        SetValue2(eitem->a_array[0], eitem->a_array[1]->bf_value);
                    }else{
                        if (eitem->a_array[1]->type=='H') {
                            CreateArrayValue(eitem->a_array[1]);
                            ArrayCopy(eitem->a_array[0], eitem->a_array[1]);
                        }else if (eitem->a_array[1]->type=='h') {
                            double v=GetArrayValue(eitem->a_array[1]);
                            SetValue2(eitem->a_array[0], v);
                        }else if (eitem->a_array[1]->type=='f') {
                            double v=GetValue(eitem->a_array[1]);
                            SetValue2(eitem->a_array[0], v);
                        }else{
                            SetValue(eitem->a_array[0], eitem->a_array[1]);
                        }
                    }
                }else if (eitem->a_array[0]->type=='h') {
                    if (eitem->eqflg=='e') {
                        SetValue2(eitem->a_array[0], eitem->a_array[1]->bf_value);
                    }else{
                        if (eitem->a_array[1]->type=='h') {
                            double v=GetArrayValue(eitem->a_array[1]);
                            SetValue2(eitem->a_array[0], v);
                        }else{
                            SetValue(eitem->a_array[0], eitem->a_array[1]);
                        }
                    }
                }else{
                    if (eitem->a_array[1]->type=='s') {
                        eitem->type='s';
                        eitem->a_array[0]->data.s_value=eitem->a_array[1]->data.s_value;
                    }else{
                        double v1=GetValue(eitem->a_array[1]);
                        *(eitem->a_array[0]->data.f_value)=v1;
                    }
                }
            }
                break;
            case 'h':
            {
                if (eitem->a_array[0]==NULL) {
                    fprintf(stderr, "ArgumentList error\n");
                    break;
                }
                //
                // eitem->arglistにアクセスし結果をa_array[0]に返す
                //
                if (eitem->a_array[0]->type=='v') {
                    if (eitem->eqflg=='e') {
                        SetValue2(eitem->a_array[0], eitem->a_array[1]->bf_value);
                    }else{
                        SetValue(eitem->a_array[0], eitem->a_array[1]);
                    }
                }else{
                    if (eitem->a_array[1]->type=='s') {
                        eitem->type='s';
                        eitem->a_array[0]->data.s_value=eitem->a_array[1]->data.s_value;
                    }else{
                        double v1=GetValue(eitem->a_array[1]);
                        *(eitem->a_array[0]->data.f_value)=v1;
                    }
                }
            }
                break;
                /*
            case 'H':
            {
                if (eitem->a_array[0]==NULL) {
                    fprintf(stderr, "ArgumentList error\n");
                    break;
                }
                //
                // eitem->arglistを変換しa_array[0]のnameに登録する
                //
                if (eitem->a_array[0]->type=='v') {
                    if (eitem->eqflg=='e') {
                        SetValue2(eitem->a_array[0], eitem->a_array[1]->bf_value);
                    }else{
                        SetValue(eitem->a_array[0], eitem->a_array[1]);
                    }
                }else{
                    if (eitem->a_array[1]->type=='s') {
                        eitem->type='s';
                        eitem->a_array[0]->data.s_value=eitem->a_array[1]->data.s_value;
                    }else{
                        double v1=GetValue(eitem->a_array[1]);
                        *(eitem->a_array[0]->data.f_value)=v1;
                    }
                }
            }
                break;
                 */
            case 'I':
            {
                if (eitem->a_array[0]!=NULL) {
                    loopflag=RunCommandList(arg_dict,rval, eitem->a_array[1]->data.c_list);
                    if ((eitem->a_array[0]!=0)&&(*(eitem->a_array[0]->data.f_value)!=0)) {
                        loopflag=RunCommandList(arg_dict,rval, eitem->a_array[2]->data.c_list);
                    }else{
                        if (eitem->a_array[3]!=0) {
                            loopflag=RunCommandList(arg_dict,rval, eitem->a_array[3]->data.c_list);
                        }
                    }
                }
            }
                break;
            case 'W':
            {
                while(true) {
                    if (eitem->a_array[0]!=0) {
                        loopflag=RunCommandList(arg_dict, rval, eitem->a_array[1]->data.c_list);
                    }
                    if ((eitem->a_array[0]!=0)&&(*(eitem->a_array[0]->data.f_value)!=0)) {
                        loopflag=RunCommandList(arg_dict, rval, eitem->a_array[2]->data.c_list);
                    }else{
                        break;
                    }
                }
            }
                break;
            case 'F':
            {
                if (eitem->a_array[1]!=0) {
                    loopflag=RunCommandList(arg_dict, rval, eitem->a_array[1]->data.c_list);
                }
                while(true) {
                    if (eitem->a_array[2]!=0) {
                        loopflag=RunCommandList(arg_dict, rval, eitem->a_array[2]->data.c_list);
                    }
                    if ((eitem->a_array[0]!=0)&&(*(eitem->a_array[0]->data.f_value)!=0)) {
                        loopflag=RunCommandList(arg_dict, rval, eitem->a_array[4]->data.c_list);
                    }else{
                        break;
                    }
                    if (eitem->a_array[3]!=0) {
                        loopflag=RunCommandList(arg_dict, rval, eitem->a_array[3]->data.c_list);
                    }
                }
            }
                break;
            case 'c':
            {
                if (eitem->a_array[0]==NULL||eitem->a_array[1]==NULL) {
                    fprintf(stderr, "ArgumentList error\n");
                    break;
                }
                FunctionControl *fctnl=GetFunctionData(eitem->a_array[1]->data.s_value);
                NSMutableDictionary *bak_dict=arg_dict;
                if (fctnl!=NULL) {
                    NSMutableDictionary *new_dict=[[NSMutableDictionary alloc] init];
                    gl_vdict=new_dict;
                    //gl_fnc_vdict=new_dict;
                    /*
                     if (eitem->arglist!=NULL) {
                     ArgumentList *witem=eitem->arglist;
                     while(witem!=NULL) {
                     ExprControl *aritem=(ExprControl*)witem->item;
                     CopyValue(aritem->a_array[0]);
                     witem=witem->next;
                     }
                     }
                     */
                    // 引数を対応させる
                    ArgumentList *witem=eitem->arglist;
                    ArgumentList *fitem=fctnl->arg_list;
                    while(witem!=NULL) {
                        if (fitem==NULL) {
                            break;
                        }
                        ExprControl *aritem=(ExprControl*)witem->item;
                        ExprControl *fritem=(ExprControl*)fitem->item;
                        //SetValue(fritem->a_array[0], aritem->a_array[0]);
                        CopyValue(gl_vdict, fritem->a_array[0], bak_dict, aritem->a_array[0]);
                        witem=witem->next;
                        fitem=fitem->next;
                    }
                    // return 値格納用変数の設定
                    return_value=eitem->a_array[0];
                    // 処理実行
                    RunCommandList(new_dict, eitem->a_array[0], fctnl->cmd_list);
                }else{
                    BOOL call_flag=NO;
                    if ((strlen(eitem->a_array[1]->data.s_value)==3)&&(strncmp(eitem->a_array[1]->data.s_value, "sin", 3)==0)) {
                        ExprControl *arg_item=GetArgumentList(eitem->arglist, 0);
                        if (arg_item!=NULL) {
                            double v1=GetValue(arg_item->a_array[0]);
                            if (deg_or_rad_falg) {
                                *(eitem->a_array[0]->data.f_value)=sin(v1);
                            }else{
                                *(eitem->a_array[0]->data.f_value)=sin((v1*M_PI)/180.0);
                            }
                        }else{
                            fprintf(stderr, "Argument error %s\n", eitem->a_array[1]->data.s_value);
                        }
                        call_flag=YES;
                    }
                    if ((strlen(eitem->a_array[1]->data.s_value)==3)&&(strncmp(eitem->a_array[1]->data.s_value, "cos", 3)==0)) {
                        ExprControl *arg_item=GetArgumentList(eitem->arglist, 0);
                        if (arg_item!=NULL) {
                            double v1=GetValue(arg_item->a_array[0]);
                            if (deg_or_rad_falg) {
                                *(eitem->a_array[0]->data.f_value)=cos(v1);
                            }else{
                                *(eitem->a_array[0]->data.f_value)=cos((v1*M_PI)/180.0);
                            }
                        }else{
                            fprintf(stderr, "Argument error %s\n", eitem->a_array[1]->data.s_value);
                        }
                        call_flag=YES;
                    }
                    if ((strlen(eitem->a_array[1]->data.s_value)==3)&&(strncmp(eitem->a_array[1]->data.s_value, "tan", 3)==0)) {
                        ExprControl *arg_item=GetArgumentList(eitem->arglist, 0);
                        if (arg_item!=NULL) {
                            double v1=GetValue(arg_item->a_array[0]);
                            if (deg_or_rad_falg) {
                                *(eitem->a_array[0]->data.f_value)=tan(v1);
                            }else{
                                *(eitem->a_array[0]->data.f_value)=tan((v1*M_PI)/180.0);
                            }
                        }else{
                            fprintf(stderr, "Argument error %s\n", eitem->a_array[1]->data.s_value);
                        }
                        call_flag=YES;
                    }
                    if ((strlen(eitem->a_array[1]->data.s_value)==4)&&(strncmp(eitem->a_array[1]->data.s_value, "asin", 4)==0)) {
                        ExprControl *arg_item=GetArgumentList(eitem->arglist, 0);
                        if (arg_item!=NULL) {
                            double v1=GetValue(arg_item->a_array[0]);
                            if (deg_or_rad_falg) {
                                *(eitem->a_array[0]->data.f_value)=asin(v1);
                            }else{
                                *(eitem->a_array[0]->data.f_value)=(asin(v1)/M_PI)*180.0;
                            }
                        }else{
                            fprintf(stderr, "Argument error %s\n", eitem->a_array[1]->data.s_value);
                        }
                        call_flag=YES;
                    }
                    if ((strlen(eitem->a_array[1]->data.s_value)==4)&&(strncmp(eitem->a_array[1]->data.s_value, "acos", 4)==0)) {
                        ExprControl *arg_item=GetArgumentList(eitem->arglist, 0);
                        if (arg_item!=NULL) {
                            double v1=GetValue(arg_item->a_array[0]);
                            if (deg_or_rad_falg) {
                                *(eitem->a_array[0]->data.f_value)=acos(v1);
                            }else{
                                *(eitem->a_array[0]->data.f_value)=(acos(v1)/M_PI)*180.0;
                            }
                        }else{
                            fprintf(stderr, "Argument error %s\n", eitem->a_array[1]->data.s_value);
                        }
                        call_flag=YES;
                    }
                    if ((strlen(eitem->a_array[1]->data.s_value)==4)&&(strncmp(eitem->a_array[1]->data.s_value, "atan", 4)==0)) {
                        ExprControl *arg_item=GetArgumentList(eitem->arglist, 0);
                        if (arg_item!=NULL) {
                            double v1=GetValue(arg_item->a_array[0]);
                            if (deg_or_rad_falg) {
                                *(eitem->a_array[0]->data.f_value)=atan(v1);
                            }else{
                                *(eitem->a_array[0]->data.f_value)=(atan(v1)/M_PI)*180.0;
                            }
                        }else{
                            fprintf(stderr, "Argument error %s\n", eitem->a_array[1]->data.s_value);
                        }
                        call_flag=YES;
                    }
                    if ((strlen(eitem->a_array[1]->data.s_value)==4)&&(strncmp(eitem->a_array[1]->data.s_value, "sqrt", 4)==0)) {
                        ExprControl *arg_item=GetArgumentList(eitem->arglist, 0);
                        if (arg_item!=NULL) {
                            double v1=GetValue(arg_item->a_array[0]);
                            *(eitem->a_array[0]->data.f_value)=sqrt(v1);
                        }else{
                            fprintf(stderr, "Argument error %s\n", eitem->a_array[1]->data.s_value);
                        }
                        call_flag=YES;
                    }
                    if ((strlen(eitem->a_array[1]->data.s_value)==5)&&(strncmp(eitem->a_array[1]->data.s_value, "atan2", 5)==0)) {
                        ExprControl *arg_item=GetArgumentList(eitem->arglist, 0);
                        ExprControl *arg_item2=GetArgumentList(eitem->arglist, 1);
                        if (arg_item2==NULL) {
                            fprintf(stderr, "atan2 argument error\n");
                        }else{
                            if (arg_item!=NULL) {
                                double v1=GetValue(arg_item->a_array[0]);
                                double v2=GetValue(arg_item2->a_array[0]);
                                if (deg_or_rad_falg) {
                                    *(eitem->a_array[0]->data.f_value)=atan2(v1,v2);
                                }else{
                                    *(eitem->a_array[0]->data.f_value)=(atan2(v1,v2)/M_PI)*180.0;
                                }
                            }
                        }
                        call_flag=YES;
                    }
                    if ((strlen(eitem->a_array[1]->data.s_value)==3)&&(strncmp(eitem->a_array[1]->data.s_value, "log", 3)==0)) {
                        ExprControl *arg_item=GetArgumentList(eitem->arglist, 0);
                        if (arg_item!=NULL) {
                            double v1=GetValue(arg_item->a_array[0]);
                            *(eitem->a_array[0]->data.f_value)=log10(v1);
                        }else{
                            fprintf(stderr, "Argument error %s\n", eitem->a_array[1]->data.s_value);
                        }
                        call_flag=YES;
                    }
                    if ((strlen(eitem->a_array[1]->data.s_value)==3)&&(strncmp(eitem->a_array[1]->data.s_value, "nCr", 3)==0)) {
                        ExprControl *arg_item=GetArgumentList(eitem->arglist, 0);
                        ExprControl *arg_item2=GetArgumentList(eitem->arglist, 1);
                        if (arg_item2==NULL) {
                            fprintf(stderr, "nCr argument error\n");
                        }else{
                            if (arg_item!=NULL) {
                                double v1=GetValue(arg_item->a_array[0]);
                                double v2=GetValue(arg_item2->a_array[0]);
                                long long p=ftA(floor(v1), floor(v2));
                                if (p>0) {
                                    long long r=ft(floor(v2));
                                    *(eitem->a_array[0]->data.f_value)=p/r;
                                }
                            }
                        }
                        call_flag=YES;
                    }
                    if ((strlen(eitem->a_array[1]->data.s_value)==3)&&(strncmp(eitem->a_array[1]->data.s_value, "nPr", 3)==0)) {
                        ExprControl *arg_item=GetArgumentList(eitem->arglist, 0);
                        ExprControl *arg_item2=GetArgumentList(eitem->arglist, 1);
                        if (arg_item2==NULL) {
                            fprintf(stderr, "nPr argument error\n");
                        }else{
                            if (arg_item!=NULL) {
                                double v1=GetValue(arg_item->a_array[0]);
                                double v2=GetValue(arg_item2->a_array[0]);
                                long long p=ftA(floor(v1), floor(v2));
                                *(eitem->a_array[0]->data.f_value)=p;
                            }
                        }
                        call_flag=YES;
                    }
                    if ((strlen(eitem->a_array[1]->data.s_value)==2)&&(strncmp(eitem->a_array[1]->data.s_value, "ln", 3)==0)) {
                        ExprControl *arg_item=GetArgumentList(eitem->arglist, 0);
                        if (arg_item!=NULL) {
                            double v1=GetValue(arg_item->a_array[0]);
                            *(eitem->a_array[0]->data.f_value)=log(v1);
                        }else{
                            fprintf(stderr, "Argument error %s\n", eitem->a_array[1]->data.s_value);
                        }
                        call_flag=YES;
                    }
                    if ((strlen(eitem->a_array[1]->data.s_value)==2)&&(strncmp(eitem->a_array[1]->data.s_value, "ex", 2)==0)) {
                        ExprControl *arg_item=GetArgumentList(eitem->arglist, 0);
                        if (arg_item!=NULL) {
                            double v1=GetValue(arg_item->a_array[0]);
                            *(eitem->a_array[0]->data.f_value)=pow(M_E, v1);
                        }else{
                            fprintf(stderr, "Argument error %s\n", eitem->a_array[1]->data.s_value);
                        }
                        call_flag=YES;
                    }
                    if ((strlen(eitem->a_array[1]->data.s_value)==2)&&(strncmp(eitem->a_array[1]->data.s_value, "x2", 2)==0)) {
                        ExprControl *arg_item=GetArgumentList(eitem->arglist, 0);
                        if (arg_item!=NULL) {
                            double v1=GetValue(arg_item->a_array[0]);
                            *(eitem->a_array[0]->data.f_value)=v1 * v1;
                        }else{
                            fprintf(stderr, "Argument error %s\n", eitem->a_array[1]->data.s_value);
                        }
                        call_flag=YES;
                    }
                    if ((strlen(eitem->a_array[1]->data.s_value)==2)&&(strncmp(eitem->a_array[1]->data.s_value, "tx", 2)==0)) {
                        ExprControl *arg_item=GetArgumentList(eitem->arglist, 0);
                        if (arg_item!=NULL) {
                            double v1=GetValue(arg_item->a_array[0]);
                            *(eitem->a_array[0]->data.f_value)=pow(10.0, v1);
                        }else{
                            fprintf(stderr, "Argument error %s\n", eitem->a_array[1]->data.s_value);
                        }
                        call_flag=YES;
                    }
                    // rand
                    if ((strlen(eitem->a_array[1]->data.s_value)==4)&&(strncmp(eitem->a_array[1]->data.s_value, "rand", 4)==0)) {
                        *(eitem->a_array[0]->data.f_value)=rand();
                        call_flag=YES;
                    }
                    // abs
                    if ((strlen(eitem->a_array[1]->data.s_value)==3)&&(strncmp(eitem->a_array[1]->data.s_value, "abs", 3)==0)) {
                        ExprControl *arg_item=GetArgumentList(eitem->arglist, 0);
                        if (arg_item!=NULL) {
                            double v1=GetValue(arg_item->a_array[0]);
                            *(eitem->a_array[0]->data.f_value)=fabsf(v1);
                        }else{
                            fprintf(stderr, "Argument error %s\n", eitem->a_array[1]->data.s_value);
                        }
                        call_flag=YES;
                    }
                    // floor
                    if ((strlen(eitem->a_array[1]->data.s_value)==5)&&(strncmp(eitem->a_array[1]->data.s_value, "floor", 5)==0)) {
                        ExprControl *arg_item=GetArgumentList(eitem->arglist, 0);
                        if (arg_item!=NULL) {
                            double v1=GetValue(arg_item->a_array[0]);
                            *(eitem->a_array[0]->data.f_value)=floor(v1);
                        }else{
                            fprintf(stderr, "Argument error %s\n", eitem->a_array[1]->data.s_value);
                        }
                        call_flag=YES;
                    }
                    // ceil
                    if ((strlen(eitem->a_array[1]->data.s_value)==4)&&(strncmp(eitem->a_array[1]->data.s_value, "ceil", 4)==0)) {
                        ExprControl *arg_item=GetArgumentList(eitem->arglist, 0);
                        if (arg_item!=NULL) {
                            double v1=GetValue(arg_item->a_array[0]);
                            *(eitem->a_array[0]->data.f_value)=ceilf(v1);
                        }else{
                            fprintf(stderr, "Argument error %s\n", eitem->a_array[1]->data.s_value);
                        }
                        call_flag=YES;
                    }
                    // graph
                    if ((strlen(eitem->a_array[1]->data.s_value)==5)&&(strncmp(eitem->a_array[1]->data.s_value, "graph", 5)==0)) {
                        ExprControl *arg_item=GetArgumentList(eitem->arglist, 0);
                        ExprControl *arg_item2=GetArgumentList(eitem->arglist, 1);
                        if (arg_item2==NULL) {
                            fprintf(stderr, "graph argument error\n");
                        }else{
                            if (arg_item->a_array[0]->type!='s') {
                                fprintf(stderr, "graph argument error\n");
                            }else{
                                AddGraphData(arg_item->a_array[0]->data.s_value, arg_item2);
                            }
                        }
                        call_flag=YES;
                    }
                    // ft
                    if ((strlen(eitem->a_array[1]->data.s_value)==2)&&(strncmp(eitem->a_array[1]->data.s_value, "ft", 2)==0)) {
                        ExprControl *arg_item=GetArgumentList(eitem->arglist, 0);
                        if (arg_item!=NULL) {
                            long v1=(long)GetValue(arg_item->a_array[0]);
                            long long ret=ft((int)v1);
                            *(eitem->a_array[0]->data.f_value)=(double)ret;
                        }else{
                            fprintf(stderr, "Argument error %s\n", eitem->a_array[1]->data.s_value);
                        }
                        call_flag=YES;
                    }
                    // degmode
                    if ((strlen(eitem->a_array[1]->data.s_value)==7)&&(strncmp(eitem->a_array[1]->data.s_value, "degmode", 7)==0)) {
                        deg_or_rad_falg=NO;
                        call_flag=YES;
                    }
                    // redmode
                    if ((strlen(eitem->a_array[1]->data.s_value)==7)&&(strncmp(eitem->a_array[1]->data.s_value, "radmode", 7)==0)) {
                        deg_or_rad_falg=YES;
                        call_flag=YES;
                    }
                    // array size
                    if ((strlen(eitem->a_array[1]->data.s_value)==12)&&(strncmp(eitem->a_array[1]->data.s_value, "arrayRowSize", 12)==0)) {
                        ExprControl *arg_item=GetArgumentList(eitem->arglist, 0);
                        if (arg_item!=NULL) {
                            double v=(double)arrayRowSize(arg_item->a_array[0]);
                            *(eitem->a_array[0]->data.f_value)=(double)v;
                        }else{
                            fprintf(stderr, "Argument error %s\n", eitem->a_array[1]->data.s_value);
                        }
                        call_flag=YES;
                    }
                    // array size
                    if ((strlen(eitem->a_array[1]->data.s_value)==12)&&(strncmp(eitem->a_array[1]->data.s_value, "arrayColSize", 12)==0)) {
                        ExprControl *arg_item=GetArgumentList(eitem->arglist, 0);
                        if (arg_item!=NULL) {
                            double v=(double)arrayColSize(arg_item->a_array[0]);
                            *(eitem->a_array[0]->data.f_value)=(double)v;
                        }else{
                            fprintf(stderr, "Argument error %s\n", eitem->a_array[1]->data.s_value);
                        }
                        call_flag=YES;
                    }
                    if ((strlen(eitem->a_array[1]->data.s_value)==8)&&(strncmp(eitem->a_array[1]->data.s_value, "addArray", 8)==0)) {
                        ExprControl *arg_item=GetArgumentList(eitem->arglist, 0);
                        ExprControl *arg_item2=GetArgumentList(eitem->arglist, 1);
                        if (arg_item2==NULL) {
                            fprintf(stderr, "graph argument error\n");
                        }else{
                            ArrayAddItem(arg_item->a_array[0],arg_item2->a_array[0]);
                        }
                        call_flag=YES;
                    }
                    if ((strlen(eitem->a_array[1]->data.s_value)==10)&&(strncmp(eitem->a_array[1]->data.s_value, "clearArray", 10)==0)) {
                        ExprControl *arg_item=GetArgumentList(eitem->arglist, 0);
                        ArrayClear(arg_item->a_array[0]);
                        call_flag=YES;
                    }
                    if ((strlen(eitem->a_array[1]->data.s_value)==11)&&(strncmp(eitem->a_array[1]->data.s_value, "createArray", 11)==0)) {
                        ArrayCreate(eitem->a_array[0]);
                        call_flag=YES;
                    }
                    if ((strlen(eitem->a_array[1]->data.s_value)==6)&&(strncmp(eitem->a_array[1]->data.s_value, "isNull", 6)==0)) {
                        ExprControl *arg_item=GetArgumentList(eitem->arglist, 0);
                        double v=isNull(arg_item->a_array[0]);
                        *(eitem->a_array[0]->data.f_value)=v;
                        call_flag=YES;
                    }
                    if ((strlen(eitem->a_array[1]->data.s_value)==4)&&(strncmp(eitem->a_array[1]->data.s_value, "exit", 4)==0)) {
                        break_flag=YES;
                        call_flag=YES;
                    }
                    if (call_flag==NO) {
                        fprintf(stderr, "call error %s\n", eitem->a_array[1]->data.s_value);
                    }
                }
                
                gl_vdict=bak_dict;
            }
                break;
            case 'r':
            {
                if (eitem->a_array[1]==NULL) {
                    *(rval->data.f_value)=0;
                }else{
                    if (eitem->a_array[1]->type=='s') {
                        rval->type='s';
                        rval->data.s_value=eitem->a_array[1]->data.s_value;
                    }else{
                        double v1=(double)GetValue(eitem->a_array[1]);
                        *(rval->data.f_value)=v1;
                    }
                }
                loopflag=NO;
            }
                break;
        }
        witem=witem->next;
    }
    deg_or_rad_falg=deg_or_rad_falg_bak;
    return loopflag;
}
ArgumentList *CreateArgumentList() {
    ArgumentList *ret_val=(ArgumentList*)m_memalloc(sizeof(ArgumentList));
    if (ret_val==NULL) {
        fprintf(stderr, "CreateArgumentList malloc error\n");
    }
    ret_val->next=NULL;
    ret_val->item=NULL;
    return ret_val;
}
ArgumentList *AddStringArgumentList(ArgumentList *arg_list, StringItem arg_item) {
    ArgumentList *ret_val=(ArgumentList*)m_memalloc(sizeof(ArgumentList));
    if (ret_val==NULL) {
        fprintf(stderr, "AddStringArgumentList malloc error\n");
        return NULL;
    }
    ret_val->next=arg_list;
    StringItem *string_item=(StringItem*)m_memalloc(sizeof(StringItem));
    if (string_item==NULL) {
        fprintf(stderr, "AddStringArgumentList item malloc error\n");
        return NULL;
    }
    *string_item=arg_item;
    ret_val->item=string_item;
    return ret_val;
}
ArgumentList *AddIntArgumentList(ArgumentList *arg_list, IntItem arg_item) {
    ArgumentList *ret_val=(ArgumentList*)m_memalloc(sizeof(ArgumentList));
    if (ret_val==NULL) {
        fprintf(stderr, "AddIntArgumentList malloc error\n");
        return NULL;
    }
    arg_list->next=ret_val;
    IntItem *int_item=(IntItem*)m_memalloc(sizeof(IntItem));
    if (int_item==NULL) {
        fprintf(stderr, "AddIntArgumentList item malloc error\n");
        return NULL;
    }
    *int_item=arg_item;
    ret_val->item=int_item;
    return ret_val;
}
int arrayRowSize(TokenControl *arg_get_value) {
    NSString* get_name_str;
    if (arg_get_value->vname==NULL) {
        if (arg_get_value->data.s_value==NULL) {
            return 0;
        }
        get_name_str = [NSString stringWithCString: arg_get_value->data.s_value encoding:NSUTF8StringEncoding];
        arg_get_value->vname=arg_get_value->data.s_value;
    }else{
        get_name_str = [NSString stringWithCString: arg_get_value->vname encoding:NSUTF8StringEncoding];
    }
    NSObject *obj=[gl_vdict objectForKey:get_name_str];
    if (obj==nil) {
        return 0;
    }else{
        if ([obj isKindOfClass:[NSMutableDictionary class]]) {
            NSMutableDictionary *dict=(NSMutableDictionary*)obj;
            NSArray *key=[dict allKeys];
            return (int)[key count];
        }
    }
    return 0;
}
int arrayColSize(TokenControl *arg_get_value) {
    NSString* get_name_str;
    if (arg_get_value->vname==NULL) {
        if (arg_get_value->data.s_value==NULL) {
            return 0;
        }
        get_name_str = [NSString stringWithCString: arg_get_value->data.s_value encoding:NSUTF8StringEncoding];
        arg_get_value->vname=arg_get_value->data.s_value;
    }else{
        get_name_str = [NSString stringWithCString: arg_get_value->vname encoding:NSUTF8StringEncoding];
    }
    NSObject *obj=[gl_vdict objectForKey:get_name_str];
    if (obj==nil) {
        return 0;
    }else{
        if ([obj isKindOfClass:[NSMutableDictionary class]]) {
            NSMutableDictionary *dict=(NSMutableDictionary*)obj;
            NSArray *key=[dict allKeys];
            NSObject *obj2=[dict objectForKey:[key objectAtIndex:0]];
            if ([obj2 isKindOfClass:[NSMutableDictionary class]]) {
                NSMutableDictionary *dict2=(NSMutableDictionary*)obj2;
                NSArray *key2=[dict2 allKeys];
                return (int)[key2 count];
            }else{
                return 0;
            }
        }
    }
    return 0;
}
void ArrayClear(TokenControl *arg_set_value) {
    NSString* set_name_str;
    if (arg_set_value->vname==NULL) {
        if (arg_set_value->data.s_value==NULL) {
            return;
        }
        set_name_str = [NSString stringWithCString: arg_set_value->data.s_value encoding:NSUTF8StringEncoding];
    }else{
        set_name_str = [NSString stringWithCString: arg_set_value->vname encoding:NSUTF8StringEncoding];
    }
    NSObject *obj=[gl_vdict objectForKey:set_name_str];
    if (obj==nil) {
        return;
    }else{
        NSMutableDictionary *wdict=(NSMutableDictionary*)obj;
        [wdict removeAllObjects];
    }
}
void ArrayCreate(TokenControl *arg_set_value) {
    NSString* set_name_str;
    arg_set_value->type='v';
    arg_set_value->vname=NewArrayName();
    set_name_str = [NSString stringWithCString: arg_set_value->vname encoding:NSUTF8StringEncoding];
    NSObject *obj=[gl_vdict objectForKey:set_name_str];
    if (obj==nil) {
        NSMutableDictionary *wdict=[[NSMutableDictionary alloc] init];
        [gl_vdict setObject:wdict forKey:set_name_str];
        return;
    }else{
        NSMutableDictionary *wdict=(NSMutableDictionary*)obj;
        [wdict removeAllObjects];
    }
}
void ArrayAddItem(TokenControl *arg_set_value,TokenControl *arg_get_value) {
    NSString* set_name_str;
    if (arg_set_value->vname==NULL) {
        if (arg_set_value->data.s_value==NULL) {
            return;
        }
        set_name_str = [NSString stringWithCString: arg_set_value->data.s_value encoding:NSUTF8StringEncoding];
    }else{
        set_name_str = [NSString stringWithCString: arg_set_value->vname encoding:NSUTF8StringEncoding];
    }
    NSObject *obj=[gl_vdict objectForKey:set_name_str];
    if (obj==nil) {
        return;
    }else{
        NSMutableDictionary *wdict=(NSMutableDictionary*)obj;
        if (IsArray(arg_get_value)) {
            NSString *get_name_str;
            if (arg_get_value->vname==NULL) {
                get_name_str = [NSString stringWithCString: arg_get_value->data.s_value encoding:NSUTF8StringEncoding];
                if ([gl_vdict objectForKey:get_name_str]==nil) {
                    CreateArrayValue(arg_get_value);
                    get_name_str = [NSString stringWithCString: arg_get_value->vname encoding:NSUTF8StringEncoding];
                }
            }else{
                arg_get_value->vname=NULL;
                CreateArrayValue(arg_get_value);
                get_name_str = [NSString stringWithCString: arg_get_value->vname encoding:NSUTF8StringEncoding];
            }
            NSMutableDictionary *wdict_item=[gl_vdict objectForKey:get_name_str];
            for(int i=0; ; i++) {
                NSString *wkey=[NSString stringWithFormat:@"%d", i];
                if ([wdict objectForKey:wkey]==nil) {
                    [wdict setObject:wdict_item forKey:wkey];
                    return;
                }
            }
            return;
        }
        if ([obj isKindOfClass:[NSMutableDictionary class]]==NO) {
            NSMutableDictionary *newdict=[[NSMutableDictionary alloc] initWithDictionary:(NSMutableDictionary*)obj copyItems:NO];
            for(int i=0; ; i++) {
                NSString *wkey=[NSString stringWithFormat:@"%d", i];
                if ([wdict objectForKey:wkey]==nil) {
                    [wdict setObject:newdict forKey:wkey];
                    return;
                }
            }
            return;
        }
        if (IsValueString(arg_get_value)) {
            char *wstr=GetValueString(arg_get_value);
            for(int i=0; ; i++) {
                NSString *wkey=[NSString stringWithFormat:@"%d", i];
                if ([wdict objectForKey:wkey]==nil) {
                    NSString *str= [NSString stringWithCString: wstr encoding:NSUTF8StringEncoding];
                    [wdict setObject:str forKey:wkey];
                    return;
                }
            }
            return;
        }else{
            double v=GetValue(arg_get_value);
            for(int i=0; ; i++) {
                NSString *wkey=[NSString stringWithFormat:@"%d", i];
                if ([wdict objectForKey:wkey]==nil) {
                    [wdict setObject:[NSNumber numberWithDouble:v] forKey:wkey];
                    return;
                }
            }
        }
    }
    
}
int isNull(TokenControl *arg_set_value) {
    NSString* set_name_str;
    if (arg_set_value->vname==NULL) {
        if (arg_set_value->data.s_value==NULL) {
            return 1;
        }
        set_name_str = [NSString stringWithCString: arg_set_value->data.s_value encoding:NSUTF8StringEncoding];
    }else{
        set_name_str = [NSString stringWithCString: arg_set_value->vname encoding:NSUTF8StringEncoding];
    }
    NSObject *obj=[gl_vdict objectForKey:set_name_str];
    if (obj==nil) {
        return 1;
    }
    return 0;
}
char *NewArrayName() {
    int n=0;
    while(true) {
        NSString *key_name=[NSString stringWithFormat:@"__array%d", n++];
        NSObject *dobj=[gl_vdict objectForKey:key_name];
        if (dobj==nil) {
            char *keystr=(char *)[key_name UTF8String];
            return strMemCopy(keystr);
        }
    }
}
void ArrayCopyProc(NSMutableDictionary *dist_dict,NSMutableDictionary *src_dict) {
    NSArray *src_key=[src_dict allKeys];
    for(NSString *src_key_name in src_key) {
        NSObject *gobj=[src_dict objectForKey:src_key_name];
        if ([gobj isKindOfClass:[NSMutableDictionary class]]) {
            NSMutableDictionary *new_dict=[[NSMutableDictionary alloc] init];
            [dist_dict setObject:new_dict forKey:src_key_name];
            ArrayCopyProc(new_dict, (NSMutableDictionary*)gobj);
        }else{
            [dist_dict setObject:gobj forKey:src_key_name];
        }
    }
}
void ArrayCopy(TokenControl *arg_set_value,TokenControl *arg_get_value) {
    NSString* str;
    if (arg_get_value->vname==NULL) {
        if (arg_get_value->data.s_value==NULL) {
            return;
        }
        str = [NSString stringWithCString: arg_get_value->data.s_value encoding:NSUTF8StringEncoding];
    }else{
        str = [NSString stringWithCString: arg_get_value->vname encoding:NSUTF8StringEncoding];
    }
    NSObject *obj=[gl_vdict objectForKey:str];
    if ([obj isKindOfClass:[NSMutableDictionary class]]==NO) {
        return;
    }
    NSMutableDictionary *src_dict=(NSMutableDictionary*)obj;
    NSString* diststr;
    if (arg_set_value->vname==NULL) {
        if (arg_set_value->data.s_value==NULL) {
            return;
        }
        diststr = [NSString stringWithCString: arg_set_value->data.s_value encoding:NSUTF8StringEncoding];
    }else{
        diststr = [NSString stringWithCString: arg_set_value->vname encoding:NSUTF8StringEncoding];
    }
    NSMutableDictionary *new_dict=[[NSMutableDictionary alloc] initWithDictionary:src_dict copyItems:YES];
    [gl_vdict setObject:new_dict forKey:diststr];
    //ArrayCopyProc(new_dict,src_dict);
}
void ArrayAdd(TokenControl *arg_set_value, char *aname,TokenControl *arg_get_value1,TokenControl *arg_get_value2) {
    NSString* str;
    if (arg_get_value1->vname==NULL) {
        if (arg_get_value1->data.s_value==NULL) {
            return;
        }
        str = [NSString stringWithCString: arg_get_value1->data.s_value encoding:NSUTF8StringEncoding];
    }else{
        str = [NSString stringWithCString: arg_get_value1->vname encoding:NSUTF8StringEncoding];
    }
    arg_set_value->vname=aname;
    NSString* dist_str = [NSString stringWithCString: aname encoding:NSUTF8StringEncoding];
    NSMutableDictionary *new_dict=[[NSMutableDictionary alloc] init];
    [gl_vdict setObject:new_dict forKey:dist_str];
    NSObject *obj=[gl_vdict objectForKey:str];
    if ([obj isKindOfClass:[NSMutableDictionary class]]==NO) {
        return;
    }
    NSMutableDictionary *src_dict=(NSMutableDictionary*)obj;
    ArrayCopyProc(new_dict,src_dict);
    NSString* str2;
    if (arg_get_value2->vname==NULL) {
        if (arg_get_value2->data.s_value==NULL) {
            return;
        }
        str2 = [NSString stringWithCString: arg_get_value2->data.s_value encoding:NSUTF8StringEncoding];
    }else{
        str2 = [NSString stringWithCString: arg_get_value2->vname encoding:NSUTF8StringEncoding];
    }
    NSObject *obj2=[gl_vdict objectForKey:str2];
    if ([obj2 isKindOfClass:[NSMutableDictionary class]]==NO) {
        return;
    }
    NSMutableDictionary *src_dict2=(NSMutableDictionary*)obj2;
    for(NSString *kname in [new_dict allKeys]) {
        NSMutableDictionary *dist_dict=[new_dict objectForKey:kname];
        NSMutableDictionary *wk_dict=[src_dict2 objectForKey:kname];
        for(NSString *kname2 in [dist_dict allKeys]) {
            NSObject *dist_obj=[dist_dict objectForKey:kname2];
            NSObject *src_obj=[wk_dict objectForKey:kname2];
            if (dist_obj==nil||src_obj==nil) {
                continue;
            }
            if ([dist_obj isKindOfClass:[NSNumber class]]==NO) {
                continue;
            }
            if ([src_obj isKindOfClass:[NSNumber class]]==NO) {
                continue;
            }
            double dict_vn=[(NSNumber*)dist_obj doubleValue];
            double src_vn=[(NSNumber*)src_obj doubleValue];
            [dist_dict setObject:[NSNumber numberWithDouble:dict_vn+src_vn] forKey:kname2];
        }
    }
}
void ArraySub(TokenControl *arg_set_value, char *aname,TokenControl *arg_get_value1,TokenControl *arg_get_value2) {
    NSString* str;
    if (arg_get_value1->vname==NULL) {
        if (arg_get_value1->data.s_value==NULL) {
            return;
        }
        str = [NSString stringWithCString: arg_get_value1->data.s_value encoding:NSUTF8StringEncoding];
    }else{
        str = [NSString stringWithCString: arg_get_value1->vname encoding:NSUTF8StringEncoding];
    }
    arg_set_value->vname=aname;
    NSString* dist_str = [NSString stringWithCString: aname encoding:NSUTF8StringEncoding];
    NSMutableDictionary *new_dict=[[NSMutableDictionary alloc] init];
    [gl_vdict setObject:new_dict forKey:dist_str];
    NSObject *obj=[gl_vdict objectForKey:str];
    if ([obj isKindOfClass:[NSMutableDictionary class]]==NO) {
        return;
    }
    NSMutableDictionary *src_dict=(NSMutableDictionary*)obj;
    ArrayCopyProc(new_dict,src_dict);
    NSString* str2;
    if (arg_get_value2->vname==NULL) {
        if (arg_get_value2->data.s_value==NULL) {
            return;
        }
        str2 = [NSString stringWithCString: arg_get_value2->data.s_value encoding:NSUTF8StringEncoding];
    }else{
        str2 = [NSString stringWithCString: arg_get_value2->vname encoding:NSUTF8StringEncoding];
    }
    NSObject *obj2=[gl_vdict objectForKey:str2];
    if ([obj2 isKindOfClass:[NSMutableDictionary class]]==NO) {
        return;
    }
    NSMutableDictionary *src_dict2=(NSMutableDictionary*)obj2;
    for(NSString *kname in [new_dict allKeys]) {
        NSMutableDictionary *dist_dict=[new_dict objectForKey:kname];
        NSMutableDictionary *wk_dict=[src_dict2 objectForKey:kname];
        for(NSString *kname2 in [dist_dict allKeys]) {
            NSObject *dist_obj=[dist_dict objectForKey:kname2];
            NSObject *src_obj=[wk_dict objectForKey:kname2];
            if (dist_obj==nil||src_obj==nil) {
                continue;
            }
            if ([dist_obj isKindOfClass:[NSNumber class]]==NO) {
                continue;
            }
            if ([src_obj isKindOfClass:[NSNumber class]]==NO) {
                continue;
            }
            double dict_vn=[(NSNumber*)dist_obj doubleValue];
            double src_vn=[(NSNumber*)src_obj doubleValue];
            [dist_dict setObject:[NSNumber numberWithDouble:dict_vn-src_vn] forKey:kname2];
        }
    }
}
double GetMatrixValue(NSMutableDictionary *dict, int a, int b) {
    double ret_val=0.0;
    NSObject *sobj=[dict objectForKey:[NSString stringWithFormat:@"%d", a]];
    if ([sobj isKindOfClass:[NSMutableDictionary class]]==NO) {
        return ret_val;
    }
    NSMutableDictionary *sdict=(NSMutableDictionary*)sobj;
    NSObject *sobj2=[sdict objectForKey:[NSString stringWithFormat:@"%d", b]];
    if ([sobj2 isKindOfClass:[NSNumber class]]==NO) {
        return ret_val;
    }
    ret_val=[(NSNumber*)sobj2 doubleValue];
    return ret_val;
}
void SetMatrixValue(NSMutableDictionary *dict, int a, int b, double v) {
    NSObject *sobj=[dict objectForKey:[NSString stringWithFormat:@"%d", a]];
    if ([sobj isKindOfClass:[NSMutableDictionary class]]==NO) {
        return;
    }
    NSMutableDictionary *sdict=(NSMutableDictionary*)sobj;
    [sdict setObject:[NSNumber numberWithDouble:v] forKey:[NSString stringWithFormat:@"%d", b]];
}
void ArrayMlt(TokenControl *arg_set_value, char *aname,TokenControl *arg_get_value1,TokenControl *arg_get_value2) {
    NSString* str;
    if (arg_get_value1->vname==NULL) {
        if (arg_get_value1->data.s_value==NULL) {
            return;
        }
        str = [NSString stringWithCString: arg_get_value1->data.s_value encoding:NSUTF8StringEncoding];
    }else{
        str = [NSString stringWithCString: arg_get_value1->vname encoding:NSUTF8StringEncoding];
    }
    arg_set_value->vname=aname;
    NSString* dist_str = [NSString stringWithCString: aname encoding:NSUTF8StringEncoding];
    NSMutableDictionary *new_dict=[[NSMutableDictionary alloc] init];
    [gl_vdict setObject:new_dict forKey:dist_str];
    NSObject *obj=[gl_vdict objectForKey:str];
    NSMutableDictionary *src_dict;
    double dv=1.0;
    if ([obj isKindOfClass:[NSMutableDictionary class]]==NO) {
        src_dict=nil;
        if ([obj isKindOfClass:[NSNumber class]]) {
            dv=[(NSNumber*)obj doubleValue];
        }else{
            return;
        }
    }else{
        src_dict=(NSMutableDictionary*)obj;
    }
    ArrayCopyProc(new_dict,src_dict);
    NSString* str2;
    if (arg_get_value2->vname==NULL) {
        if (arg_get_value2->data.s_value==NULL) {
            return;
        }
        str2 = [NSString stringWithCString: arg_get_value2->data.s_value encoding:NSUTF8StringEncoding];
    }else{
        str2 = [NSString stringWithCString: arg_get_value2->vname encoding:NSUTF8StringEncoding];
    }
    NSObject *obj2=[gl_vdict objectForKey:str2];
    NSMutableDictionary *src_dict2;
    double dv2=1.0;
    if ([obj2 isKindOfClass:[NSMutableDictionary class]]==NO) {
        src_dict2=nil;
        if ([obj2 isKindOfClass:[NSNumber class]]) {
            dv2=[(NSNumber*)obj2 doubleValue];
        }else{
            return;
        }
    }else{
        src_dict2=(NSMutableDictionary*)obj2;
    }
    if ((src_dict2!=nil)&&(src_dict!=nil)) {
        int get_ary=arrayRowSize(arg_get_value1);
        for(int j=0; j<get_ary ;j++) {
            for(int i2=0; i2<get_ary ;i2++) {
                double ttl=0.0;
                for(int i=0; i<get_ary ;i++) {
                    double avalue=GetMatrixValue(src_dict2, i,j);
                    double bvalue=GetMatrixValue(src_dict, i2,j);
                    ttl+=avalue*bvalue;
                }
                SetMatrixValue(new_dict, i2,j,ttl);
            }
        }
    }else{
        NSMutableDictionary *wkdict=nil;
        double wv=1.0;
        if (src_dict2!=nil) {
            wkdict=src_dict2;
            wv=dv2;
        }
        if (src_dict!=nil) {
            wkdict=src_dict;
            wv=dv;
        }
        if (wkdict==nil) {
            return;
        }
        int get_ary=arrayRowSize(arg_get_value1);
        for(int j=0; j<get_ary ;j++) {
            for(int i=0; i<get_ary ;i++) {
                double ttl=GetMatrixValue(wkdict, i,j);
                ttl=ttl * wv;
                SetMatrixValue(new_dict, i,j,ttl);
            }
        }
    }
}
int AddVoidArgumentList(ArgumentList *arg_list, void *arg_item) {
    int ret_cnt=0;
    ArgumentList *ret_val=(ArgumentList*)m_memalloc(sizeof(ArgumentList));
    if (ret_val==NULL) {
        fprintf(stderr, "AddVoidArgumentList malloc error\n");
        return -1;
    }
    ret_val->item=arg_item;
    ret_val->next=NULL;
    ArgumentList *warglist=arg_list;
    ArgumentList *lastitem=NULL;
    while(warglist!=NULL) {
        lastitem=warglist;
        warglist=warglist->next;
        ret_cnt++;
    }
    if (lastitem!=NULL) {
        lastitem->next=ret_val;
    }
    return ret_cnt;
}
void AddListArgumentList(ArgumentList *arg_list, ArgumentList *add_list) {
    ArgumentList *witem=add_list;
    while(witem!=NULL) {
        ExprControl *aritem=(ExprControl*)witem->item;
        AddVoidArgumentList(arg_list,aritem);
        witem=witem->next;
    }
}
ArgumentList *AddFloatArgumentList(ArgumentList *arg_list, FloatItem arg_item) {
    ArgumentList *ret_val=(ArgumentList*)m_memalloc(sizeof(ArgumentList));
    if (ret_val==NULL) {
        fprintf(stderr, "AddFloatArgumentList malloc error\n");
        return NULL;
    }
    arg_list->next=ret_val;
    FloatItem *float_item=(FloatItem*)m_memalloc(sizeof(FloatItem));
    if (float_item==NULL) {
        fprintf(stderr, "AddFloatArgumentList item malloc error\n");
        return NULL;
    }
    *float_item=arg_item;
    arg_list->item=float_item;
    return ret_val;
}
CommandItem CreateCommandItem() {
    CommandItem ret_val;
    ret_val.type='c';
    return ret_val;
}
CListControl *CreateCItem() {
    CListControl *ret=(CListControl*)m_memalloc(sizeof(CListControl));
    ret->start_pt=CreateCommandList();
    ret->end_pt=ret->start_pt;
    return ret;
}

@implementation Command
-(id)init {
    self=[super init];
    if (self) {
        gl_cmd_list=NULL;
        gl_cmd_list_end=gl_cmd_list;
        break_flag=NO;
        gl_vdict=[[NSMutableDictionary alloc] init];
        NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        out_path = [documentsDirectory stringByAppendingPathComponent:@"out.txt"];
        NSString *func_path = [documentsDirectory stringByAppendingPathComponent:@"function.json"];
        gl_fnc_cmdlst=[[NSMutableDictionary alloc] init];
        if ([[NSFileManager defaultManager] fileExistsAtPath:func_path]==NO) {
            // error message
        }else{
            NSError *jsonParsingError = nil;
            NSData *json_data=[NSData dataWithContentsOfFile:func_path];
            NSDictionary *wdict=[NSJSONSerialization JSONObjectWithData:json_data options:0 error:&jsonParsingError];
            [gl_fnc_cmdlst addEntriesFromDictionary:wdict];
        }
        NSString *func_src_path = [documentsDirectory stringByAppendingPathComponent:@"function_src.json"];
        gl_fnc_srclst=[[NSMutableDictionary alloc] init];
        if ([[NSFileManager defaultManager] fileExistsAtPath:func_src_path]==NO) {
            // error message
        }else{
            NSError *jsonParsingError = nil;
            NSData *json_data=[NSData dataWithContentsOfFile:func_src_path];
            NSDictionary *wdict=[NSJSONSerialization JSONObjectWithData:json_data options:0 error:&jsonParsingError];
            [gl_fnc_srclst addEntriesFromDictionary:wdict];
        }
        fname_array=[[NSMutableArray alloc] init];
        NSString *cmdpath = [documentsDirectory stringByAppendingPathComponent:@"cmdhlist.json"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:cmdpath]==NO) {
            [@"[]" writeToFile:cmdpath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        NSError *jsonParsingError = nil;
        NSData *json_data=[NSData dataWithContentsOfFile:cmdpath];
        NSArray *warr=[NSJSONSerialization JSONObjectWithData:json_data options:0 error:&jsonParsingError];
        cmd_hlist=[[NSMutableArray alloc] initWithArray:warr];
        NSString *calpath = [documentsDirectory stringByAppendingPathComponent:@"calhlist.json"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:calpath]==NO) {
            [@"[]" writeToFile:calpath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        json_data=[NSData dataWithContentsOfFile:calpath];
        warr=[NSJSONSerialization JSONObjectWithData:json_data options:0 error:&jsonParsingError];
        cal_hlist=[[NSMutableArray alloc] initWithArray:warr];
    }
    return self;
}
-(NSArray*)expr:(NSString*)arg_cmd {
    if (gl_memctl!=NULL) {
        deleteMemory(gl_memctl);
        deleteMomoryControll(gl_memctl);
        gl_memctl=NULL;
    }
    //eror_flag=0;
    //[self error_reset];
    eror_flag=0;
    break_flag=NO;
    linenumber=1;
    gl_graph_list=nil;
    gl_fnc_list=CreateArgumentList();
	NSString *work_str = [NSString stringWithFormat:@"%@%@",arg_cmd,[self getAllFunctionStr]];
	//NSString *work_str = [NSString stringWithFormat:@"%@%@",[self getAllFunctionStr],arg_cmd];
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"yy_in.txt"];
    NSString *wout_path = [documentsDirectory stringByAppendingPathComponent:@"out.txt"];
    NSString *werr_path = [documentsDirectory stringByAppendingPathComponent:@"err.txt"];
    [work_str writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    const char *cpath = [path UTF8String];
    const char *opath = [wout_path UTF8String];
    const char *erpath = [werr_path UTF8String];
    fflush(stdout);
    yyin=fopen(cpath,"r");
    app_out=fopen(opath,"w");
    stderr=fopen(erpath,"w");
    yyparse ();
    if (eror_flag==0) {
        RunCommandList(gl_vdict, NULL, gl_cmd_list);
    }else{
        fprintf(stderr, "error lineno %d\n", linenumber);
        yylex_destroy();
        //int c;
        //while ( (c=fgetc(yyin)) != EOF);
    }
    fclose(yyin);
    fclose(app_out);
    fclose(stderr);
    NSData *str_data=[NSData dataWithContentsOfFile:out_path];
    NSString *str_out=[[NSString alloc] initWithData:str_data encoding:NSUTF8StringEncoding];
    NSData *err_data=[NSData dataWithContentsOfFile:werr_path];
    NSString *str_err=[[NSString alloc] initWithData:err_data encoding:NSUTF8StringEncoding];
    return [NSArray arrayWithObjects:arg_cmd, str_out, str_err,nil];
}
-(NSArray*)check:(NSString*)arg_cmd {
    if (gl_memctl!=NULL) {
        deleteMemory(gl_memctl);
        deleteMomoryControll(gl_memctl);
        gl_memctl=NULL;
    }
    eror_flag=0;
    break_flag=NO;
    linenumber=1;
    gl_graph_list=nil;
    gl_fnc_list=CreateArgumentList();
	NSString *work_str = [NSString stringWithFormat:@"%@",arg_cmd];
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"yy_in.txt"];
    NSString *wout_path = [documentsDirectory stringByAppendingPathComponent:@"out.txt"];
    NSString *werr_path = [documentsDirectory stringByAppendingPathComponent:@"err.txt"];
    [work_str writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    const char *cpath = [path UTF8String];
    const char *opath = [wout_path UTF8String];
    const char *erpath = [werr_path UTF8String];
    fflush(stdout);
    yyin=fopen(cpath,"r");
    app_out=fopen(opath,"w");
    stderr=fopen(erpath,"w");
    yyparse ();
    if (eror_flag!=0) {
        fprintf(stderr, "error lineno %d\n", linenumber);
        yylex_destroy();
    }
    fclose(yyin);
    fclose(app_out);
    fclose(stderr);
    NSData *str_data=[NSData dataWithContentsOfFile:out_path];
    NSString *str_out=[[NSString alloc] initWithData:str_data encoding:NSUTF8StringEncoding];
    NSData *err_data=[NSData dataWithContentsOfFile:werr_path];
    NSString *str_err=[[NSString alloc] initWithData:err_data encoding:NSUTF8StringEncoding];
    return [NSArray arrayWithObjects:arg_cmd, str_out, str_err,nil];
}
-(void)initialFile:(NSString*)arg_path {
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"out.txt"];
    const char *cpath = [arg_path UTF8String];
    const char *opath = [path UTF8String];
    // gname array set
    NSData *str_data=[NSData dataWithContentsOfFile:arg_path];
    NSString *ini_str=[[NSString alloc] initWithData:str_data encoding:NSUTF8StringEncoding];
    long lpt=0;
    while(true) {
        if (lpt>=[ini_str length]) {
            break;
        }
        NSRange trng=[ini_str rangeOfString:@"define" options:NSCaseInsensitiveSearch range:NSMakeRange(lpt, [ini_str length]-lpt)];
        if (trng.location==NSNotFound) {
            break;
        }else{
            lpt=trng.location+trng.length;
            //lpt=trng.location;
            NSRange orng=[ini_str rangeOfString:@"(" options:NSCaseInsensitiveSearch range:NSMakeRange(trng.location+trng.length, [ini_str length]-lpt)];
            if (orng.location!=-1) {
                NSString *hit_wd=[ini_str substringWithRange:NSMakeRange(trng.location+trng.length, orng.location-trng.location-trng.length)];
                NSCharacterSet *cset=[NSCharacterSet whitespaceAndNewlineCharacterSet];
                NSString *new_wd=[hit_wd stringByTrimmingCharactersInSet:cset];
                if ([fname_array indexOfObject:new_wd]==NSNotFound) {
                    [fname_array addObject:new_wd];
                }
                lpt=orng.location+orng.length;
            }
        }
    }

    fflush(stdout);
    yyin=fopen(cpath,"r");
    app_out=fopen(opath,"w");
    yyparse ();
    fclose(yyin);
    fclose(app_out);
}
-(BOOL)addFunction:(NSString*)arg_txt {
    NSString *funstr=[self functionParse:arg_txt];
    if ((funstr==nil)||(fnamestr==nil)) {
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"error"
                                                      message:@"function error"
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
        [alert show];
        return NO;
    }else{
        [gl_fnc_cmdlst setObject:funstr forKey:fnamestr];
        [self saveFunction];
        return YES;
    }
}
// function dictionry の保存
// function dictionry の読み取り
//
-(NSString*)functionParse:(NSString*)arg_str {
    BOOL fmt_error=NO;
    char buff[256];
    char *fname=NULL;
    char *define_start=NULL;
    char *define_end=NULL;
    const char *wcpr=[arg_str UTF8String];
    const char *skpt=wcpr;
    char *fstart=NULL;
    int lev=0;
    while(*skpt!=(char)NULL) {
        if ((*skpt==' ')||(*skpt=='\n')||(*skpt=='\t')||(*skpt=='\r')) {
            skpt++;
            continue;
        }
        if (*skpt=='\\') {
            skpt++;
            continue;
        }
        if (*skpt=='"') {
            while(*skpt!=(char)NULL) {
                if (*++skpt=='"') {
                    skpt++;
                    break;
                }else if (*skpt=='\\') {
                    skpt++;
                }
            }
            continue;
        }
        if (*skpt=='\'') {
            while(*skpt!=(char)NULL) {
                if (*++skpt=='\'') {
                    skpt++;
                    break;
                }else if (*skpt=='\\') {
                    skpt++;
                }
            }
            continue;
        }
        if (fname==NULL) {
            if (fstart==NULL) {
                if (define_start!=NULL) {
                    fstart=(char*)skpt;
                }
            }
            if (*skpt=='(') {
                if (skpt!=fstart) {
                    long nlen=skpt-fstart;
                    if (nlen>255) {
                        fmt_error=YES;
                        NSLog(@"buff size over");
                        break;
                    }else{
                        fname=buff;
                        strncpy(buff, fstart, nlen);
                        buff[nlen]=0;
                    }
                }
            }
        }else{
            if (*skpt=='{') {
                lev++;
            }
            if (*skpt=='}') {
                lev--;
                if (lev==0) {
                    define_end=(char*)skpt;
                    define_end++;
                    break;
                }
            }
        }
        if (strncmp(skpt, "function", 8)==0) {
            define_start=(char*)skpt;
            if (lev!=0) {
                fmt_error=YES;
                break;
            }
            skpt+=8;
            fname=NULL;
            lev=0;
        }
        skpt++;
    }
    if (fmt_error) {
        return nil;
    }else{
        long nlen=(long)((long)define_end-(long)define_start);
        char *funcstr_ch=malloc(nlen+1);
        strncpy(funcstr_ch, define_start, nlen);
        funcstr_ch[nlen+1]=0;
        NSString* funcstr = [NSString stringWithCString: funcstr_ch encoding:NSUTF8StringEncoding];
        fnamestr = [NSString stringWithCString: fname encoding:NSUTF8StringEncoding];
        free(funcstr_ch);
        return funcstr;
    }
}
-(NSArray*)getFnameArray {
    //return [NSArray arrayWithObjects:@"func1",@"func2dc",@"func3arc",nil];
    return [gl_fnc_srclst allKeys];
}
-(void)saveFunction {
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *func_path = [documentsDirectory stringByAppendingPathComponent:@"function.json"];
    //if ([[NSFileManager defaultManager] fileExistsAtPath:func_path]==NO) {
    //    [@"{}" writeToFile:func_path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    //}
    NSData *data = [NSJSONSerialization dataWithJSONObject:gl_fnc_cmdlst options:NSJSONWritingPrettyPrinted error:nil];
    NSString *work_str=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [work_str writeToFile:func_path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}
-(void)addFunctionSource {
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *func_path = [documentsDirectory stringByAppendingPathComponent:@"function_src.json"];
    //if ([[NSFileManager defaultManager] fileExistsAtPath:func_path]==NO) {
    //    [@"{}" writeToFile:func_path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    //}
    NSData *data = [NSJSONSerialization dataWithJSONObject:gl_fnc_srclst options:NSJSONWritingPrettyPrinted error:nil];
    NSString *work_str=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [work_str writeToFile:func_path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}
-(void)initialFunctionFile:(NSString*)arg_path {
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *func_path = [documentsDirectory stringByAppendingPathComponent:@"function.json"];
    NSError *jsonParsingError = nil;
    NSData *json_data=[NSData dataWithContentsOfFile:func_path];
    gl_fnc_cmdlst=[NSJSONSerialization JSONObjectWithData:json_data options:0 error:&jsonParsingError];
}
-(NSString*)getFunction:(NSString*)arg_txt {
    return [gl_fnc_cmdlst objectForKey:arg_txt];
}
-(NSString*)getFunctionSrc:(NSString*)arg_txt {
    return [gl_fnc_srclst objectForKey:arg_txt];
}
-(void)removeFunction:(NSString*)arg_fname {
    [gl_fnc_cmdlst removeObjectForKey:arg_fname];
    [gl_fnc_srclst removeObjectForKey:arg_fname];
    [self saveFunction];
    [self addFunctionSource];
}
-(void)setCmdHistory:(NSString*)arg_cmd {
    NSUInteger r=[cmd_hlist indexOfObject:arg_cmd];
    if (r!=NSNotFound) {
        [cmd_hlist removeObjectAtIndex:r];
    }
    [cmd_hlist insertObject:arg_cmd atIndex:0];
    if ([cmd_hlist count]>100) {
        [cmd_hlist removeLastObject];
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:cmd_hlist options:NSJSONWritingPrettyPrinted error:nil];
    NSString *work_str=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"cmdhlist.json"];
    [work_str writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}
-(NSString*)getCmdHisrory:(int)arg_idx {
    if ([cmd_hlist count]<(arg_idx+1)) {
        return nil;
    }else{
        return [cmd_hlist objectAtIndex:arg_idx];
    }
}
-(void)setCalHistory:(NSString*)arg_cmd {
    NSUInteger r=[cal_hlist indexOfObject:arg_cmd];
    if (r!=NSNotFound) {
        [cal_hlist removeObjectAtIndex:r];
    }
    [cal_hlist insertObject:arg_cmd atIndex:0];
    if ([cal_hlist count]>100) {
        [cal_hlist removeLastObject];
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:cal_hlist options:NSJSONWritingPrettyPrinted error:nil];
    NSString *work_str=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"calhlist.json"];
    [work_str writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}
-(NSString*)getCalHisrory:(int)arg_idx {
    if ([cal_hlist count]<(arg_idx+1)) {
        return nil;
    }else{
        return [cal_hlist objectAtIndex:arg_idx];
    }
}
-(NSString*)getAllFunctionStr {
    NSMutableString *wstr=[[NSMutableString alloc] init];
    NSArray *klist=[gl_fnc_srclst allKeys];
    for(NSString *kname in klist) {
        NSObject *ww=[gl_fnc_srclst objectForKey:kname];
        if ([ww isKindOfClass:[NSString class]]) {
            [wstr appendString:(NSString*)ww];
        }
    }
    return (NSString*)wstr;
}
-(void)addFunctionSource:(NSString*)arg_value {
    NSString *funstr=[self functionParse:arg_value];
    if ((funstr==nil)||(fnamestr==nil)) {
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"error"
                                                      message:@"function error"
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
        [alert show];
        return;
    }else{
        [gl_fnc_srclst setObject:funstr forKey:fnamestr];
        [self addFunctionSource];
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"message"
                                                      message:@"function save"
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
        [alert show];
        return;
    }
}
@end
