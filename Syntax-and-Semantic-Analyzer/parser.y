%{
    #include <iostream>
    #include <cstdlib>
    #include <cstring>
    #include <cmath>
    #include <string>
    #include <sstream>
    #include <vector>
    #include "../Symbol Table Manager/include.hpp"

    using namespace std;

    extern FILE* yyin;
    extern int line_count;

    int yyparse();
    int yylex();
    void yyerror(char* str);

    FILE* input_file,* log_file,* error_file;

    const int SYM_TABLE_BUCKETS = 10;
    SymbolTable symbol_table(SYM_TABLE_BUCKETS);

    vector<string> split(string, char);
    void insert_into_symtable(string, vector<string>);
    void write_log(string, SymbolInfo*);
    void write_error_log(string);
    void write_symtable_in_log(SymbolTable&);
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
        $$ = new SymbolInfo($1->get_name_str(), "start");

        string production = "start : program";
        write_log(production, $$);

        delete $1;

        YYACCEPT;
    }
    ;

program: 
    program unit {
        $$ = new SymbolInfo($1->get_name_str() + $2->get_name_str(), "program");

        string production = "program : program unit";
        write_log(production, $$);

        delete $1, $2;
    }   
    | unit {
        $$ = new SymbolInfo($1->get_name_str(), "program");

        string production = "program : unit";
        write_log(production, $$);

        delete $1;
    }
    ;

unit:
    var_declaration {
        $$ = new SymbolInfo($1->get_name_str(), "unit");

        string production = "unit : var_declaration";
        write_log(production, $$);

        delete $1;
    }
    | func_declaration {
        $$ = new SymbolInfo($1->get_name_str(), "unit");

        string production = "unit : func_declaration";
        write_log(production, $$);

        delete $1;
    }
    | func_definition {
        $$ = new SymbolInfo($1->get_name_str(), "unit");

        string production = "unit : func_definition";
        write_log(production, $$);

        delete $1;
    }
    ;

func_declaration: 
    type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
        $$ = new SymbolInfo($1->get_name_str() + " " + $2->get_name_str() + "(" + $4->get_name_str() + 
            ");\n", "func_declaration");

        string production = "func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON";
        write_log(production, $$);

        symbol_table.exit_scope();

        delete $1, $2, $4;
    }
    ;

func_definition:
    type_specifier ID LPAREN parameter_list RPAREN compound_statement {
        $$ = new SymbolInfo($1->get_name_str() + " " + $2->get_name_str() + "(" + $4->get_name_str() + ") " + 
            $6->get_name_str(), "func_definition");

        string production = "func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement";
        write_log(production, $$);

        write_symtable_in_log(symbol_table);
        symbol_table.exit_scope();

        delete $1, $2, $4, $6;
    }
    ;

parameter_list:
    parameter_list COMMA type_specifier ID {
        $$ = new SymbolInfo($1->get_name_str() + "," + $3->get_name_str() + " " + 
            $4->get_name_str(), "parameter_list");

        insert_into_symtable($3->get_name_str() + "_param", {$4->get_name_str()});

        string production = "parameter_list : parameter_list COMMA type_specifier ID";
        write_log(production, $$);

        delete $1, $3, $4;
    }
    | parameter_list COMMA type_specifier {
        $$ = new SymbolInfo($1->get_name_str() + "," + $3->get_name_str(), "parameter_list");

        insert_into_symtable($3->get_name_str() + "_param", {""});

        string production = "parameter_list : parameter_list COMMA type_specifier";
        write_log(production, $$);

        delete $1, $3;
    }
    | type_specifier ID {
        $$ = new SymbolInfo($1->get_name_str() + " " + $2->get_name_str(), "parameter_list");

        insert_into_symtable($<syminfo_ptr>-2->get_name_str() + "_function", {$<syminfo_ptr>-1->get_name_str()});
        symbol_table.enter_scope();
        insert_into_symtable($1->get_name_str() + "_param", {$2->get_name_str()});

        string production = "parameter_list : type_specifier ID";
        write_log(production, $$);

        delete $1, $2;
    }
    | type_specifier {
        $$ = new SymbolInfo($1->get_name_str(), "parameter_list");

        insert_into_symtable($<syminfo_ptr>-2->get_name_str() + "_function", {$<syminfo_ptr>-1->get_name_str()});
        symbol_table.enter_scope();
        insert_into_symtable($1->get_name_str() + "_param", {""});

        string production = "parameter_list : type_specifier";
        write_log(production, $$);

        delete $1;
    }
    | %empty {
        $$ = new SymbolInfo("", "parameter_list");

        insert_into_symtable($<syminfo_ptr>-2->get_name_str() + "_function", {$<syminfo_ptr>-1->get_name_str()});
        symbol_table.enter_scope();
    }
    ;

