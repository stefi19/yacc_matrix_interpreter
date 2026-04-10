# Matrix Interpreter (Yacc + Lex)

Small interpreter for matrix operations, built with `yacc` and `lex`.

## Features

- Matrix assignment to variables `A`..`Z`
- Matrix print
- Matrix addition: `A + B`
- Matrix subtraction: `A - B`
- Matrix multiplication: `A * B`
- Determinant: `| A |` or `| (A + B) |`
- Parentheses for precedence: `(A + B) * C`

## Input Syntax

- Variables: single uppercase letter (`A`..`Z`)
- Numbers: non-negative integers
- Matrix assignment ends with `;`
- New line separates rows inside a matrix

Example assignment:

```text
A = 1 2
3 4 ;
```

## Build

Run inside `Lab6/yacc_matrix_interpreter`:

```zsh
yacc -d matrix.y
lex matrix.l
gcc -o MATRIX lex.yy.c y.tab.c -ly -ll
```

## Run

Interactive:

```zsh
./MATRIX
```

From file:

```zsh
./MATRIX < input.txt
```

## Full Run Example

### Example Input

```text
A = 1 2
3 4 ;
B = 5 6
7 8 ;
A ;
B ;
A + B ;
A - B ;
A * B ;
| A | ;
( A + B ) * B ;
| ( A + B ) | ;
```

### Expected Output

```text
1 2 
3 4 
5 6 
7 8 
6 8 
10 12 
-4 -4 
-4 -4 
19 22 
43 50 
-2
86 100 
134 156 
-8
```

## Notes

- `MAX` size is `10` (max rows and max columns).
- Determinant is only defined for square matrices.
- Matrix add/subtract require same dimensions.
- Matrix multiply requires: `cols(left) == rows(right)`.

