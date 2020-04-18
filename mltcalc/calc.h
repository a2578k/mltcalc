#ifndef mltcalc_calc_h
#define mltcalc_calc_h
// String Item
typedef struct StringItemType {
    char type;
    char *s_value;
}StringItem;
// int item
typedef struct IntItemType {
    char type;
    int  *i_value;
}IntItem;
// float item
typedef struct FloatItemType {
    char type;
    double  *f_value;
}FloatItem;
// Argument List
// String List
typedef struct ArgumentType {
    void *item;
    struct ArgumentType *next;
}ArgumentList;

// CallCommandItem
typedef struct CommandItemType {
    char type;
    StringItem *func_name;
    ArgumentList *a_list;
}CommandItem;
// String List
typedef struct CommandListType {
    void *item;
    struct CommandListType *next;
}CommandList;

typedef struct CListControlType {
    CommandList *start_pt;
    CommandList *end_pt;
}CListControl;

typedef struct TokenControlType {
    char type;
    double bf_value;
    char *vname;
    union {
        double *f_value;
        int   *i_value;
        char  *s_value;
        CommandList *c_list;
        ArgumentList *arg_list;
    }data;
}TokenControl;

typedef struct ExprControlType {
    char type;
    char  eqflg;
    TokenControl *a_array[5];
    ArgumentList *arglist;
    CListControl clist_ctl;
}ExprControl;

typedef struct FunctionControlType {
    char *name;
    ArgumentList *arg_list;
    CommandList  *cmd_list;
}FunctionControl;

// String List
typedef struct MemoryControllType {
    void *item;
    struct MemoryControllType *next;
}MemoryControll;
//
typedef struct GraphDataType {
    char *color_name; // color name
    ExprControl  *exp_item;
}GraphData;
int IsValueString(TokenControl *arg_value);
int IsArray(TokenControl *arg_value);
void PrintArray(TokenControl *arg_value);
char *GetValueString(TokenControl *arg_value);
double GetValue(TokenControl *arg_value);
double GetArrayValue(TokenControl *arg_value);
void SetValue(TokenControl *arg_set_value,TokenControl *arg_get_value);
void SetValue2(TokenControl *arg_set_value,double  arg_value);
void SetArrayValue(TokenControl *arg_set_value,TokenControl *arg_get_value);
void SetArrayValue2(TokenControl *arg_set_value,double  arg_value);
char *NewArrayName();
void ArrayAdd(TokenControl *arg_set_value, char *aname,TokenControl *arg_get_value1,TokenControl *arg_get_value2);
void ArraySub(TokenControl *arg_set_value, char *aname,TokenControl *arg_get_value1,TokenControl *arg_get_value2);
void ArrayMlt(TokenControl *arg_set_value, char *aname,TokenControl *arg_get_value1,TokenControl *arg_get_value2);
void ArrayClear(TokenControl *arg_set_value);
void ArrayCreate();
void ArrayAddItem(TokenControl *arg_set_value,TokenControl *arg_get_value);
int isNull(TokenControl *arg_set_value);
void ArrayCopy(TokenControl *arg_set_value,TokenControl *arg_get_value);
int arrayRowSize(TokenControl *arg_get_value);
int arrayColSize(TokenControl *arg_get_value);
TokenControl *CreateChartItem(char ch);
TokenControl *CreateFloatItem(double arg_f);
TokenControl *CreateArrayItem();
TokenControl *CreateArgumentItem(char *vname,ArgumentList *arg_list);
void CreateArrayValue(TokenControl *arg_token);
void AddListArgumentList(ArgumentList *arg_list, ArgumentList *add_list);
TokenControl *CreateStringItem(char *arg_str);
TokenControl *CreateAddressItem(CommandList *arg_addr);
TokenControl *CreateDblequotItem(char *arg_str);
CommandItem CreateCommandItem();
ArgumentList *CreateArgumentList();
ArgumentList *AddStringArgumentList(ArgumentList *arg_list, StringItem arg_item);
ArgumentList *AddIntArgumentList(ArgumentList *arg_list, IntItem arg_item);
ArgumentList *AddFloatArgumentList(ArgumentList *arg_list, FloatItem arg_item);
int AddVoidArgumentList(ArgumentList *arg_list, void *arg_item);
void FreeArgumentList(ArgumentList *arg_list);
CommandList *CreateCommandList();
CommandList *AddCommandList(CommandList *cmd_list,void *arg_item);
CommandList *AddCommandList2(CommandList *cmd_list,CommandList *cmd_list2);
ExprControl *CreateExprControl(TokenControl *arg_token);
ExprControl *AccessArrayControl(TokenControl *arg_token,ArgumentList *arg_list);
ExprControl *CreateArrayControl(TokenControl *arg_token,ArgumentList *arg_list);
ExprControl *CreateExprNextControl(ExprControl *arg_exp);
ExprControl *AddVoidCmdList(char op,ExprControl *arg_item1);
ExprControl *AddVoidCmd2List(char op, ExprControl *arg_item1,ExprControl *arg_item2);
ExprControl *AddVoidCmd3List(char op, ExprControl *arg_item1,ExprControl *arg_item2,ExprControl *arg_item3);
ExprControl *AddListCommandList(ExprControl *arg_item1,ExprControl *arg_item2);
ExprControl *CopyExprControl(ExprControl *arg_item);
ExprControl *AddIfCmd3List(ExprControl *arg_item1,ExprControl *arg_item2,ExprControl *arg_item3);
ExprControl *AddWhileCmdList(ExprControl *arg_item1,ExprControl *arg_item2);
ExprControl *AddForCmdList(ExprControl *arg_item1,ExprControl *arg_item2,ExprControl *arg_item3,ExprControl *arg_item4);
ExprControl *AddCallFunctionCmd3List(char op, ExprControl *arg_item1,TokenControl *arg_item2,ExprControl *arg_item3);
ExprControl *AddRegistFunctionCmd3List(TokenControl *arg_item1,ExprControl *arg_item2,ExprControl *arg_item3);
FunctionControl *GetFunctionData(char *arg_name);
CommandList *AddStringCmdList(CommandList *cmd_list,char op, StringItem arg_item);
GraphData *GetGraphData(int arg_idx);
void AddGraphData(char *arg_color_name, ExprControl *arg_item);
void DebugCommandList(CommandList *cmd_list);
void DebugValue(ExprControl *arg_expr);
void DebugArgList(ExprControl *arg_expr);
void *GetArgumentList(ArgumentList *cmd_list,int arg_idx);
//CListControl *AddCItem(CListControl *arg_clist, void *item);
CListControl *CreateCItem();
MemoryControll *addMemory(MemoryControll *arg_ctl, void *arg_mem);
void deleteMemory(MemoryControll *arg_ctl);
void deleteMomoryControll(MemoryControll *arg_ctl);
double strToDouble(char *arg_str);
#endif
