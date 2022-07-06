%{
    #include <iostream>
    #include <cstdlib>
    #include <cstring>
    #include <cmath>
    #include <string>
    #include <sstream>
    #include <vector>
    #include <algorithm>
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

    const string INT_TYPE = "int";
    const string INT_ARRAY_TYPE = "int_arr";
    const string FLOAT_TYPE = "float";
    const string FLOAT_ARRAY_TYPE = "float_arr";
    const string VOID_TYPE = "void";
    // TODO: needs array type with size for index checking

    SymbolInfo* current_func_sym_ptr;

    vector<string> split(string, char = ' ');
    bool insert_into_symtable(string, string, vector<string> = {});
    bool insert_var_list_into_symtable(string var_type, vector<string> var_names);
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

        write_symtable_in_log(symbol_table);

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
        $$ = new SymbolInfo($1->get_name_str(), VOID_TYPE);

        string production = "unit : var_declaration";
        write_log(production, $$);

        delete $1;
    }
    | func_declaration {
        $$ = new SymbolInfo($1->get_name_str(), VOID_TYPE);

        string production = "unit : func_declaration";
        write_log(production, $$);

        delete $1;
    }
    | func_definition {
        $$ = new SymbolInfo($1->get_name_str(), VOID_TYPE);

        string production = "unit : func_definition";
        write_log(production, $$);

        delete $1;
    }
    ;

func_declaration: 
    type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
        $$ = new SymbolInfo($1->get_name_str() + " " + $2->get_name_str() + "(" + $4->get_name_str() + 
            ");\n", VOID_TYPE);

        string production = "func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON";
        write_log(production, $$);

        symbol_table.exit_scope();

        delete $1, $2, $4;
    }
    ;

func_definition:
    type_specifier ID LPAREN parameter_list RPAREN compound_statement {
        $$ = new SymbolInfo($1->get_name_str() + " " + $2->get_name_str() + "(" + $4->get_name_str() + ") " + 
            $6->get_name_str(), VOID_TYPE);

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
            $4->get_name_str(), VOID_TYPE);

        string param_type = $3->get_name_str();
        current_func_sym_ptr->add_func_type(param_type);

        insert_into_symtable(param_type, $4->get_name_str());

        string production = "parameter_list : parameter_list COMMA type_specifier ID";
        write_log(production, $$);

        delete $1, $3, $4;
    }
    | parameter_list COMMA type_specifier {
        $$ = new SymbolInfo($1->get_name_str() + "," + $3->get_name_str(), VOID_TYPE);

        string param_type = $3->get_name_str();
        current_func_sym_ptr->add_func_type(param_type);

        string production = "parameter_list : parameter_list COMMA type_specifier";
        write_log(production, $$);

        delete $1, $3;
    }
    | type_specifier ID {
        $$ = new SymbolInfo($1->get_name_str() + " " + $2->get_name_str(), VOID_TYPE);

        string func_name = $<syminfo_ptr>-1->get_name_str();
        string return_type = $<syminfo_ptr>-2->get_name_str();

        insert_into_symtable(return_type + "_func", func_name);
        current_func_sym_ptr = symbol_table.lookup(func_name);

        current_func_sym_ptr->add_func_type(return_type);

        symbol_table.enter_scope();

        string param_type = $1->get_name_str();
        current_func_sym_ptr->add_func_type(param_type);
        insert_into_symtable(param_type, $2->get_name_str());

        string production = "parameter_list : type_specifier ID";
        write_log(production, $$);

        delete $1, $2;
    }
    | type_specifier {
        $$ = new SymbolInfo($1->get_name_str(), VOID_TYPE);

        string func_name = $<syminfo_ptr>-1->get_name_str();
        string return_type = $<syminfo_ptr>-2->get_name_str();

        insert_into_symtable(return_type + "_func", func_name);
        current_func_sym_ptr = symbol_table.lookup(func_name);

        current_func_sym_ptr->add_func_type(return_type);

        symbol_table.enter_scope();

        string param_type = $1->get_name_str();
        current_func_sym_ptr->add_func_type(param_type);

        string production = "parameter_list : type_specifier";
        write_log(production, $$);

        delete $1;
    }
    | %empty {
        $$ = new SymbolInfo("", VOID_TYPE);

        string func_name = $<syminfo_ptr>-1->get_name_str();
        string return_type = $<syminfo_ptr>-2->get_name_str();

        insert_into_symtable(return_type + "_func", func_name);
        current_func_sym_ptr = symbol_table.lookup(func_name);

        current_func_sym_ptr->add_func_type(return_type);

        symbol_table.enter_scope();

        string production = "parameter_list : epsilon";
        write_log(production, $$);
    }
    ;