compound_statement:
    LCURL statements RCURL {
        $$ = new SymbolInfo("{\n" + $2->get_name_str() + "}\n", "compound_statement");


        string production = "compound_statement : LCURL statements RCURL";
        write_log(production, $$);

        delete $2;
    }
    | LCURL RCURL {
        $$ = new SymbolInfo("{}", "compound_statement");

        string production = "compound_statement : LCURL RCURL";
        write_log(production, $$);
    }
    ;

var_declaration:
    type_specifier declaration_list SEMICOLON {
        $$ = new SymbolInfo($1->get_name_str() + " " + $2->get_name_str() + ";\n", "var_declaration");

        string var_type = $1->get_name_str();
        vector<string> var_names = split($2->get_name_str(), ',');
        insert_into_symtable(var_type, var_names);

        string production = "var_declaration : type_specifier declaration_list SEMICOLON";
        write_log(production, $$);

        delete $1, $2;
    }
    ;

type_specifier:
    INT {
        $$ = new SymbolInfo("int", "type_specifier");

        string production = "type_specifier : INT";
        write_log(production, $$);
    }
    | FLOAT {
        $$ = new SymbolInfo("float", "type_specifier");

        string production = "type_specifier : FLOAT";
        write_log(production, $$);
    }
    | VOID {
        $$ = new SymbolInfo("void", "type_specifier");

        string production = "type_specifier : VOID";
        write_log(production, $$);
    }
    ;

declaration_list:
    declaration_list COMMA ID {
        $$ = new SymbolInfo($1->get_name_str() + "," + $3->get_name_str(), "declaration_list");

        string production = "declaration_list : declaration_list COMMA ID";
        write_log(production, $$);

        delete $1, $3;
    }
    | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
        $$ = new SymbolInfo($1->get_name_str() + "," + $3->get_name_str() + "[" + $5->get_name_str() + 
            "]", "declaration_list");

        string production = "declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD";
        write_log(production, $$);

        delete $1, $3, $5;
    }
    | ID {
        $$ = new SymbolInfo($1->get_name_str(), "declaration_list");

        string production = "declaration_list : ID";
        write_log(production, $$);

        delete $1;
    }
    | ID LTHIRD CONST_INT RTHIRD {
        $$ = new SymbolInfo($1->get_name_str() + "[" + $3->get_name_str() + "]", "declaration_list");

        string production = "declaration_list : ID LTHIRD CONST_INT RTHIRD";
        write_log(production, $$);

        delete $1, $3;
    }
    ;

statements:
    statement {
        $$ = new SymbolInfo($1->get_name_str(), "statements");

        string production = "statements : statement";
        write_log(production, $$);

        delete $1;
    }
    | statements statement {
        $$ = new SymbolInfo($1->get_name_str() + $2->get_name_str(), "statements");
        
        string production = "statements : statements statement";
        write_log(production, $$);

        delete $1, $2;
    }
    ;

statement:
    var_declaration {
        $$ = new SymbolInfo($1->get_name_str(), "statement");

        string production = "statement : var_declaration";
        write_log(production, $$);

        delete $1;
    }
    | expression_statement {
        $$ = new SymbolInfo($1->get_name_str(), "statement");

        string production = "statement : expression_statement";
        write_log(production, $$);

        delete $1;
    }
    | compound_statement {
        $$ = new SymbolInfo($1->get_name_str(), "statement");

        string production = "statement : compound_statement";
        write_log(production, $$);

        delete $1;
    }
    | FOR LPAREN expression_statement expression_statement expression RPAREN statement {
        $$ = new SymbolInfo("for (" + $3->get_name_str() + " " + $4->get_name_str() + " " + 
            $5->get_name_str() + ")\n" + $7->get_name_str(), "statement");
            
        string production = "statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement";
        write_log(production, $$);

        delete $3, $4, $5, $7;
    }
    | IF LPAREN expression RPAREN statement 
    %prec SHIFT_ELSE {
        $$ = new SymbolInfo("if (" + $3->get_name_str() + ")\n" + $5->get_name_str(), "statement");

        string production = "statement : IF LPAREN expression RPAREN statement";
        write_log(production, $$);

        delete $3, $5;
    } 
    | IF LPAREN expression RPAREN statement ELSE statement {
        $$ = new SymbolInfo("if (" + $3->get_name_str() + ")\n" + $5->get_name_str() + " else\n" + 
            $7->get_name_str(), "statement");

        string production = "statement : IF LPAREN expression RPAREN statement ELSE statement";
        write_log(production, $$);

        delete $3, $5, $7;
    }
    | WHILE LPAREN expression RPAREN statement {
        $$ = new SymbolInfo("while (" + $3->get_name_str() + ")\n" + $5->get_name_str(), "statement");

        string production = "statement : WHILE LPAREN expression RPAREN statement";
        write_log(production, $$);

        delete $3, $5;
    }
    | PRINTLN LPAREN ID RPAREN SEMICOLON {
        $$ = new SymbolInfo("printf(" + $3->get_name_str() + ");\n", "statement");

        string production = "statement : PRINTLN LPAREN ID RPAREN SEMICOLON";
        write_log(production, $$);

        delete $3;
    }
    | RETURN expression SEMICOLON {
        $$ = new SymbolInfo("return " + $2->get_name_str() + ";\n", "statement");

        string production = "statement : RETURN expression SEMICOLON";
        write_log(production, $$);

        delete $2;
    }
    ;

