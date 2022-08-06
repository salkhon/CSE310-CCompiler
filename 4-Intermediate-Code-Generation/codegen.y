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
    const string VOID_TYPE = "void";

    vector<SymbolInfo*> globals;

    SymbolInfo* current_func_sym_ptr;
    vector<SymbolInfo*> params_for_func_scope;
    int current_stack_offset;

    vector<string> split(string, char = ' ');
    bool is_sym_func(SymbolInfo*);
    bool is_func_sym_defined(SymbolInfo*);
    bool is_func_signatures_match(SymbolInfo*, SymbolInfo*);
    string vec_to_str(vector<string>);
    bool insert_into_symtable(string, string, string, vector<string> = {});
    bool insert_into_symtable(SymbolInfo*);
    bool insert_var_list_into_symtable(vector<string>);
    void write_code(string, int=0);
    void write_code(vector<string>, int=0);
%}

%union {
    SymbolInfo* syminfo_ptr;
}

%token
    LPAREN RPAREN SEMICOLON COMMA LCURL RCURL INT VOID LTHIRD RTHIRD FOR IF ELSE WHILE
    PRINTLN RETURN ASSIGNOP NOT INCOP DECOP

%token<syminfo_ptr>
    ID CONST_INT LOGICOP RELOP ADDOP MULOP

%type<syminfo_ptr>
    start program unit var_declaration func_definition type_specifier parameter_list
    compound_statement statements declaration_list statement expression_statement expression
    variable logic_expression rel_expression simple_expression term unary_expression factor argument_list
    arguments func_declaration func_signature

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

 // ELSE has higher precedence than dummy token SHIFT_ELSE (telling to shift ELSE, rather than reduce lone if)
%nonassoc SHIFT_ELSE
%nonassoc ELSE

%%

start: 
    program {
        // write globals in data segment
        write_code(".DATA");
        for (SymbolInfo* syminfo_ptr : globals) {
            write_code(syminfo_ptr->get_codegen_info_ptr()->get_all_code()[0]);
        }
        globals.clear();
        YYACCEPT;
    }
    ;

program: 
    program unit {
        $$ = nullptr;
    }   
    | unit {
        $$ = nullptr;
    }
    ;

unit:
    var_declaration {
        $$ = nullptr;
    }
    | func_declaration {
        $$ = nullptr;
    }
    | func_definition {
        write_code("");
        $$ = nullptr;
    }
    ;

/**
    A -> B {} C {}
    Midrule semantic actions are rewritten as:
    T -> %empty {}
    A -> B T C {}
    Which means the action code of T -> %empty {} will execute before A -> B T C {} is executed. 
    It simulates inheritted attribute semantic actions. 
    Practically it just breaks the production into two separate productions. 
**/

/**
    Func declarations are used for type analysis. But for code generation they are useless. Because in an error 
    free code, you can allocate function frame from the number of arguments. Plus their is only one type INT. 
    So args are PUSHed arg_size times. So no need to insert into symbol table. 
**/
func_declaration: 
    func_signature SEMICOLON {
        delete current_func_sym_ptr;
        current_func_sym_ptr = nullptr;
        params_for_func_scope.clear();

        $$ = $1;
    }
    ;

func_definition:
    func_signature LCURL {
        // we can safely write PROC here
        // CALLER will push old fp, set new fp to current sp, push old stack offset, reset stack offset, 
        // push return space, and param values. PROC just needs to reference them through current stack offset. 
        // so at this point, we know, fp points to frame start, current stack offset is incremented by return space, 
        // and all params. 
        insert_into_symtable(current_func_sym_ptr); // since we're not inserting in func def, no collision

        // symbol table insertions of parameters in new scope, var names are not available in calling sequence
        int offset = 1; // return space
        symbol_table.enter_scope();
        for (SymbolInfo* param_symbol : params_for_func_scope) {
            param_symbol->get_codegen_info_ptr()->set_stack_offset(offset++);
            insert_into_symtable(param_symbol);
        }
        current_stack_offset = offset; // useful when declaring local vars
        params_for_func_scope.clear();

        string func_name = current_func_sym_ptr->get_symbol();
        string code = func_name + " PROC";
        write_code(code);

        $<syminfo_ptr>$ = nullptr;
    } statements RCURL {
        delete current_func_sym_ptr;
        current_func_sym_ptr = nullptr;

        string code = "ENDP";
        write_code(code);
        
        $$ = nullptr;
    }
    ;

