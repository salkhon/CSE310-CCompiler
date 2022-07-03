%{
    #include <iostream>
    #include <cstdlib>
    #include <cstring>
    #include <cmath>
    #include <string>
    #include "../Symbol Table Manager/include.hpp"

    using namespace std;

    extern FILE* yyin;
    FILE* input_file,* log_file,* error_file;

    SymbolTable* symbol_table_ptr;

    int yyparse();
    int yylex();

    void yyerror(char* str) {
    }
%}

%union {
    int int_val;
    SymbolInfo* syminfo_ptr;
}

%token<int_val>
    LPAREN RPAREN SEMICOLON COMMA LCURL RCURL INT FLOAT VOID LTHIRD RTHIRD FOR IF ELSE WHILE
    PRINTLN RETURN ASSIGNOP LOGICOP RELOP ADDOP MULOP NOT INCOP DECOP

%token<syminfo_ptr>
    ID CONST_INT CONST_FLOAT

%nterm<int_val>
    program unit var_declaration func_definition type_specifier parameter_list
    compound_statement statements declaration_list statement expression_statement expression
    variable logic_expression rel_expression simple_expression term unary_expression factor argument_list
    arguments

%nterm<syminfo_ptr>
    func_declaration

%left ADDOP 
%left MULOP
%right ASSIGNOP

 // ELSE has higher precedence than dummy token SHIFT_ELSE (telling to shift ELSE, rather than reduce lone if)
%nonassoc SHIFT_ELSE
%nonassoc ELSE

%%

start: 
    program {
        cout << "here" << endl;
    }
    ;

program: 
    program unit {

    }   
    | unit {

    }
    ;

unit:
    var_declaration {

    }
    | func_declaration {

    }
    | func_definition {

    }
    ;

func_declaration: 
    type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {

    }
    | type_specifier ID LPAREN RPAREN SEMICOLON {

    }
    ;

func_definition:
    type_specifier ID LPAREN parameter_list RPAREN compound_statement {

    }
    | type_specifier ID LPAREN RPAREN compound_statement {

    }
    ;

parameter_list:
    parameter_list COMMA type_specifier ID {

    }
    | parameter_list COMMA type_specifier {

    }
    | type_specifier ID {

    }
    | type_specifier {

    }
    ;

compound_statement:
    LCURL statements RCURL {

    }
    | LCURL RCURL {

    }
    ;

var_declaration:
    type_specifier declaration_list SEMICOLON {

    }
    ;

type_specifier:
    INT {

    }
    | FLOAT {

    }
    | VOID {

    }
    ;

declaration_list:
    declaration_list COMMA ID {

    }
    | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {

    }
    | ID {

    }
    | ID LTHIRD CONST_INT RTHIRD {

    }
    ;

statements:
    statement {

    }
    | statements statement {

    }
    ;

statement:
    var_declaration {

    }
    | expression_statement {

    }
    | compound_statement {

    }
    | FOR LPAREN expression_statement expression_statement expression RPAREN statement {

    }
    | IF LPAREN expression RPAREN statement 
    %prec SHIFT_ELSE {

    } 
    | IF LPAREN expression RPAREN statement ELSE statement {

    }
    | WHILE LPAREN expression RPAREN statement {

    }
    | PRINTLN LPAREN ID RPAREN SEMICOLON {

    }
    | RETURN expression SEMICOLON {

    }
    ;

expression_statement:
    SEMICOLON {

    }
    | expression SEMICOLON {

    }
    ;

variable:
    ID {

    }
    | ID LTHIRD expression RTHIRD {

    }
    ;

expression:
    logic_expression {

    }
    | variable ASSIGNOP logic_expression {

    }
    ;

logic_expression:
    rel_expression {

    }
    | rel_expression LOGICOP rel_expression {

    }
    ;

rel_expression:
    simple_expression {
        
    }
    | simple_expression RELOP simple_expression {

    }
    ;

simple_expression:
    term {

    }
    | simple_expression ADDOP term {

    }
    ;

term:
    unary_expression {

    }
    | term MULOP unary_expression {

    }
    ;

unary_expression:
    ADDOP unary_expression {

    }
    | NOT unary_expression {

    }
    | factor {

    }
    ;

factor:
    variable {

    }
    | ID LPAREN argument_list RPAREN {

    }
    | LPAREN expression RPAREN {

    }
    | CONST_INT {

    }
    | CONST_FLOAT {

    }
    | variable INCOP {

    }
    | variable DECOP {

    }
    ;

argument_list:
    arguments {

    }
    | {

    }
    ;

arguments:
    arguments COMMA logic_expression {

    }
    | logic_expression {

    }
    ;

%%

int main(int argc, char* argv[]) {
    if (argc != 2) {
        cout << "ERROR: Parser needs input file as argument\n";
        return 1;
    }

    input_file = fopen(argv[1], "r");
    log_file = fopen("log.txt", "w");
    error_file = fopen("error.txt", "w");

    if (!input_file || !log_file || !error_file) {
        cout << "ERROR: Could not open file\n";
        return 1;
    }

    yyin = input_file;

    yyparse();

    fclose(input_file);
    fclose(log_file);
    fclose(error_file);

    return 0;
}