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
void free_matrix(matr *m);
int is_rectangular(matr *m);
int same_dimensions(matr *m1, matr *m2);
struct _matr add_matrix(struct _matr m1, struct _matr m2);
struct _matr subtract_matrix(struct _matr m1, struct _matr m2);
struct _matr multiply_matrix(struct _matr m1, struct _matr m2);
struct _matr create_matrix(struct _line l);
struct _matr add_row(struct _matr m, struct _line l);
struct _line insert_nr_in_row(struct _line l, int nr);
struct _line create_row(int nr);
int determinant(matr *m);
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
%type <mat> matrix
%type <lin> row

//define the order of priorities
%left '+' '-'
%left '*'

%%
file: file stmt '\n'
    | file '\n'
    |
    ;
stmt: VAR '=' matrix ';' {
        if (mem[$1] != NULL) {
            free_matrix(mem[$1]);
            free(mem[$1]);
        }
        mem[$1] = $3;
    }
    | expr ';' {print_matrix($1);}
    | '|' expr '|' ';' {printf("%d\n", determinant($2));}
    ;
expr : expr '+' expr {$$=malloc(sizeof(matr)); *$$ = add_matrix(*$1,*$3);}
    | expr '-' expr {$$=malloc(sizeof(matr)); *$$ = subtract_matrix(*$1,*$3);}
    | expr '*' expr {$$=malloc(sizeof(matr)); *$$ = multiply_matrix(*$1,*$3);}
    | VAR {
        if (mem[$1] == NULL) {
            yyerror("Undefined matrix variable");
            $$ = malloc(sizeof(matr));
            $$->no_rows_used = 0;
        } else {
            $$ = mem[$1];
        }
    }
    ;
matrix : matrix '\n' row {
        $$ = malloc(sizeof(matr));
        *$$ = add_row(*$1,*$3);
        free($3);
    }
    | row {
        $$ = malloc(sizeof(matr));
        *$$ = create_matrix(*$1);
        free($1);
    }
    ;
row : row NUMBER {$$=malloc(sizeof(line)); *$$ = insert_nr_in_row(*$1,$2);}
    | NUMBER {$$=malloc(sizeof(line)); *$$ = create_row($1);}
    ;

%%

void print_matrix(matr *m) {
    if (m == NULL || m->no_rows_used == 0) {
        yyerror("Empty matrix");
        return;
    }

    for (int i = 0; i < m->no_rows_used; i++) {
        for (int j = 0; j < m->rows[i]->no_columns_used; j++) {
            printf("%d ", m->rows[i]->elems[j]);
        }
        printf("\n");
    }
}

void free_matrix(matr *m) {
    if (m == NULL) {
        return;
    }

    for (int i = 0; i < m->no_rows_used; i++) {
        free(m->rows[i]);
        m->rows[i] = NULL;
    }
    m->no_rows_used = 0;
}

int is_rectangular(matr *m) {
    if (m == NULL || m->no_rows_used <= 0 || m->no_rows_used > MAX || m->rows[0] == NULL) {
        return 0;
    }

    int cols = m->rows[0]->no_columns_used;
    if (cols <= 0 || cols > MAX) {
        return 0;
    }

    for (int i = 0; i < m->no_rows_used; i++) {
        if (m->rows[i] == NULL || m->rows[i]->no_columns_used != cols) {
            return 0;
        }
    }

    return 1;
}

int same_dimensions(matr *m1, matr *m2) {
    if (!is_rectangular(m1) || !is_rectangular(m2)) {
        return 0;
    }

    return m1->no_rows_used == m2->no_rows_used &&
           m1->rows[0]->no_columns_used == m2->rows[0]->no_columns_used;
}

struct _matr add_matrix(struct _matr m1, struct _matr m2) {
    struct _matr result;
    result.no_rows_used = 0;

    if (!same_dimensions(&m1, &m2)) {
        yyerror("Matrix dimensions must match for addition");
        return result;
    }

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
    result.no_rows_used = 0;

