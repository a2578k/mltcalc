%{
    #include <stdio.h>
    #include "calc.h"
    int yylex(void);
    void yyerror(char *);
    extern ArgumentList *arg_list;
    extern CommandList *gl_cmd_list;
    extern CommandList *gl_cmd_list_end;
    int fnc_flag=0;
    int eror_flag=0;
    ExprControl *cmd_list_item=NULL;
%}
%start cmd_list

%union
{
    TokenControl *fval;
    ExprControl *fitem;
    TokenControl *string;
    ExprControl *clist;
    ArgumentList *alist;
}

%token FUNCTION PRINT LE GE EQ IF ELSE ENDPC WHILE FOR RETURN IDTYPE AND OR NOT
%token <fval> FLOAT
%token <fval> FNAME
%token <fval> IDTYPE
%token <fval> STRING
%type <fitem> expr
%type <fitem> expr_a
%type <clist> cmd_list
%type <fitem> command
%type <clist> arg_list
%type <alist> array_list

%nonassoc IFX
%nonassoc ELSE
%nonassoc IDTYPE

%left GE LE EQ NE '>' '<'
%left '+' '-'
%left '*' '/'
%right '^'
%left   UPLUS   UMINUS
sy
%%

cmd_list:command {
    //printf("cmd_list:command\n");
    $$=AddListCommandList(NULL,$1);
    //DebugCommandList($$->clist_ctl.start_pt);
    gl_cmd_list=$$->clist_ctl.start_pt;
}
| cmd_list command {
    //printf("addcmd\n");
    $$=AddListCommandList($1,$2);
    //printf("add cmd_list %c", $2->type);
    gl_cmd_list=$1->clist_ctl.start_pt;
}
;

command: expr ';' {
    $$=$1;
    //DebugCommandList($1->clist_ctl.start_pt);
}
| PRINT arg_list  ';'  {
    $$=AddVoidCmdList('p', $2);
    //DebugArgList($2);
    //DebugCommandList($$->clist_ctl.start_pt);
}
| IF '(' expr ')' '{' cmd_list '}' %prec IFX {
    $$=AddIfCmd3List($3,$6,(ExprControl*)NULL);
}
| IF '(' expr ')' '{' cmd_list '}' ELSE '{' cmd_list '}'  {
    $$=AddIfCmd3List($3,$6,$10);
}
| WHILE '(' expr ')' '{' cmd_list '}'  {
    $$=AddWhileCmdList($3, $6);
}
| FOR '(' expr ';' expr ';' expr ')' '{' cmd_list '}'  {
    $$=AddForCmdList($3, $5, $7, $10);
}
| FUNCTION {
    if (fnc_flag==1) {
      yyerror("function error");
    }
    fnc_flag=1;
} FNAME '(' arg_list ')' '{' cmd_list '}' {
    fnc_flag=0;
    $$=AddRegistFunctionCmd3List($3,$5,$8);
}
| RETURN ';' {
    $$=CreateExprControl(CreateFloatItem(0));
    $$=AddVoidCmd2List('r', $$, NULL);
}
| RETURN expr ';' {
    //DebugValue($2);
    $$=CreateExprControl(CreateFloatItem(0));
    $$=AddVoidCmd2List('r', $$, $2);
}
;


expr:
FLOAT {
    $$=CreateExprControl($1);
}
| '-' FLOAT  %prec UMINUS {
    *($2->data.f_value)*=-1;
    $$=CreateExprControl($2);
}
| '+' FLOAT  %prec UPLUS {
    $$=CreateExprControl($2);
}

