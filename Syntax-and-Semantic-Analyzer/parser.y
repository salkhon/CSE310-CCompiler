%{
    #include <iostream>
    #include <cstdlib>
    #include <cstring>
    #include <cmath>
    #include <string>
    #include "../Symbol Table Manager/include.hpp"

    using namespace std;

    extern FILE* yyin;
    int yyparse();
    int yylex();
    void yyerror(char* str) {}

    FILE* input_file,* log_file,* error_file;

    SymbolTable* symbol_table_ptr;
%}

%union {
    int int_val;
    SymbolInfo* syminfo_ptr;
}

%token<int_val>
    LPAREN RPAREN SEMICOLON COMMA LCURL RCURL INT FLOAT VOID LTHIRD RTHIRD FOR IF ELSE WHILE
    PRINTLN RETURN ASSIGNOP NOT INCOP DECOP

%token<syminfo_ptr>
    ID CONST_INT CONST_FLOAT LOGICOP RELOP ADDOP MULOP

%nterm<syminfo_ptr>
    start program unit var_declaration func_definition type_specifier parameter_list
    compound_statement statements declaration_list statement expression_statement expression
    variable logic_expression rel_expression simple_expression term unary_expression factor argument_list
    arguments func_declaration

%right COMMA
%right ASSIGNOP
%left LOGICOP
%left RELOP
%left ADDOP 
%left MULOP
%right NOT UNARY  // dummy token to reduce unary ADDOP before arithmetic ADDOP
%left INCOP DECOP LPAREN RPAREN LTHIRD RTHIRD 
 // each rule gets its precedence from the last terminal symbol mentioned in the components by default. 

 // ELSE has higher precedence than dummy token SHIFT_ELSE (telling to shift ELSE, rather than reduce lone if)
%nonassoc SHIFT_ELSE
%nonassoc ELSE

%%

start: 
    program {
        cout << "FINISHED\n";
        $$ = new SymbolInfo($1->get_name_str(), "start");
        YYACCEPT;
    }
    ;

program: 
    program unit {
        cout << "in unit: ";
        $$ = new SymbolInfo($1->get_name_str() + " " + $2->get_name_str(), "program");
        cout << $$->get_name_str() << endl;
    }   
    | unit {
        cout << "in single unit: ";
        $$ = new SymbolInfo($1->get_name_str(), "program");
        cout << $$->get_name_str() << endl;
    }
    ;

unit:
    var_declaration {
        $$ = new SymbolInfo($1->get_name_str(), "unit");
    }
    | func_declaration {
        $$ = new SymbolInfo($1->get_name_str(), "unit");
    }
    | func_definition {
        $$ = new SymbolInfo($1->get_name_str(), "unit");
    }
    ;

func_declaration: 
    type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
        $$ = new SymbolInfo($1->get_name_str() + " " + $2->get_name_str() + "(" + $4->get_name_str() + 
            ");", "func_declaration");
    }
    | type_specifier ID LPAREN RPAREN SEMICOLON {
        $$ = new SymbolInfo($1->get_name_str() + " " + $2->get_name_str() + "();", "func_declaration");
    }
    ;

func_definition:
    type_specifier ID LPAREN parameter_list RPAREN compound_statement {
        $$ = new SymbolInfo($1->get_name_str() + " " + $2->get_name_str() + "(" + $4->get_name_str() + ") " + 
            $6->get_name_str(), "func_definition");
    }
    | type_specifier ID LPAREN RPAREN compound_statement {
        $$ = new SymbolInfo($1->get_name_str() + " " + $2->get_name_str() + "() " + 
            $5->get_name_str(), "func_definition");
        cout << "no param func def: " << $$->get_name_str() << endl;
    }
    ;