compound_statement:
    LCURL statements RCURL {
        $$ = new SymbolInfo("{\n" + $2->get_name_str() + "}\n", $2->get_type_str());

        string production = "compound_statement : LCURL statements RCURL";
        write_log(production, $$);

        delete $2;
    }
    | LCURL RCURL {
        $$ = new SymbolInfo("{}", VOID_TYPE);

        string production = "compound_statement : LCURL RCURL";
        write_log(production, $$);
    }
    ;

var_declaration:
    type_specifier declaration_list SEMICOLON {
        $$ = new SymbolInfo($1->get_name_str() + " " + $2->get_name_str() + ";\n", VOID_TYPE);

        string var_type = $1->get_name_str();
        vector<string> var_names = split($2->get_name_str(), ',');
        insert_var_list_into_symtable(var_type, var_names);

        string production = "var_declaration : type_specifier declaration_list SEMICOLON";
        write_log(production, $$);

        delete $1, $2;
    }
    ;

type_specifier:
    INT {
        $$ = new SymbolInfo("int", VOID_TYPE);

        string production = "type_specifier : INT";
        write_log(production, $$);
    }
    | FLOAT {
        $$ = new SymbolInfo("float", VOID_TYPE);

        string production = "type_specifier : FLOAT";
        write_log(production, $$);
    }
    | VOID {
        $$ = new SymbolInfo("void", VOID_TYPE);

        string production = "type_specifier : VOID";
        write_log(production, $$);
    }
    ;

declaration_list:
    declaration_list COMMA ID {
        $$ = new SymbolInfo($1->get_name_str() + "," + $3->get_name_str(), VOID_TYPE);

        string production = "declaration_list : declaration_list COMMA ID";
        write_log(production, $$);

        delete $1, $3;
    }
    | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
        $$ = new SymbolInfo($1->get_name_str() + "," + $3->get_name_str() + 
            "[" + $5->get_name_str() + "]", VOID_TYPE);

        string production = "declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD";
        write_log(production, $$);

        delete $1, $3, $5;
    }
    | ID {
        $$ = new SymbolInfo($1->get_name_str(), VOID_TYPE);

        string production = "declaration_list : ID";
        write_log(production, $$);

        delete $1;
    }
    | ID LTHIRD CONST_INT RTHIRD {
        $$ = new SymbolInfo($1->get_name_str() + "[" + $3->get_name_str() + "]", VOID_TYPE);

        string production = "declaration_list : ID LTHIRD CONST_INT RTHIRD";
        write_log(production, $$);

        delete $1, $3;
    }
    ;

statements:
    statement {
        $$ = new SymbolInfo($1->get_name_str(), $1->get_type_str());

        string production = "statements : statement";
        write_log(production, $$);

        delete $1;
    }
    | statements statement {
        string statement_type = VOID_TYPE;
        if  ($1->get_type_str() == FLOAT_TYPE || $2->get_type_str() == FLOAT_TYPE) {
            statement_type = FLOAT_TYPE;
        } else if ($1->get_type_str() == INT_TYPE || $2->get_type_str() == FLOAT_TYPE) {
            statement_type = INT_TYPE;
        }

        $$ = new SymbolInfo($1->get_name_str() + $2->get_name_str(), statement_type);
        
        string production = "statements : statements statement";
        write_log(production, $$);

        delete $1, $2;
    }
    ;