| STRING {
    $$=CreateExprControl($1);
    $$->type='s';
}
|FNAME {
    $$=CreateExprControl($1);
    $$->type='v';
}
|FNAME '[' arg_list ']' {
    //DebugValue($3);
    $$ = AccessArrayControl($1,$3->arglist);
}
|IDTYPE FNAME {
    if (*($1->data.s_value)=='+') {
        $$=AddVoidCmdList('k', CreateExprControl($2));
    }else{
        $$=AddVoidCmdList('j', CreateExprControl($2));
    }
    //DebugValue($$);
}
|FNAME IDTYPE {
    if (*($2->data.s_value)=='+') {
        $$=AddVoidCmdList('K', CreateExprControl($1));
    }else{
        $$=AddVoidCmdList('J', CreateExprControl($1));
    }
    $$->eqflg='e';
    //DebugValue($$);
}
|FNAME '(' arg_list ')' {
    printf("CALL FNAME=%s(%p)\n", $1->data.s_value,$1->data.s_value);
    $$=CreateExprControl(CreateFloatItem(0));
    $$=AddCallFunctionCmd3List('c', $$, $1, $3);
    //DebugCommandList($$->clist_ctl.start_pt);
}
| expr '=' expr {
    $$=AddVoidCmd2List('=', $1, $3);
    //DebugArgList($$);
    //DebugValue($3);
    //DebugCommandList($$->clist_ctl.start_pt);
}
| array_list {
    $$=CreateExprControl(CreateArrayItem());
    $$->type='H';
    $$->arglist=$1;
    $$->a_array[0]->data.arg_list=$1;
    $$->a_array[0]->vname=NULL;
}
| '(' expr ')'            {
    if ($2->type=='s') { yyerror("argument error");}
    $$=CreateExprControl(CreateFloatItem(0));
    $$=AddVoidCmd2List('=', $$, $2);
}
| expr '+' expr           {
    if ($1->type=='s'||$3->type=='s') { yyerror("expr error");}
    $$=CreateExprControl(CreateFloatItem(0));
    $$=AddVoidCmd3List('+',$$, $1, $3);
}
| expr '-' expr           {
    if ($1->type=='s'||$3->type=='s') { yyerror("expr error");}
    $$=CreateExprControl(CreateFloatItem(0));
    $$=AddVoidCmd3List('-',$$, $1, $3);
}
| expr '*' expr           {
    if ($1->type=='s'||$3->type=='s') { yyerror("expr error");}
    $$=CreateExprControl(CreateFloatItem(0));
    $$=AddVoidCmd3List('*',$$, $1, $3);
}
| expr '/' expr           {
    if ($1->type=='s'||$3->type=='s') { yyerror("expr error");}
    $$=CreateExprControl(CreateFloatItem(0));
    $$=AddVoidCmd3List('/',$$, $1, $3);
}
| expr '%' expr           {
    if ($1->type=='s'||$3->type=='s') { yyerror("expr error");}
    $$=CreateExprControl(CreateFloatItem(0));
    $$=AddVoidCmd3List('%',$$, $1, $3);
}
| expr '<' expr           {
    if ($1->type=='s'||$3->type=='s') { yyerror("expr error");}
    $$=CreateExprControl(CreateFloatItem(0));
    $$=AddVoidCmd3List('<',$$, $1, $3);
}
| expr '>' expr           {
    if ($1->type=='s'||$3->type=='s') { yyerror("expr error");}
    $$=CreateExprControl(CreateFloatItem(0));
    $$=AddVoidCmd3List('>',$$, $1, $3);
}
| expr GE expr           {
    if ($1->type=='s'||$3->type=='s') { yyerror("expr error");}
    $$=CreateExprControl(CreateFloatItem(0));
    $$=AddVoidCmd3List('G',$$, $1, $3);
}
| expr LE expr           {
    if ($1->type=='s'||$3->type=='s') { yyerror("expr error");}
    $$=CreateExprControl(CreateFloatItem(0));
    $$=AddVoidCmd3List('L',$$, $1, $3);
}
| expr EQ expr           {
    if ($1->type=='s'||$3->type=='s') { yyerror("expr error");}
    $$=CreateExprControl(CreateFloatItem(0));
    $$=AddVoidCmd3List('E',$$, $1, $3);
}
| expr '^' expr           {
    if ($1->type=='s'||$3->type=='s') { yyerror("expr error");}
    $$=CreateExprControl(CreateFloatItem(0));
    $$=AddVoidCmd3List('^',$$, $1, $3);
}
| expr AND expr           {
    if ($1->type=='s'||$3->type=='s') { yyerror("expr error");}
    $$=CreateExprControl(CreateFloatItem(0));
    $$=AddVoidCmd3List('A',$$, $1, $3);
}
| expr OR expr           {
    if ($1->type=='s'||$3->type=='s') { yyerror("expr error");}
    $$=CreateExprControl(CreateFloatItem(0));
    $$=AddVoidCmd3List('O',$$, $1, $3);
}
| NOT expr {
    if ($2->type=='s') { yyerror("expr error");}
    $$=CreateExprControl(CreateFloatItem(0));
    $$=AddVoidCmd2List('N',$$, $2);
}
;