    if (!same_dimensions(&m1, &m2)) {
        yyerror("Matrix dimensions must match for subtraction");
        return result;
    }

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

struct _matr multiply_matrix(struct _matr m1, struct _matr m2) {
    struct _matr result;
    result.no_rows_used = 0;

    if (!is_rectangular(&m1) || !is_rectangular(&m2)) {
        yyerror("Invalid matrix");
        return result;
    }

    int m1_cols = m1.rows[0]->no_columns_used;
    int m2_cols = m2.rows[0]->no_columns_used;
    if (m1_cols != m2.no_rows_used) {
        yyerror("Matrix dimensions are incompatible for multiplication");
        return result;
    }

    result.no_rows_used = m1.no_rows_used;
    for (int i = 0; i < m1.no_rows_used; i++) {
        result.rows[i] = (line *)malloc(sizeof(line));
        result.rows[i]->no_columns_used = m2_cols;
        for (int j = 0; j < m2_cols; j++) {
            int sum = 0;
            for (int k = 0; k < m1_cols; k++) {
                sum += m1.rows[i]->elems[k] * m2.rows[k]->elems[j];
            }
            result.rows[i]->elems[j] = sum;
        }
    }

    return result;
}

struct _matr create_matrix(struct _line l) {
    struct _matr m;
    m.no_rows_used = 0;

    if (l.no_columns_used <= 0 || l.no_columns_used > MAX) {
        yyerror("Invalid row size");
        return m;
    }

    m.no_rows_used = 1;
    m.rows[0] = (line *)malloc(sizeof(line));
    m.rows[0]->no_columns_used = l.no_columns_used;
    for (int i = 0; i < l.no_columns_used; i++) {
        m.rows[0]->elems[i] = l.elems[i];
    }
    return m;
}

struct _matr add_row(struct _matr m, struct _line l) {
    if (m.no_rows_used <= 0 || m.no_rows_used >= MAX) {
        yyerror("Too many rows in matrix");
        return m;
    }
    if (l.no_columns_used != m.rows[0]->no_columns_used) {
        yyerror("All matrix rows must have the same number of columns");
        return m;
    }

    m.rows[m.no_rows_used] = (line *)malloc(sizeof(line));
    m.rows[m.no_rows_used]->no_columns_used = l.no_columns_used;
    for (int i = 0; i < l.no_columns_used; i++) {
        m.rows[m.no_rows_used]->elems[i] = l.elems[i];
    }
    m.no_rows_used++;
    return m;
}

struct _line insert_nr_in_row(struct _line l, int nr) {
    if (l.no_columns_used >= MAX) {
        yyerror("Too many columns in row");
        return l;
    }

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

int determinant(matr *m) {
    if (!is_rectangular(m)) {
        yyerror("Invalid matrix");
        return 0;
    }
    if (m->no_rows_used != m->rows[0]->no_columns_used) {
        yyerror("Determinant is defined only for square matrices");
        return 0;
    }

    if (m->no_rows_used == 1) {
        return m->rows[0]->elems[0];
    } else if (m->no_rows_used == 2) {
        return m->rows[0]->elems[0] * m->rows[1]->elems[1] - m->rows[0]->elems[1] * m->rows[1]->elems[0];
    } else {
        int det = 0;
        for (int i = 0; i < m->rows[0]->no_columns_used; i++) {
            matr submatrix;
            submatrix.no_rows_used = m->no_rows_used - 1;
            for (int j = 1; j < m->no_rows_used; j++) {
                submatrix.rows[j - 1] = (line *)malloc(sizeof(line));
                submatrix.rows[j - 1]->no_columns_used = m->rows[j]->no_columns_used - 1;
                for (int k = 0; k < m->rows[j]->no_columns_used; k++) {
                    if (k < i) {
                        submatrix.rows[j - 1]->elems[k] = m->rows[j]->elems[k];
                    } else if (k > i) {
                        submatrix.rows[j - 1]->elems[k - 1] = m->rows[j]->elems[k];
                    }
                }
            }
            det += (i % 2 == 0 ? 1 : -1) * m->rows[0]->elems[i] * determinant(&submatrix);
            free_matrix(&submatrix);
        }
        return det;
    }
}