statement:
    var_declaration {
        $$ = new SymbolInfo($1->get_name_str(), $1->get_type_str());

        string production = "statement : var_declaration";
        write_log(production, $$);

        delete $1;
    }
    | expression_statement {
        $$ = new SymbolInfo($1->get_name_str(), $1->get_type_str());

        string production = "statement : expression_statement";
        write_log(production, $$);

        delete $1;
    }
    | compound_statement {
        $$ = new SymbolInfo($1->get_name_str(), $1->get_type_str());

        string production = "statement : compound_statement";
        write_log(production, $$);

        delete $1;
    }
    | FOR LPAREN expression_statement expression_statement expression RPAREN statement {
        if ($4->get_type_str() == VOID_TYPE) {
            write_error_log("for conditional expression cannot be void type");
        }

        $$ = new SymbolInfo("for (" + $3->get_name_str() + " " + $4->get_name_str() + " " + 
            $5->get_name_str() + ")\n" + $7->get_name_str(), $7->get_type_str());
            
        string production = "statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement";
        write_log(production, $$);

        delete $3, $4, $5, $7;
    }
    | IF LPAREN expression RPAREN statement 
    %prec SHIFT_ELSE {
        if ($3->get_type_str() == VOID_TYPE) {
            write_error_log("if expression cannot be void type");
        }

        $$ = new SymbolInfo("if (" + $3->get_name_str() + ")\n" + $5->get_name_str(), $5->get_type_str());

        string production = "statement : IF LPAREN expression RPAREN statement";
        write_log(production, $$);

        delete $3, $5;
    } 
    | IF LPAREN expression RPAREN statement ELSE statement {
        if ($3->get_type_str() == VOID_TYPE) {
            write_error_log("if expression cannot be void type");
        }

        string statement_type = VOID_TYPE;
        if  ($5->get_type_str() == FLOAT_TYPE || $7->get_type_str() == FLOAT_TYPE) {
            statement_type = FLOAT_TYPE;
        } else if ($5->get_type_str() == INT_TYPE || $7->get_type_str() == FLOAT_TYPE) {
            statement_type = INT_TYPE;
        }

        $$ = new SymbolInfo("if (" + $3->get_name_str() + ")\n" + $5->get_name_str() + " else\n" + 
            $7->get_name_str(), statement_type);

        string production = "statement : IF LPAREN expression RPAREN statement ELSE statement";
        write_log(production, $$);

        delete $3, $5, $7;
    }
    | WHILE LPAREN expression RPAREN statement {
        if ($3->get_type_str() == VOID_TYPE) {
            write_error_log("while loop expression cannot be void type");
        }

        $$ = new SymbolInfo("while (" + $3->get_name_str() + ")\n" + $5->get_name_str(), $5->get_type_str());

        string production = "statement : WHILE LPAREN expression RPAREN statement";
        write_log(production, $$);

        delete $3, $5;
    }
    | PRINTLN LPAREN ID RPAREN SEMICOLON {
        $$ = new SymbolInfo("printf(" + $3->get_name_str() + ");\n", VOID_TYPE);

        string production = "statement : PRINTLN LPAREN ID RPAREN SEMICOLON";
        write_log(production, $$);

        delete $3;
    }
    | RETURN expression SEMICOLON {
        $$ = new SymbolInfo("return " + $2->get_name_str() + ";\n", $2->get_type_str());

        string production = "statement : RETURN expression SEMICOLON";
        write_log(production, $$);

        string expression_type = $2->get_type_str();
        string func_return_type = current_func_sym_ptr->get_func_types()[0];

        if (func_return_type == FLOAT_TYPE && expression_type == INT_TYPE) {
            // okay
        } else if (func_return_type == INT_TYPE && expression_type == FLOAT_TYPE) {
            write_error_log("[WARNING] Returning float type from a function with int return type");
        } else if (func_return_type != expression_type) {
            write_error_log("Cannot return " + expression_type + " from a function of " + 
                func_return_type + " return type");
        }

        delete $2;
    }
    ;