arg_list: {
    $$=NULL;
}
| expr {
    $$=CreateExprNextControl($1);
    $$->type='a';
    $$->arglist=CreateArgumentList();
    $$->arglist->item=$1;
    DebugValue($$);
    //DebugCommandList($$->clist_ctl.start_pt);
}
| arg_list ',' expr {
    $$=AddListCommandList($1,$3);
    $$->arglist=$$->arglist;
    AddVoidArgumentList($$->arglist,$3);
    //DebugArgList($$);
}
;
expr_a:
FLOAT {
    $$=CreateExprControl($1);
}
| '-' FLOAT  %prec UMINUS {
    *($2->data.f_value)*=-1;
    $$=CreateExprControl($2);
}
| '+' FLOAT  %prec UPLUS {
    $$=CreateExprControl($2);
}

| STRING {
    $$=CreateExprControl($1);
    $$->type='s';
}
|FNAME {
    $$=CreateExprControl($1);
    $$->type='v';
}
|IDTYPE FNAME {
    if (*($1->data.s_value)=='+') {
        $$=AddVoidCmdList('k', CreateExprControl($2));
    }else{
        $$=AddVoidCmdList('j', CreateExprControl($2));
    }
    //DebugValue($$);
}
|FNAME IDTYPE {
    if (*($2->data.s_value)=='+') {
        $$=AddVoidCmdList('K', CreateExprControl($1));
    }else{
        $$=AddVoidCmdList('J', CreateExprControl($1));
    }
    $$->eqflg='e';
    //DebugValue($$);
}
| '(' expr_a ')'            {
    if ($2->type=='s') { yyerror("argument error");}
    $$=CreateExprControl(CreateFloatItem(0));
    $$=AddVoidCmd2List('=', $$, $2);
}
| expr_a '+' expr_a           {
    if ($1->type=='s'||$3->type=='s') { yyerror("expr error");}
    $$=CreateExprControl(CreateFloatItem(0));
    $$=AddVoidCmd3List('+',$$, $1, $3);
}
| expr_a '-' expr_a           {
    if ($1->type=='s'||$3->type=='s') { yyerror("expr error");}
    $$=CreateExprControl(CreateFloatItem(0));
    $$=AddVoidCmd3List('-',$$, $1, $3);
}
| expr_a '*' expr_a           {
    if ($1->type=='s'||$3->type=='s') { yyerror("expr error");}
    $$=CreateExprControl(CreateFloatItem(0));
    $$=AddVoidCmd3List('*',$$, $1, $3);
}
| expr_a '/' expr_a           {
    if ($1->type=='s'||$3->type=='s') { yyerror("expr error");}
    $$=CreateExprControl(CreateFloatItem(0));
    $$=AddVoidCmd3List('/',$$, $1, $3);
}
| expr_a '%' expr_a           {
    if ($1->type=='s'||$3->type=='s') { yyerror("expr error");}
    $$=CreateExprControl(CreateFloatItem(0));
    $$=AddVoidCmd3List('%',$$, $1, $3);
}
;
array_list: {
    $$=NULL;
}
| '[' array_list ']' {
    ExprControl *e1=CreateExprControl(CreateChartItem('['));
    $$=CreateArgumentList();
    $$->item=e1;
    AddListArgumentList($$,$2);
    ExprControl *e2=CreateExprControl(CreateChartItem(']'));
    AddVoidArgumentList($$,e2);
}
|expr_a {
    cmd_list_item=AddListCommandList(cmd_list_item,$1);
    $$=CreateArgumentList();
    $$->item=$1;
}
|array_list ',' expr_a {
    cmd_list_item=AddListCommandList(cmd_list_item,$3);
    AddVoidArgumentList($1,$3);
    $$=$1;
}
|array_list ',' '[' array_list ']' {
    ExprControl *e1=CreateExprControl(CreateChartItem('['));
    AddVoidArgumentList($1,e1);
    AddVoidArgumentList($1,$4);
    ExprControl *e2=CreateExprControl(CreateChartItem(']'));
    AddVoidArgumentList($1,e2);
    $$=$1;
}
;
%%

void yyerror(char *s) {
    eror_flag=1;
    fprintf(stderr, "%s\n", s);
    yyclearin;
}