/**
    Symbol table insertion for declaration will be done on func_declaration. But to allow pre-declaration
    before definition, symbol table entry for definition will be done on compound statement start, 
    just so we don't re-insert a declared function, and cause an error. 
**/
func_signature:
    type_specifier ID LPAREN {
        string ret_type = $1->get_symbol();
        string func_name = $2->get_symbol();

        current_func_sym_ptr = new SymbolInfo(func_name, "ID", ret_type);

        $<syminfo_ptr>$ = nullptr;
    } parameter_list RPAREN {
        $$ = nullptr; 
    }
    ;

parameter_list:
    parameter_list COMMA type_specifier ID {
        string param_type = $3->get_symbol();
        string param_name = $4->get_symbol();
        current_func_sym_ptr->add_data(param_type);
        
        params_for_func_scope.push_back(new SymbolInfo(param_name, "ID", param_type)); // .clear() calls delete

        $$ = nullptr;
    }
    | parameter_list COMMA type_specifier {
        // func_definition are ignored
    }
    | type_specifier ID {
        string param_type = $1->get_symbol();
        string param_name = $2->get_symbol();
        current_func_sym_ptr->add_data(param_type);
        
        params_for_func_scope.push_back(new SymbolInfo(param_name, "ID", param_type));

        $$ = nullptr;
    }
    | type_specifier {
        // func_definition is ignored
    }
    | %empty {
        // empty param list will be added VOID_TYPE in function_signture
        current_func_sym_ptr->add_data(VOID_TYPE);

        $$ = nullptr;
    }
    ;

compound_statement:
    LCURL {
        // this is nested scope
        symbol_table.enter_scope();
    } statements RCURL {
        symbol_table.exit_scope();
    }
    | LCURL RCURL {
    }
    ;

/**
    LCURL can mean 2 things. Start of a function, or a nested scope. If it's a functions, current_func_sym_ptr
    will have function signature. If so, write PROC code. 
    If it's just a nested scope, no new frame. Means no new stack ptr. We can use the old stack offset. Just create
    new scope to refer to actual variables with proper offset. And the ability to declare same named variables as
    the outer scope. 
**/

var_declaration:
    type_specifier declaration_list SEMICOLON {
        // type is int for our language. The only distinction is make is int vs int[]
    }
    ;
type_specifier:
    INT {
    }
    | VOID {
    }
    ;

