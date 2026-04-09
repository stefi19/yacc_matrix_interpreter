%{

#include <stdio.h>
#include <stdlib.h>
#define MAX 10

typedef struct _line{
    int elems[MAX];
    int no_columns_used;
    } line;
typedef struct _matr {
    line *rows[MAX];
    int no_rows_used;
    } matr;
    matr *mem[26];
    //function prototypes
void print_matrix(matr *m);
struct _matr add_matrix(struct _matr m1, struct _matr m2);
struct _matr subtract_matrix(struct _matr m1, struct _matr m2);
struct _matr create_matrix(struct _line l);
struct _matr add_row(struct _matr m, struct _line l);
struct _line insert_nr_in_row(struct _line l, int nr);
struct _line create_row(int nr);
int yylex(void);
void yyerror(const char *s){ fprintf(stderr,"Error: %s\n",s); }
%}

%union {
    struct _matr *mat;
    struct _line *lin;
    int ival;
    }

//define symbols
%token <ival> NUMBER VAR

//define non-terminals
%type <mat> expr
%type <mat> stmt
%type <mat> file
%type <mat> matrix
%type <lin> row

//define the order of priorities
%left '+' '-'

%%
file: file stmt '\n'
    | file '\n'
    |
    ;
stmt: VAR '=' matrix ';' {mem[$1]=$3;}
    | expr ';' {print_matrix($1);}
    ;
expr : expr '+' expr {$$=malloc(sizeof(matr)); *$$ = add_matrix(*$1,*$3);}
    | expr '-' expr {$$=malloc(sizeof(matr)); *$$ = subtract_matrix(*$1,*$3);}
    | VAR {$$=mem[$1];}
    ;
matrix : matrix '\n' row {$$=malloc(sizeof(matr)); *$$ = add_row(*$1,*$3);}
    | row {$$=malloc(sizeof(matr)); *$$ = create_matrix(*$1);}
    ;
row : row NUMBER {$$=malloc(sizeof(line)); *$$ = insert_nr_in_row(*$1,$2);}
    | NUMBER {$$=malloc(sizeof(line)); *$$ = create_row($1);}
    ;

%%

void print_matrix(matr *m) {
    for (int i = 0; i < m->no_rows_used; i++) {
        for (int j = 0; j < m->rows[i]->no_columns_used; j++) {
            printf("%d ", m->rows[i]->elems[j]);
        }
        printf("\n");
    }
}

struct _matr add_matrix(struct _matr m1, struct _matr m2) {
    struct _matr result;
    result.no_rows_used = m1.no_rows_used;
    for (int i = 0; i < m1.no_rows_used; i++) {
        result.rows[i] = (line *)malloc(sizeof(line));
        result.rows[i]->no_columns_used = m1.rows[i]->no_columns_used;
        for (int j = 0; j < m1.rows[i]->no_columns_used; j++) {
            result.rows[i]->elems[j] = m1.rows[i]->elems[j] + m2.rows[i]->elems[j];
        }
    }
    return result;
}

struct _matr subtract_matrix(struct _matr m1, struct _matr m2) {
    struct _matr result;
    result.no_rows_used = m1.no_rows_used;
    for (int i = 0; i < m1.no_rows_used; i++) {
        result.rows[i] = (line *)malloc(sizeof(line));
        result.rows[i]->no_columns_used = m1.rows[i]->no_columns_used;
        for (int j = 0; j < m1.rows[i]->no_columns_used; j++) {
            result.rows[i]->elems[j] = m1.rows[i]->elems[j] - m2.rows[i]->elems[j];
        }
    }
    return result;
}

struct _matr create_matrix(struct _line l) {
    struct _matr m;
    m.no_rows_used = 1;
    m.rows[0] = (line *)malloc(sizeof(line));
    m.rows[0]->no_columns_used = l.no_columns_used;
    for (int i = 0; i < l.no_columns_used; i++) {
        m.rows[0]->elems[i] = l.elems[i];
    }
    return m;
}

struct _matr add_row(struct _matr m, struct _line l) {
    m.rows[m.no_rows_used] = (line *)malloc(sizeof(line));
    m.rows[m.no_rows_used]->no_columns_used = l.no_columns_used;
    for (int i = 0; i < l.no_columns_used; i++) {
        m.rows[m.no_rows_used]->elems[i] = l.elems[i];
    }
    m.no_rows_used++;
    return m;
}

struct _line insert_nr_in_row(struct _line l, int nr) {
    l.elems[l.no_columns_used] = nr;
    l.no_columns_used++;
    return l;
}

struct _line create_row(int nr) {
    struct _line l;
    l.no_columns_used = 1;
    l.elems[0] = nr;
    return l;
}