parameter_list:
    parameter_list COMMA type_specifier ID {
        $$ = new SymbolInfo($1->get_name_str() + ", " + $3->get_name_str() + " " + 
            $4->get_name_str(), "parameter_list");
    }
    | parameter_list COMMA type_specifier {
        $$ = new SymbolInfo($1->get_name_str() + ", " + $3->get_name_str(), "parameter_list");
    }
    | type_specifier ID {
        $$ = new SymbolInfo($1->get_name_str() + " " + $2->get_name_str(), "parameter_list");
    }
    | type_specifier {
        $$ = new SymbolInfo($1->get_name_str(), "parameter_list");
    }
    ;

compound_statement:
    LCURL statements RCURL {
        $$ = new SymbolInfo("{ " + $2->get_name_str() + " }", "compound_statement");
        cout << "compound stmt: " << $$->get_name_str() << endl;
    }
    | LCURL RCURL {
        $$ = new SymbolInfo("{}", "compound_statement");
    }
    ;

var_declaration:
    type_specifier declaration_list SEMICOLON {
        $$ = new SymbolInfo($1->get_name_str() + " " + $2->get_name_str() + ";", "var_declaration");
    }
    ;

type_specifier:
    INT {
        $$ = new SymbolInfo("int", "type_specifier");
    }
    | FLOAT {
        $$ = new SymbolInfo("float", "type_specifier");
    }
    | VOID {
        $$ = new SymbolInfo("void", "type_specifier");
    }
    ;

declaration_list:
    declaration_list COMMA ID {
        $$ = new SymbolInfo($1->get_name_str() + ", " + $3->get_name_str(), "declaration_list");
    }
    | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
        $$ = new SymbolInfo($1->get_name_str() + ", " + $3->get_name_str() + "[" + $5->get_name_str() + 
            "]", "declaration_list");
    }
    | ID {
        $$ = new SymbolInfo($1->get_name_str(), "declaration_list");
    }
    | ID LTHIRD CONST_INT RTHIRD {
        $$ = new SymbolInfo($1->get_name_str() + "[" + $3->get_name_str() + "]", "declaration_list");
    }
    ;

statements:
    statement {
        $$ = new SymbolInfo($1->get_name_str(), "statements");
        cout << "single statement: " << $$->get_name_str() << endl;
    }
    | statements statement {
        $$ = new SymbolInfo($1->get_name_str() + " " + $2->get_name_str(), "statements");
        cout << "multiple stmt: " << $$->get_name_str() << endl;
    }
    ;

statement:
    var_declaration {
        $$ = new SymbolInfo($1->get_name_str(), "statement");
    }
    | expression_statement {
        $$ = new SymbolInfo($1->get_name_str(), "statement");
        cout << "expr stmt: " << $$->get_name_str() << endl;
    }
    | compound_statement {
        $$ = new SymbolInfo($1->get_name_str(), "statement");
    }
    | FOR LPAREN expression_statement expression_statement expression RPAREN statement {
        $$ = new SymbolInfo("for (" + $3->get_name_str() + " " + $4->get_name_str() + " " + 
            $5->get_name_str() + ") " + $7->get_name_str(), "statement");
    }
    | IF LPAREN expression RPAREN statement 
    %prec SHIFT_ELSE {
        $$ = new SymbolInfo("if (" + $3->get_name_str() + ") " + $5->get_name_str(), "statement");
    } 
    | IF LPAREN expression RPAREN statement ELSE statement {
        $$ = new SymbolInfo("if (" + $3->get_name_str() + ") " + $5->get_name_str() + " else " + 
        $7->get_name_str(), "statement");
    }
    | WHILE LPAREN expression RPAREN statement {
        $$ = new SymbolInfo("while (" + $3->get_name_str() + ") " + $5->get_name_str(), "statement");
    }
    | PRINTLN LPAREN ID RPAREN SEMICOLON {
        $$ = new SymbolInfo("printf(" + $3->get_name_str() + ");", "statement");
    }
    | RETURN expression SEMICOLON {
        $$ = new SymbolInfo("return " + $2->get_name_str() + ";", "statement");
    }
    ;