declaration_list:
    declaration_list COMMA ID {
        $3->set_semantic_type(INT_TYPE); // can do this because that's the only type
        string var_name = $3->get_symbol();

        if (current_func_sym_ptr == nullptr) {
            // global
            string code = var_name + " DW 0";
            // write data segment code at the end
            globals.push_back(new SymbolInfo(*$3)); // .clear() calls delete
        } else {
            // local
            string code = "PUSH 0";
            CodeGenInfo* codegeninfoptr = $3->get_codegen_info_ptr();
            codegeninfoptr->set_stack_offset(current_stack_offset++);
            write_code(code);
        }

        insert_into_symtable($3);
        $$ = nullptr;
    }
    | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
        $3->set_semantic_type(INT_ARRAY_TYPE);
        string var_name = $3->get_symbol();
        string size = $5->get_symbol();

        if (current_func_sym_ptr == nullptr) {
            // global
            string code = var_name + " DW " + size + " DUP(0)";
            $1->add_data(size); // storing array size on symbol data[]
            globals.push_back($3);
        } else {
            // local
            int size_int = stoi(size);
            vector<string> code(size_int, "PUSH 0");
            $3->get_codegen_info_ptr()->set_stack_offset(current_stack_offset);
            current_stack_offset += size_int;
            write_code(code);
        }

        insert_into_symtable($3);
        $$ = nullptr;

    }
    | ID {
        $1->set_semantic_type(INT_TYPE); // can do this because that's the only type
        string var_name = $1->get_symbol();

        if (current_func_sym_ptr == nullptr) {
            // global
            string code = var_name + " DW 0";
            globals.push_back(new SymbolInfo(*$1)); // .clear() calls delete
        } else {
            // local
            string code = "PUSH 0";
            CodeGenInfo* codegeninfoptr = $1->get_codegen_info_ptr();
            codegeninfoptr->set_stack_offset(current_stack_offset++);
            write_code(code);
        }

        insert_into_symtable($1);
        $$ = nullptr;
    }
    | ID LTHIRD CONST_INT RTHIRD {
        $1->set_semantic_type(INT_ARRAY_TYPE);
        string var_name = $1->get_symbol();
        string size = $3->get_symbol();

        if (current_func_sym_ptr == nullptr) {
            // global
            string code = var_name + " DW " + size + " DUP(0)";
            $1->add_data(size); // storing array size on symbol data[]
            globals.push_back($1);
        } else {
            // local
            int size_int = stoi(size);
            vector<string> code(size_int, "PUSH 0");
            $1->get_codegen_info_ptr()->set_stack_offset(current_stack_offset);
            current_stack_offset += size_int;
            write_code(code);
        }

        insert_into_symtable($1);
        $$ = nullptr;
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

/**
    variable can be global or local. Global is stored by name, can be called in x86 by name. Local has to 
    be popped from the stack. So the stack offset would be it's identifier. 
    If its local, put stack offset in x86, if its global put name in x86. 
**/
/**
    expression value cannot be evaluated in compile time.
    expression code needs to store result in AX. Since we know the latest expression value is in AX, 
    if we need to store 2 expressions, we can just add a midrule code in the earlier expression to store 
    the AX val to BX. 
    If you find variable from symbol table is an array, you can find it's index expression at AX. 
**/
variable:
    ID {
        // can be l value or r value - so not resolving now, just inheritting symbol name to find in sym table.
        $$ = $1;
    }
    | ID LTHIRD expression RTHIRD {
        vector<string> expression_code = $3->get_codegen_info_ptr()->get_all_code();

        SymbolInfo* var_symptr = symbol_table.lookup($1->get_symbol());
        CodeGenInfo* var_cgi_ptr = var_symptr->get_codegen_info_ptr();

        vector<string> code{expression_code};
        code.push_back("MOV DI, AX");
        var_cgi_ptr->add_code(code);

        // passes index up, now upper context needs to use that index accordingly, as l-value or r-value
        $$ = new SymbolInfo(*var_symptr); 
    }
    ;

expression: // TODO: fix
    logic_expression {
    }
    | variable ASSIGNOP logic_expression {
        // l values of variable is needed. In that case $1 must have info about variable l val.
        CodeGenInfo* var_cgi_ptr = $1->get_codegen_info_ptr();
        vector<string> code;
        if (var_cgi_ptr->is_local()) {
            int stack_offset = var_cgi_ptr->get_stack_offset();
            code.push_back("MOV [BP+" + to_string(stack_offset) + "], AX");
        } else {
            string var_name = $1->get_symbol();
            code.push_back("MOV " + var_name + ", AX");
        }
        write_code(code);
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
        // epxression evaluation will be done accumulatively in AX
        SymbolInfo* var_syminfo_ptr = symbol_table.lookup($1->get_symbol());
        vector<string> code;
        if (var_syminfo_ptr->get_codegen_info_ptr()->is_local()) {
            code.push_back(string("MOV AX, [BP + ") + to_string(var_syminfo_ptr->get_codegen_info_ptr()->get_stack_offset())
                + "]");
        } else {
            code.push_back("MOV AX, " + var_syminfo_ptr->get_symbol());
        }
        write_code(code);
    }
    | ID LPAREN argument_list RPAREN {
    }
    | LPAREN expression RPAREN {
    }
    | CONST_INT {
        $$ = new SymbolInfo($1->get_symbol(), $1->get_token_type(), INT_TYPE);
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
        // push on stack here
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
    return symbol_table.insert(symbol, token_type, semantic_type, data);
}

bool insert_into_symtable(SymbolInfo* syminfo) {
    return symbol_table.insert_copy(syminfo);
}

bool insert_var_list_into_symtable(vector<string> var_names) {
    bool is_all_success = true;
    for (string var_name : var_names) {
        if (var_name.find("[") < var_name.length()) {
            // variable is array
            var_name = var_name.substr(0, var_name.find("["));
            is_all_success = is_all_success && insert_into_symtable(var_name, "ID", INT_ARRAY_TYPE);
        } else {
            is_all_success = is_all_success && insert_into_symtable(var_name, "ID", INT_TYPE);
        }
    }
    return is_all_success;
}

void write_code(string code, int indentation) {
    string indent = "";
    for (int i = 0; i < indentation; i++) {
        indent += "\t";
    }
    fprintf(code_file, "%s%s\n", indent, code.c_str());
}

void write_code(vector<string> code, int indentation) {
    for (string code_line : code) {
        write_code(code, indentation);
    }
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