expression_statement:
    SEMICOLON {
        $$ = new SymbolInfo(";\n", VOID_TYPE);

        string production = "expression_statement : SEMICOLON";
        write_log(production, $$);
    }
    | expression SEMICOLON {
        $$ = new SymbolInfo($1->get_name_str() + ";\n", $1->get_type_str());

        string production = "expression_statement : expression SEMICOLON";
        write_log(production, $$);

        delete $1;
    }
    ;

variable:
    ID {
        string var_name = $1->get_name_str();
        SymbolInfo* var_sym_ptr = symbol_table.lookup(var_name);
        string var_type = INT_TYPE;

        if (var_sym_ptr == nullptr) {
            write_error_log(var_name + " does not exist");
        } else {
            var_type = var_sym_ptr->get_type_str();
        }

        if (var_type == INT_ARRAY_TYPE) {
            write_error_log(var_name + " is an array and has to be indexed");
            var_type = INT_TYPE;
        } else if (var_type == FLOAT_ARRAY_TYPE) {
            write_error_log(var_name + " is an array and has to be indexed");
            var_type = FLOAT_TYPE;
        }

        $$ = new SymbolInfo($1->get_name_str(), var_type);

        string production = "variable : ID";
        write_log(production, $$);

        delete $1;
    }
    | ID LTHIRD expression RTHIRD {
        if ($3->get_type_str() != INT_TYPE) {
            write_error_log("array index can only be int type");
        }

        string var_name = $1->get_name_str();
        SymbolInfo* var_sym_ptr = symbol_table.lookup(var_name);
        string var_type = INT_ARRAY_TYPE;

        if (var_sym_ptr == nullptr) {
            write_error_log(var_name + " does not exist");
        } else {
            var_type = var_sym_ptr->get_type_str();
        }

        if (var_type == INT_TYPE || var_type == FLOAT_TYPE) {
            write_error_log(var_name + " is not an array and cannot be indexed");
            var_type = INT_ARRAY_TYPE;
        }

        if (var_type == INT_ARRAY_TYPE) {
            var_type = INT_TYPE;
        } else {
            var_type = FLOAT_TYPE;
        }

        $$ = new SymbolInfo($1->get_name_str() + "[" + $3->get_name_str() + "]", var_type);

        string production = "variable : ID LTHIRD expression RTHIRD";
        write_log(production, $$);

        delete $1, $3;
    }
    ;

expression:
    logic_expression {
        $$ = new SymbolInfo($1->get_name_str(), $1->get_type_str());

        string production = "expression : logic_expression";
        write_log(production, $$);

        delete $1;
    }
    | variable ASSIGNOP logic_expression {
        string type = $1->get_type_str();
        if ($3->get_type_str() == VOID_TYPE) {
            write_error_log("Void type cannot be assigned to any type");
        } else if ($1->get_type_str() == FLOAT_TYPE && $3->get_type_str() == INT_TYPE) {
            // okay  
        } else if ($1->get_type_str() == INT_TYPE && $3->get_type_str() == FLOAT_TYPE) {
            write_error_log("[WARNING]: Assigning float to int");
        } else if ($1->get_type_str() != $3->get_type_str()) {
            write_error_log("Cannot assign " + $3->get_type_str() + " to " + $1->get_type_str());
        }

        $$ = new SymbolInfo($1->get_name_str() + " = " + $3->get_name_str(), type);

        string production = "expression : variable ASSIGNOP logic_expression";
        write_log(production, $$);

        delete $1, $3;
    }
    ;