expression_statement:
    SEMICOLON {
        $$ = new SymbolInfo(";\n", "expression_statement");

        string production = "expression_statement : SEMICOLON";
        write_log(production, $$);
    }
    | expression SEMICOLON {
        $$ = new SymbolInfo($1->get_name_str() + ";\n", "expression_statement");

        string production = "expression_statement : expression SEMICOLON";
        write_log(production, $$);

        delete $1;
    }
    ;

variable:
    ID {
        $$ = new SymbolInfo($1->get_name_str(), "variable");

        string production = "variable : ID";
        write_log(production, $$);

        delete $1;
    }
    | ID LTHIRD expression RTHIRD {
        $$ = new SymbolInfo($1->get_name_str() + "[" + $3->get_name_str() + "]", "variable");

        string production = "variable : ID LTHIRD expression RTHIRD";
        write_log(production, $$);

        delete $1, $3;
    }
    ;

expression:
    logic_expression {
        $$ = new SymbolInfo($1->get_name_str(), "expression");

        string production = "expression : logic_expression";
        write_log(production, $$);

        delete $1;
    }
    | variable ASSIGNOP logic_expression {
        $$ = new SymbolInfo($1->get_name_str() + " = " + $3->get_name_str(), "expression");

        string production = "expression : variable ASSIGNOP logic_expression";
        write_log(production, $$);

        delete $1, $3;
    }
    ;

logic_expression:
    rel_expression {
        $$ = new SymbolInfo($1->get_name_str(), "logic_expression");

        string production = "logic_expression : rel_expression";
        write_log(production, $$);

        delete $1;
    }
    | rel_expression LOGICOP rel_expression {
        $$ = new SymbolInfo($1->get_name_str() + " " + $2->get_name_str() + " " +
            $3->get_name_str(), "logic_expression");

        string production = "logic_expression : rel_expression LOGICOP rel_expression";
        write_log(production, $$);

        delete $1, $2, $3;
    }
    ;

rel_expression:
    simple_expression {
        $$ = new SymbolInfo($1->get_name_str(), "rel_expression");

        string production = "rel_expression : simple_expression";
        write_log(production, $$);

        delete $1;
    }
    | simple_expression RELOP simple_expression {
        $$ = new SymbolInfo($1->get_name_str() + " " + $2->get_name_str() + " " + 
            $3->get_name_str(), "rel_expression");

        string production = "rel_expression : simple_expression RELOP simple_expression";
        write_log(production, $$);

        delete $1, $2, $3;
    }
    ;

simple_expression:
    term {
        $$ = new SymbolInfo($1->get_name_str(), "simple_expression");

        string production = "simple_expression : term";
        write_log(production, $$);

        delete $1;
    }
    | simple_expression ADDOP term {
        $$ = new SymbolInfo($1->get_name_str() + " " + $2->get_name_str() + " " + 
            $3->get_name_str(), "simple_expression");

        string production = "simple_expression : simple_expression ADDOP term";
        write_log(production, $$);

        delete $1, $2, $3;
    }
    ;

term:
    unary_expression {
        $$ = new SymbolInfo($1->get_name_str(), "term");

        string production = "term : unary_expression";
        write_log(production, $$);

        delete $1;
    }
    | term MULOP unary_expression {
        $$ = new SymbolInfo($1->get_name_str() + " " + $2->get_name_str() + " " +  $3->get_name_str(), "term");

        string production = "term : term MULOP unary_expression";
        write_log(production, $$);

        delete $1, $2, $3;
    }
    ;

