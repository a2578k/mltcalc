/* calculator #1 */
%{
    #include <stdlib.h>
    #include "calc.h"
    #include "y.tab.h"
    void yyerror(char *);
    char *strMemCopy(char *srg_str);
    int linenumber = 1;
    char errmsg[256];
%}

%%


[-\(\)<>=+*/\%,\^\;\{\}\[\]] {
    //printf(">%c\n", *yytext);
    return *yytext;
}
"\n"         {linenumber += 1;}
[ \t\n\r]       ;       /* skip whitespace */
[0-9]+("."[0-9]+)* {
    //printf(">%s\n", yytext);
    double fval;
    fval=strToDouble(yytext);
    yylval.fval = CreateFloatItem(fval);
    return FLOAT;
}

">="            return GE;
"<="            return LE;
"=="            return EQ;
"!="            return NE;
"if"            return IF;
"else"          return ELSE;
"print"         return PRINT;
"function"      return FUNCTION;
"while"         return WHILE;
"for"           return FOR;
"return"        return RETURN;
&& { return(AND); }
\|\| { return(OR); }
"!" { return(NOT); }

[a-zA-Z][a-zA-Z0-9_]* { yylval.string = CreateStringItem(yytext); return(FNAME); }
\+\+|--         { yylval.string = CreateStringItem(yytext); return(IDTYPE); }
\"[^\"]*\"  {
//unsigned char *look;
//int count = 0;
yylval.string = CreateDblequotItem(yytext); return(STRING);
}

"#"  {
	int c;
    
	    while ( ((c=input()) != '\n') && (c != EOF))
        if (c == '\n') {
            linenumber++;
            break;
        }else if (c == EOF)
        {
            break;
        }else if (c == 0)
        {
            break;
        }
}

.           {
    sprintf(errmsg, "Unknown character 0x%x",*yytext);
    yyerror(errmsg);
}

%%

int yywrap(void) {
    return 1;
}
