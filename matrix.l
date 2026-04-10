%{
#include <stdlib.h>
#include "y.tab.h"

void yyerror(const char *s);
%}

%%

[0-9]+ {yylval.ival = atoi(yytext); return NUMBER;}
[A-Z] {yylval.ival = *yytext-'A'; return VAR;}
[-*+=;\n|] {return *yytext;}
[ \t] {}
. {yyerror("Unknown character");}
