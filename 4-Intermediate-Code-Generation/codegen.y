%{
    #include <iostream>
    #include <cstdlib>
    #include <cstring>
    #include <cmath>
    #include <string>
    #include <sstream>
    #include <vector>
    #include <algorithm>
    #include "./symbol-table/include.hpp"

    using namespace std;

    extern FILE* yyin;
    extern int line_count;

    int yyparse();
    int yylex();
    extern int yyerror(char*);

    FILE* input_file,* code_file,* optim_code_file;

    const int SYM_TABLE_BUCKETS = 10;
    SymbolTable symbol_table(SYM_TABLE_BUCKETS);

    const string INT_TYPE = "int";
    const string INT_ARRAY_TYPE = "int_arr";
    const string FLOAT_TYPE = "float";
    const string FLOAT_ARRAY_TYPE = "float_arr";
    const string VOID_TYPE = "void";

    SymbolInfo* current_func_sym_ptr;
    vector<SymbolInfo*> params_for_func_scope;

    vector<string> split(string, char = ' ');
    bool is_sym_func(SymbolInfo*);
    bool is_func_sym_defined(SymbolInfo*);
    bool is_func_signatures_match(SymbolInfo*, SymbolInfo*);
    string vec_to_str(vector<string>);
    bool insert_into_symtable(string, string, string, vector<string> = {});
    bool insert_into_symtable(SymbolInfo*);
    bool insert_var_list_into_symtable(string, vector<string>);
    void write_error_log(string, string="ERROR") {}
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

%type<syminfo_ptr>
    start program unit var_declaration func_definition type_specifier parameter_list
    compound_statement statements declaration_list statement expression_statement expression
    variable logic_expression rel_expression simple_expression term unary_expression factor argument_list
    arguments func_declaration func_signature compound_statement_start

%destructor {
    delete $$;
} <syminfo_ptr>

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
        YYACCEPT;
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

/**
    A -> B {} C {}
    Midrule semantic actions are rewritten as:
    T -> B {}
    A -> T C {}
    Which means the action code of B {} will execute before C {} is executed. It simulates inheritted attribute
    semantic actions. Practically it just breaks the production into two separate productions. 
**/
func_declaration: 
    func_signature SEMICOLON {
    }
    ;

func_definition:
    func_signature compound_statement {
    }
    ;

func_signature:
    type_specifier ID LPAREN parameter_list RPAREN {
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
    | %empty {
        // empty param list will be added VOID_TYPE in function_signture
        $$ = new SymbolInfo("", "parameter_list", VOID_TYPE);
    }
    ;

compound_statement:
    compound_statement_start statements RCURL {
    }
    | compound_statement_start RCURL {
    }
    ;

compound_statement_start:
    LCURL {
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
    | declaration_list error COMMA ID {
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
    | PRINTLN LPAREN variable RPAREN SEMICOLON {
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
    ADDOP unary_expression 
    %prec UNARY {
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
    | %empty {
    }
    ;

arguments:
    arguments COMMA logic_expression {
    }
    | logic_expression {
    }
    ;

%%

vector<string> split(string str, char delim) {
    stringstream sstrm(str);
    string split_str;
    vector<string> split_strs;

    while (getline(sstrm, split_str, delim)) {
        split_strs.push_back(split_str);    
    }

    return split_strs; 
}

bool is_sym_func(SymbolInfo* syminfo) {
    return !syminfo->get_all_data().empty();
}

bool is_func_sym_defined(SymbolInfo* syminfo) {
    return syminfo->get_all_data()[syminfo->get_all_data().size()-1] == "defined";
}

bool is_func_signatures_match(SymbolInfo* func_sym_ptr1, SymbolInfo* func_sym_ptr2) {
    vector<string> param_type_list1 = func_sym_ptr1->get_all_data();
    vector<string> param_type_list2 = func_sym_ptr2->get_all_data();
    if (param_type_list1[param_type_list1.size()-1] == "defined") {
        param_type_list1 = vector<string>(param_type_list1.begin(), param_type_list1.end()-1);
    }
    if (param_type_list2[param_type_list2.size()-1] == "defined") {
        param_type_list2 = vector<string>(param_type_list2.begin(), param_type_list2.end()-1);
    }

    return func_sym_ptr1->get_symbol() == func_sym_ptr2->get_symbol() && 
        func_sym_ptr1->get_semantic_type() == func_sym_ptr2->get_semantic_type() &&
        param_type_list1 == param_type_list2;
}

string vec_to_str(vector<string> strings) {
    stringstream ss;
    for (string str : strings) {
        ss << str << " ";
    }
    return ss.str();
}

bool insert_into_symtable(string symbol, string token_type, string semantic_type, vector<string> data) {
    if (!symbol_table.insert(symbol, token_type, semantic_type, data)) {
        write_error_log("Symbol name " + symbol + " already exists");
        return false;
    }
    return true;
}

bool insert_into_symtable(SymbolInfo* syminfo) {
    return insert_into_symtable(syminfo->get_symbol(), syminfo->get_token_type(), syminfo->get_semantic_type(), 
        syminfo->get_all_data());
}

bool insert_var_list_into_symtable(string var_type, vector<string> var_names) {
    bool is_all_success = true;
    for (string var_name : var_names) {
        if (var_name.find("[") < var_name.length()) {
            // variable is array
            var_name = var_name.substr(0, var_name.find("["));
            if (var_type == INT_TYPE) {
                is_all_success = is_all_success && insert_into_symtable(var_name, "ID", INT_ARRAY_TYPE);
            } else if (var_type == FLOAT_TYPE) {
                is_all_success = is_all_success && insert_into_symtable(var_name, "ID", FLOAT_ARRAY_TYPE);
            }
        } else {
            is_all_success = is_all_success && insert_into_symtable(var_name, "ID", var_type);
        }
    }
    return is_all_success;
}

bool is_file_empty(FILE* file) {
    char c;
    for (c = fgetc(file); c != EOF && c != ' ' && c != '\t' && c != '\n'; c = fgetc(file)) {
    }
    return c == EOF;
}

int main(int argc, char* argv[]) {
    if (argc != 2) {
        cout << "ERROR: Code generator needs input file as argument\n";
        return 1;
    }

    FILE* error_file = fopen("error.txt", "r");
    if (!is_file_empty(error_file)) {
        cout << "Copmilation failed. Check error.txt for errors in your code\n";
        return 0; 
    }

    input_file = fopen(argv[1], "r");
    code_file = fopen("code.asm", "w");
    optim_code_file = fopen("optimized_code.asm", "w");

    if (!input_file || !code_file || !optim_code_file) {
        cout << "ERROR: Could not open file\n";
        return 1;
    }

    yyin = input_file;

    yyparse();

    fclose(input_file);
    fclose(code_file);
    fclose(optim_code_file);

    return 0;
}