unary_expression:
    ADDOP unary_expression 
    %prec UNARY {
        $$ = new SymbolInfo($1->get_name_str() + $2->get_name_str(), "unary_expression");

        string production = "unary_expression : ADDOP unary_expression";
        write_log(production, $$);

        delete $1, $2;
    }
    | NOT unary_expression {
        $$ = new SymbolInfo("!" + $2->get_name_str(), "unary_expression");

        string production = "unary_expression : NOT unary_expression";
        write_log(production, $$);

        delete $2;
    }
    | factor {
        $$ = new SymbolInfo($1->get_name_str(), "unary_expression");

        string production = "unary_expression : factor";
        write_log(production, $$);

        delete $1;
    }
    ;

factor:
    variable {
        $$ = new SymbolInfo($1->get_name_str(), "factor");

        string production = "factor : variable";
        write_log(production, $$);

        delete $1;
    }
    | ID LPAREN argument_list RPAREN {
        $$ = new SymbolInfo($1->get_name_str() + "(" + $3->get_name_str() + ")", "factor");

        string production = "factor : ID LPAREN argument_list RPAREN";
        write_log(production, $$);

        delete $1, $3;
    }
    | LPAREN expression RPAREN {
        $$ = new SymbolInfo("(" + $2->get_name_str() + ")", "factor");

        string production = "factor : LPAREN expression RPAREN";
        write_log(production, $$);

        delete $2;
    }
    | CONST_INT {
        $$ = new SymbolInfo($1->get_name_str(), "factor");

        string production = "factor : CONST_INT";
        write_log(production, $$);

        delete $1;
    }
    | CONST_FLOAT {
        $$ = new SymbolInfo($1->get_name_str(), "factor");

        string production = "factor : CONST_FLOAT";
        write_log(production, $$);

        delete $1;
    }
    | variable INCOP {
        $$ = new SymbolInfo($1->get_name_str() + "++", "factor");

        string production = "factor : variable INCOP";
        write_log(production, $$);

        delete $1;
    }
    | variable DECOP {
        $$ = new SymbolInfo($1->get_name_str() + "--", "factor");

        string production = "factor : variable DECOP";
        write_log(production, $$);

        delete $1;
    }
    ;

argument_list:
    arguments {
        $$ = new SymbolInfo($1->get_name_str(), "argument_list");

        string production = "argument_list : arguments";
        write_log(production, $$);

        delete $1;
    }
    | %empty {
        $$ = new SymbolInfo("", "argument_list");

        string production = "argument_list : ";
        write_log(production, $$);
    }
    ;

arguments:
    arguments COMMA logic_expression {
        $$ = new SymbolInfo($1->get_name_str() + "," + $3->get_name_str(), "arguments");

        string production = "arguments : arguments COMMA logic_expression";
        write_log(production, $$);

        delete $1, $3;
    }
    | logic_expression {
        $$ = new SymbolInfo($1->get_name_str(), "arguments");

        string production = "arguments : logic_expression";
        write_log(production, $$);

        delete $1;
    }
    ;

%%

void yyerror(char* s) {

}

vector<string> split(string str, char delim) {
    stringstream sstrm(str);
    string split_str;
    vector<string> split_strs;

    while (getline(sstrm, split_str, delim)) {
        split_strs.push_back(split_str);    
    }

    return split_strs; 
}

void insert_into_symtable(string sym_type, vector<string> sym_names) {
    for (string sym_name : sym_names) {
        if (!symbol_table.insert(sym_name, sym_type)) {
            write_error_log("[REDEF] Symbol name " + sym_name  + " already exists");
        }
    }
}

void write_log(string production, SymbolInfo* matched_sym_ptr) {
    fprintf(log_file, "Line %d: %s\n\n", line_count, production.c_str());
    fprintf(log_file, "%s\n\n", matched_sym_ptr->get_name_str().c_str());
}

void write_error_log(string log_str) {
    fprintf(log_file, "[ERROR] Line %d: %s\n", line_count, log_str.c_str());
    fprintf(error_file, "[ERROR] Line %d: %s\n", line_count, log_str.c_str());
}

void write_symtable_in_log(SymbolTable& symtable) {
    ostringstream osstrm;
    osstrm << symtable;
    fprintf(log_file, "%s\n", osstrm.str().c_str());
}

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