logic_expression:
    rel_expression {
        $$ = new SymbolInfo($1->get_name_str(), $1->get_type_str());

        string production = "logic_expression : rel_expression";
        write_log(production, $$);

        delete $1;
    }
    | rel_expression LOGICOP rel_expression {
        if ($1->get_type_str() == VOID_TYPE || $3->get_type_str() == VOID_TYPE) {
            write_error_log("Logical operation not defined on void type");
        }

        $$ = new SymbolInfo($1->get_name_str() + " " + $2->get_name_str() + " " +
            $3->get_name_str(), INT_TYPE);

        string production = "logic_expression : rel_expression LOGICOP rel_expression";
        write_log(production, $$);

        delete $1, $2, $3;
    }
    ;

rel_expression:
    simple_expression {
        $$ = new SymbolInfo($1->get_name_str(), $1->get_type_str());

        string production = "rel_expression : simple_expression";
        write_log(production, $$);

        delete $1;
    }
    | simple_expression RELOP simple_expression {
        if ($1->get_type_str() == VOID_TYPE || $3->get_type_str() == VOID_TYPE) {
            write_error_log("Relational operation not defined on void type");
        }

        $$ = new SymbolInfo($1->get_name_str() + " " + $2->get_name_str() + " " + 
            $3->get_name_str(), INT_TYPE);

        string production = "rel_expression : simple_expression RELOP simple_expression";
        write_log(production, $$);

        delete $1, $2, $3;
    }
    ;

simple_expression:
    term {
        $$ = new SymbolInfo($1->get_name_str(), $1->get_type_str());

        string production = "simple_expression : term";
        write_log(production, $$);

        delete $1;
    }
    | simple_expression ADDOP term {
        string type = INT_TYPE;
        if ($1->get_type_str() == VOID_TYPE || $3->get_type_str() == VOID_TYPE) {
            write_error_log("Addition not defined on void type");
        } else if ($1->get_type_str() == FLOAT_TYPE || $3->get_type_str() == FLOAT_TYPE) {
            type = FLOAT_TYPE;
        }

        $$ = new SymbolInfo($1->get_name_str() + " " + $2->get_name_str() + " " + 
            $3->get_name_str(), type);

        string production = "simple_expression : simple_expression ADDOP term";
        write_log(production, $$);

        delete $1, $2, $3;
    }
    ;

term:
    unary_expression {
        $$ = new SymbolInfo($1->get_name_str(), $1->get_type_str());

        string production = "term : unary_expression";
        write_log(production, $$);

        delete $1;
    }
    | term MULOP unary_expression {
        string type = INT_TYPE;
        if ($1->get_type_str() == VOID_TYPE || $3->get_type_str() == VOID_TYPE) {
            write_error_log("Multiplication not defined on void type");
        } else if ($1->get_type_str() == FLOAT_TYPE || $3->get_type_str() == FLOAT_TYPE) {
            type = FLOAT_TYPE;
        }

        $$ = new SymbolInfo($1->get_name_str() + " " + $2->get_name_str() + " " +  $3->get_name_str(), type);

        string production = "term : term MULOP unary_expression";
        write_log(production, $$);

        delete $1, $2, $3;
    }
    ;

unary_expression:
    ADDOP unary_expression 
    %prec UNARY {
        $$ = new SymbolInfo($1->get_name_str() + $2->get_name_str(), $2->get_type_str());

        string production = "unary_expression : ADDOP unary_expression";
        write_log(production, $$);

        delete $1, $2;
    }
    | NOT unary_expression {
        $$ = new SymbolInfo("!" + $2->get_name_str(), INT_TYPE);

        string production = "unary_expression : NOT unary_expression";
        write_log(production, $$);

        delete $2;
    }
    | factor {
        $$ = new SymbolInfo($1->get_name_str(), $1->get_type_str());

        string production = "unary_expression : factor";
        write_log(production, $$);

        delete $1;
    }
    ;