expression_statement:
    SEMICOLON {
        $$ = new SymbolInfo(";", "expression_statement");
    }
    | expression SEMICOLON {
        $$ = new SymbolInfo($1->get_name_str() + ";", "expression_statement");
    }
    ;

variable:
    ID {
        $$ = new SymbolInfo($1->get_name_str(), "variable");
    }
    | ID LTHIRD expression RTHIRD {
        $$ = new SymbolInfo($1->get_name_str() + "[" + $3->get_name_str() + "]", "variable");
    }
    ;

expression:
    logic_expression {
        $$ = new SymbolInfo($1->get_name_str(), "expression");
    }
    | variable ASSIGNOP logic_expression {
        $$ = new SymbolInfo($1->get_name_str() + " = " + $3->get_name_str(), "expression");
        cout << "assign: " << $$->get_name_str() << endl;
    }
    ;

logic_expression:
    rel_expression {
        $$ = new SymbolInfo($1->get_name_str(), "logic_expression");
    }
    | rel_expression LOGICOP rel_expression {
        $$ = new SymbolInfo($1->get_name_str() + " " + $2->get_name_str() + " " +
            $3->get_name_str(), "logic_expression");
    }
    ;

rel_expression:
    simple_expression {
        $$ = new SymbolInfo($1->get_name_str(), "rel_expression");
    }
    | simple_expression RELOP simple_expression {
        $$ = new SymbolInfo($1->get_name_str() + " " + $2->get_name_str() + " " + 
            $3->get_name_str(), "rel_expression");
    }
    ;

simple_expression:
    term {
        $$ = new SymbolInfo($1->get_name_str(), "simple_expression");
    }
    | simple_expression ADDOP term {
        $$ = new SymbolInfo($1->get_name_str() + " " + $2->get_name_str() + " " + 
            $3->get_name_str(), "simple_expression");
        cout << "simple expr: " << $$->get_name_str() << endl;
    }
    ;

term:
    unary_expression {
        $$ = new SymbolInfo($1->get_name_str(), "term");
    }
    | term MULOP unary_expression {
        $$ = new SymbolInfo($1->get_name_str() + " " + $2->get_name_str() + " " +  $3->get_name_str(), "term");
    }
    ;

unary_expression:
    ADDOP unary_expression 
    %prec UNARY {
        $$ = new SymbolInfo($1->get_name_str() + $2->get_name_str(), "unary_expression");
    }
    | NOT unary_expression {
        $$ = new SymbolInfo("!" + $2->get_name_str(), "unary_expression");
    }
    | factor {
        $$ = new SymbolInfo($1->get_name_str(), "unary_expression");
    }
    ;

factor:
    variable {
        $$ = new SymbolInfo($1->get_name_str(), "factor");
    }
    | ID LPAREN argument_list RPAREN {
        $$ = new SymbolInfo($1->get_name_str() + "(" + $3->get_name_str() + ")", "factor");
    }
    | LPAREN expression RPAREN {
        $$ = new SymbolInfo("(" + $2->get_name_str() + ")", "factor");
    }
    | CONST_INT {
        $$ = new SymbolInfo($1->get_name_str(), "factor");
    }
    | CONST_FLOAT {
        $$ = new SymbolInfo($1->get_name_str(), "factor");
    }
    | variable INCOP {
        $$ = new SymbolInfo($1->get_name_str() + "++", "factor");
    }
    | variable DECOP {
        $$ = new SymbolInfo($1->get_name_str() + "--", "factor");
    }
    ;

argument_list:
    arguments {
        $$ = new SymbolInfo($1->get_name_str(), "argument_list");
    }
    | %empty {
        $$ = new SymbolInfo("", "argument_list");
    }
    ;

arguments:
    arguments COMMA logic_expression {
        $$ = new SymbolInfo($1->get_name_str() + ", " + $3->get_name_str(), "arguments");
    }
    | logic_expression {
        $$ = new SymbolInfo($1->get_name_str(), "arguments");
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