factor:
    variable {
        $$ = new SymbolInfo($1->get_name_str(), $1->get_type_str());

        string production = "factor : variable";
        write_log(production, $$);

        delete $1;
    }
    | ID LPAREN argument_list RPAREN {
        string func_name = $1->get_name_str();
        SymbolInfo* func_sym_ptr = symbol_table.lookup(func_name);
        string return_type = VOID_TYPE;
        vector<string> param_types = {};

        if (func_sym_ptr == nullptr) {
            write_error_log(func_name + " does not exist and cannot be called");
        } else if (func_sym_ptr->get_func_types().size() == 0) {
            write_error_log(func_name + " is not callable");
        } else {
            return_type = func_sym_ptr->get_func_types()[0];
            param_types = func_sym_ptr->get_func_types();
            param_types = vector<string>(param_types.begin()+1, param_types.end());

            vector<string> arg_types = split($3->get_type_str());

            if (param_types != arg_types) {
                write_error_log(func_name + " expects " + to_string(param_types.size()) + 
                    " arguments, but got " + to_string(arg_types.size()));
            }
        }


        $$ = new SymbolInfo($1->get_name_str() + "(" + $3->get_name_str() + ")", return_type);

        string production = "factor : ID LPAREN argument_list RPAREN";
        write_log(production, $$);

        delete $1, $3;
    }
    | LPAREN expression RPAREN {
        $$ = new SymbolInfo("(" + $2->get_name_str() + ")", $2->get_type_str());

        string production = "factor : LPAREN expression RPAREN";
        write_log(production, $$);

        delete $2;
    }
    | CONST_INT {
        $$ = new SymbolInfo($1->get_name_str(), INT_TYPE);

        string production = "factor : CONST_INT";
        write_log(production, $$);

        delete $1;
    }
    | CONST_FLOAT {
        $$ = new SymbolInfo($1->get_name_str(), FLOAT_TYPE);

        string production = "factor : CONST_FLOAT";
        write_log(production, $$);

        delete $1;
    }
    | variable INCOP {
        $$ = new SymbolInfo($1->get_name_str() + "++", $1->get_type_str());

        string production = "factor : variable INCOP";
        write_log(production, $$);

        delete $1;
    }
    | variable DECOP {
        $$ = new SymbolInfo($1->get_name_str() + "--", $1->get_type_str());

        string production = "factor : variable DECOP";
        write_log(production, $$);

        delete $1;
    }
    ;

argument_list:
    arguments {
        $$ = new SymbolInfo($1->get_name_str(), $1->get_type_str());

        string production = "argument_list : arguments";
        write_log(production, $$);

        delete $1;
    }
    | %empty {
        $$ = new SymbolInfo("", "");

        string production = "argument_list : ";
        write_log(production, $$);
    }
    ;

arguments:
    arguments COMMA logic_expression {
        $$ = new SymbolInfo($1->get_name_str() + "," + $3->get_name_str(), 
            $1->get_type_str() + " " + $3->get_type_str());

        string production = "arguments : arguments COMMA logic_expression";
        write_log(production, $$);

        delete $1, $3;
    }
    | logic_expression {
        $$ = new SymbolInfo($1->get_name_str(), $1->get_type_str());

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

bool insert_into_symtable(string sym_type, string sym_name, vector<string> func_types) {
    if (!symbol_table.insert(sym_name, sym_type, func_types)) {
        write_error_log("[REDEF] Symbol name " + sym_name  + " already exists");
        return false;
    }
    return true;
}

bool insert_var_list_into_symtable(string var_type, vector<string> var_names) {
    bool is_all_success = true;
    for (string var_name : var_names) {
        if (var_name.find("[") < var_name.length()) {
            var_name = var_name.substr(0, var_name.find("["));
            if (var_type == INT_TYPE) {
                is_all_success = is_all_success && insert_into_symtable(INT_ARRAY_TYPE, var_name);
            } else if (var_type == FLOAT_TYPE) {
                is_all_success = is_all_success && insert_into_symtable(FLOAT_ARRAY_TYPE, var_name);
            }
        } else {
            is_all_success = is_all_success && insert_into_symtable(var_type, var_name);
        }
    }
    return is_all_success;
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