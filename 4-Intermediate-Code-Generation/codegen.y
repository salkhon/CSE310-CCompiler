%{
    #include <iostream>
    #include <cstdlib>
    #include <cstring>
    #include <cmath>
    #include <string>
    #include <sstream>
    #include <vector>
    #include <algorithm>
    #include <stack>
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

    // number of label-requiring-statements encountered
    int label_count = 0;
    // depth of nested label-requiring-statements
    int label_depth = 0;

    const string FOR_LOOP_CONDITION_LABEL = "FOR_LOOP_CONDITION_";
    const string FOR_LOOP_INCREMENT_LABEL = "FOR_LOOP_INCREMENT_";
    const string FOR_LOOP_BODY_LABEL = "FOR_LOOP_BODY_";
    const string FOR_LOOP_END_LABEL = "FOR_LOOP_END_";
    const string WHILE_LOOP_CONDITION_LABEL = "WHILE_LOOP_CONDITION_";
    const string WHILE_LOOP_BODY_LABEL = "WHILE_LOOP_BODY_";
    const string WHILE_LOOP_END_LABEL = "WHILE_LOOP_END_";
    const string IF_BODY_LABEL = "IF_BODY_";
    const string IF_BODY_END_LABEL = "IF_BODY_END_";
    const string ELSE_BODY_LABEL = "ELSE_BODY_";
    const string ELSE_BODY_END_LABEL = "ELSE_BODY_END_";

    const string IF_CONDITION_TEMP_NAME = "_if_temp"; // name will start with number to avoid collision with ID

    vector<string> split(string, char = ' ');
    string _get_var_ref(SymbolInfo*);
    void _alloc_int_var(string);
    void _alloc_int_array(string, int);
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
    // int will be used to keep track of labeled statements' opening and closing label in between nested statements
    int int_val;
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
    arguments func_declaration func_signature if_condition

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

/**
    function call needs to push base pointer, and pop and set base pointer on return. 
    Doing this on stack enables recursive calls. 
    current_stack_pointer needn't be modified, because that's only relevant for code generation.
**/
func_definition:
    func_signature LCURL {
        insert_into_symtable(current_func_sym_ptr); // since we're not inserting in func def, no collision

        // symbol table insertions of parameters in new scope, var names are not available in calling sequence
        current_stack_offset = 0;
        symbol_table.enter_scope();
        for (SymbolInfo* param_symbol : params_for_func_scope) {
            // base pointer is reset on on every call, so identifying local vars based on offset works
            param_symbol->get_codegen_info_ptr()->set_stack_offset(current_stack_offset++);
            insert_into_symtable(param_symbol);
        }
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
        // no conflict with func_def because closure includes compound statement only after encountering statement non terminal.
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
        // allocation done for each variable on declaration_list
        $$ = nullptr;
    }
    ;
type_specifier:
    INT {
        // necessary for instantiating current_func_sym_ptr in func_signature
        $$ = new SymbolInfo(INT_TYPE, INT_TYPE);
    }
    | VOID {
        $$ = new SymbolInfo(VOID_TYPE, VOID_TYPE);
    }
    ;

declaration_list:
    declaration_list COMMA ID {
        _alloc_int_var($3->get_symbol());
        $$ = nullptr;
    }
    | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
        _alloc_int_array($3->get_symbol(), stoi($5->get_symbol()));
        $$ = nullptr;
    }
    | ID {
        _alloc_int_var($1->get_symbol());
        $$ = nullptr;
    }
    | ID LTHIRD CONST_INT RTHIRD {
        _alloc_int_array($1->get_symbol(), stoi($3->get_symbol()));
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
        $$ = nullptr;
    }
    | expression_statement {
        $$ = nullptr;
    }
    | compound_statement {
        $$ = nullptr;
    }
    | FOR LPAREN expression_statement {
        // expression code written, value stored on AX (assignment mostly)
        // need label to comeback to following condition checking expression
        string code = FOR_LOOP_CONDITION_LABEL + to_string(label_count) + ":";
        // $$ will be used as a statement ID, so we can label corresponding opening and closing labels with same id
        write_code(code, label_depth);

        $<int_val>$ = label_count; 
    } expression_statement {
        // conditional statement value in AX, code written
        string current_for_id = to_string($<int_val>4);
        string for_loop_body_label = FOR_LOOP_BODY_LABEL + current_for_id;
        string for_loop_end_label = FOR_LOOP_END_LABEL + current_for_id;
        string for_loop_increment_label = FOR_LOOP_INCREMENT_LABEL + current_for_id;
        vector<string> code{
            "CMP AX, 0", 
            "JNE " + for_loop_body_label, 
            "JMP " + for_loop_end_label,
            for_loop_increment_label + ":"
        };
        write_code(code, label_depth);

        $<int_val>$ = $<int_val>4;
    } expression RPAREN {
        // expression val in AX, mostly assignment
        string current_for_id = to_string($<int_val>6);
        string for_loop_condition_label = FOR_LOOP_CONDITION_LABEL + current_for_id;
        string for_loop_body_label = FOR_LOOP_BODY_LABEL + current_for_id;
        vector<string> code{
            "JMP " + for_loop_condition_label,
            for_loop_body_label + ":"
        };
        label_count++;
        write_code(code, label_depth++);

        $<int_val>$ = $<int_val>6;
    } statement {
        // all statement codes are writted, including nested loops, need to pop label stack
        string current_for_id = to_string($<int_val>9);
        string for_loop_increment_label = FOR_LOOP_INCREMENT_LABEL + current_for_id;
        string for_loop_end_label = FOR_LOOP_END_LABEL + current_for_id;
        vector<string> code{
            "JMP " + for_loop_increment_label, 
            for_loop_end_label + ":"
        };
        write_code(code, --label_depth);
    }
    | if_condition statement 
    %prec SHIFT_ELSE {
        string code = IF_BODY_END_LABEL + to_string($<int_val>1) + ":";
        write_code(code, --label_depth);
    } 
    | if_condition statement ELSE {
        string current_if_else_id = to_string($<int_val>1);
        string if_temp_name = current_if_else_id + IF_CONDITION_TEMP_NAME;
        string if_temp_ref = _get_var_ref(symbol_table.lookup(if_temp_name));
        string else_body_label = ELSE_BODY_LABEL + current_if_else_id;
        string else_body_end_label = ELSE_BODY_END_LABEL + current_if_else_id;
        vector<string> code{
            "CMP " + if_temp_ref + ", 0",
            "JE " + else_body_label, 
            "JMP " + else_body_end_label,
            else_body_label + ":"
        };
        write_code(code, label_depth-1);

        $<int_val>$ = $<int_val>1;
    } statement {
        string code = ELSE_BODY_END_LABEL + to_string($<int_val>4) + ":";
        write_code(code, --label_depth);
    }
    | WHILE LPAREN {
        string code = WHILE_LOOP_CONDITION_LABEL + to_string(label_count) + ":";
        write_code(code, label_depth);

        $<int_val>$ = label_count;
    } expression RPAREN {
        string current_while_id = to_string($<int_val>3);
        string while_loop_body_label = WHILE_LOOP_BODY_LABEL + current_while_id;
        string while_loop_end_label = WHILE_LOOP_END_LABEL + current_while_id;
        vector<string> code{
            "CMP AX, 0", 
            "JNE " + while_loop_body_label, 
            "JMP " + while_loop_end_label, 
            while_loop_body_label + ":"
        };
        label_count++;
        write_code(code, label_depth++);

        $<int_val>$ = $<int_val>3;
    } statement {
        string current_while_id = to_string($<int_val>6);
        string while_loop_condition_label = WHILE_LOOP_CONDITION_LABEL + current_while_id;
        string while_loop_end_label = WHILE_LOOP_END_LABEL + current_while_id;
        vector<string> code{
            "JMP " + while_loop_condition_label, 
            while_loop_end_label + ":"
        };
        write_code(code, --label_depth);
    }
    | PRINTLN LPAREN variable RPAREN SEMICOLON {
    }
    | RETURN expression SEMICOLON {
    }
    ;

if_condition:
    IF LPAREN expression RPAREN {
        // expression value needs to be stored for ELSE to determine if it should execute, and it has to 
        // be done at run time, and can have nesting. So we allocate a temp variable in the symbol table. 
        string current_if_id = to_string(label_count);
        string if_temp_name = current_if_id + IF_CONDITION_TEMP_NAME;
        _alloc_int_var(if_temp_name);
        string var_asm_ref = _get_var_ref(symbol_table.lookup(if_temp_name)); 
        string if_body_label = IF_BODY_LABEL + current_if_id;
        string if_body_end_label = IF_BODY_END_LABEL + current_if_id;
        vector<string> code{
            "MOV " + var_asm_ref + ", AX", 
            "CMP AX, 0", 
            "JNE " + if_body_label, 
            "JMP " + if_body_end_label, 
            if_body_label + ":"
        };
        write_code(code, label_depth++);

        $<int_val>$ = label_count++;
    }

expression_statement:
    SEMICOLON {
        $$ = nullptr;
    }
    | expression SEMICOLON {
        $$ = nullptr;
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
        // expression value on AX, since its an index, move it to SI
        string code = "MOV SI, AX";
        write_code(code, 1);
        $$ = new SymbolInfo(*$1); 
    }
    ;

expression:
    logic_expression {
        // expression value persists on AX
        $$ = nullptr;
    }
    | variable ASSIGNOP logic_expression {
        // variable can be an array, if so, index is in SI.
        SymbolInfo* var_sym_ptr = symbol_table.lookup($1->get_symbol());
        string var_ref = _get_var_ref(var_sym_ptr);
        string code = "MOV " + var_ref + ", AX";
        write_code(code, 1);
        // asigned value persists on AX, which is the value of the expression
        $$ = nullptr;
    }
    ;

logic_expression:
    rel_expression {
        // expression value persists on AX
        $$ = nullptr;
    }
    | rel_expression {
        // make expression value persist
        string code = "MOV BX, AX";
        write_code(code, 1);
    } LOGICOP rel_expression {
        string code;
        if ($3->get_symbol() == "&&") {
            code = "AND AX, BX";
        } else if ($3->get_symbol() == "||") {
            code = "OR AX, BX";
        }
        write_code(code, 1);
    }
    ;

rel_expression:
    simple_expression {
        // expression value persists on AX
        $$ = nullptr;
    }
    | simple_expression {
        // make expression value persist
        string code = "MOV BX, AX";
        write_code(code, 1);
    } RELOP simple_expression {
        // second expression value in AX
        string relop = $3->get_symbol();
        vector<string> code = {"CMP BX, AX", "MOV AX, 0"};

        if (relop == "<") {
            code.push_back("SETG AL");
        } else if (relop == "<=") {
            code.push_back("SETGE AL");
        } else if (relop == ">") {
            code.push_back("SETL AL");
        } else if (relop == ">=") {
            code.push_back("SETLE AL");
        } else if (relop == "==") {
            code.push_back("SETE AL");
        } else if (relop == "!=") {
            code.push_back("SETNE AL");
        }

        $$ = nullptr;
    }
    ;

simple_expression:
    term {
        // value in AX persists
        $$ = nullptr;
    }
    | simple_expression {
        string code = "MOV BX, AX";
        write_code(code, 1);
        $<syminfo_ptr>$ = nullptr;
    } ADDOP term {
        string addop = $4->get_symbol();
        vector<string> code;
        if (addop == "+") {
            code.push_back("ADD AX, BX");
        } else if (addop == "-") {
            code.push_back("SUB BX, AX");
            code.push_back("MOV AX, BX");
        }
        write_code(code, 1);

        $$ = nullptr;
    }
    ;

term:
    unary_expression {
        // expression value persists on AX
        $$ = nullptr;
    }
    | term {
        string code = "MOV BX, AX";
        write_code(code, 1);
        $<syminfo_ptr>$ = nullptr;
    } MULOP unary_expression {
        string mulop = $3->get_symbol();
        vector<string> code = {
            "XOR AX, BX", 
            "XOR BX, AX", 
            "XOR AX, BX"
        }; // getting the MULOP order right

        if (mulop == "*") {
            code.push_back("IMUL BX"); // result in DX:AX, we'll take AX
        } else if (mulop == "/") {
            code.push_back("MOV DX, 0");
            code.push_back("IDIV BX"); // AX quo, DX rem
        } else if (mulop == "%") {
            code.push_back("MOV DX, 0");
            code.push_back("IDIV BX");
            code.push_back("MOV AX, DX");
        }
        write_code(code, 1);

        $$ = nullptr;
    }
    ;

unary_expression:
    ADDOP unary_expression 
    %prec UNARY {
        // expression value on AX persists.
        $$ = nullptr;
    }
    | NOT unary_expression {
        vector<string> code = {
            "CMP AX, 0",
            "MOV AX, 0", 
            "SETE AL"
        };
        write_code(code, 1);
        $$ = nullptr;
    }
    | factor {
        // expression value on AX persists.
        $$ = nullptr;
    }
    ;

factor:
    variable {
        // when variable reduces to factor, it's symbol table info is no longer needed, just the value on AX. 
        SymbolInfo* var_sym_ptr = symbol_table.lookup($1->get_symbol());
        string var_ref = _get_var_ref(var_sym_ptr);
        string code = "MOV AX, " + var_ref;
        write_code(code, 1);
        $$ = nullptr;
    }
    | ID LPAREN argument_list RPAREN {
        // TODO: calling sequence, put result on AX
    }
    | LPAREN expression RPAREN {
        // expression value in AX persists. 
        $$ = nullptr;
    }
    | CONST_INT {
        string code = "MOV AX, " + $1->get_symbol();
        write_code(code, 1);
        $$ = nullptr;
    }
    | variable INCOP {
        SymbolInfo* var_sym_ptr = symbol_table.lookup($1->get_symbol());
        string var_ref = _get_var_ref(var_sym_ptr);
        vector<string> code = {
            "MOV AX, " + var_ref, 
            "INC " + var_ref
        };
        write_code(code, 1);
        $$ = nullptr;
    }
    | variable DECOP {
        SymbolInfo* var_sym_ptr = symbol_table.lookup($1->get_symbol());
        string var_ref = _get_var_ref(var_sym_ptr);
        vector<string> code = {
            "MOV AX, " + var_ref, 
            "DEC " + var_ref
        };
        write_code(code, 1);
        $$ = nullptr;
    }
    ;

argument_list:
    arguments {
        $$ = nullptr;
    }
    | %empty {
        $$ = nullptr;
    }
    ;

arguments:
    arguments COMMA logic_expression {
        // TODO: push on stack here, expression value on AX
        string code = "PUSH AX";
    }
    | logic_expression {
        string code = "PUSH AX";
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

/**
    Resolves the identifier of a variable in assembly, based on if it's local or global and if it's an array or 
    not. 
    @param var_sym_ptr Pointer to the SymbolInfo of the variable whose identifier needs to be resolved.
    @return string Identifier that can be included in assembly code
**/
string _get_var_ref(SymbolInfo* var_sym_ptr) {
    string var_type = var_sym_ptr->get_semantic_type();
    CodeGenInfo* var_cgi_ptr = var_sym_ptr->get_codegen_info_ptr();
    string var_ref;
    if (var_cgi_ptr->is_local()) {
        var_ref = "BP+" + var_cgi_ptr->get_stack_offset();
        if (var_type == INT_ARRAY_TYPE) {
            var_ref += "+SI"; // array index in SI from expression
        }
        var_ref = "[" + var_ref + "]";
    } else {
        var_ref = var_sym_ptr->get_symbol();
        if (var_type == INT_ARRAY_TYPE) {
            var_ref += "[SI]"; // array indec in SI from expression
        }
    }
    return var_ref;
}

/**
    Writes allocation asm code of int variable into code_file based on if the variable is a local or global. 
    Also inserts new symbol for the allocated variable in the symbol table.
    @param var_name name of the variable to be allocated  
**/
void _alloc_int_var(string var_name) {
    SymbolInfo* var_sym_ptr = new SymbolInfo(var_name, "ID", INT_TYPE); // can do this because that's the only type

    if (current_func_sym_ptr == nullptr) {
        // global
        string code = var_name + " DW 0";
        // write data segment code at the end
        globals.push_back(new SymbolInfo(*var_sym_ptr)); // .clear() calls delete
    } else {
        // local
        string code = "PUSH 0";
        CodeGenInfo* cgi_ptr = var_sym_ptr->get_codegen_info_ptr();
        cgi_ptr->set_stack_offset(current_stack_offset++);
        write_code(code, 1);
    }

    insert_into_symtable(var_sym_ptr);
    delete var_sym_ptr;
}

/**
    Writes allocation asm code of int array into code_file based on if the array is a local or global. 
    Also inserts new symbol for the allocated array in the symbol table.
    @param arr_name name of the array to be allocated  
    @param arr_size size of the array
**/
void _alloc_int_array(string arr_name, int arr_size) {
    string arr_sz_str = to_string(arr_size);
    SymbolInfo* arr_sym_ptr = new SymbolInfo(arr_name, "ID", INT_ARRAY_TYPE, { arr_sz_str });

    if (current_func_sym_ptr == nullptr) {
        // global
        string code = arr_name + " DW " + arr_sz_str + " DUP(0)";
        globals.push_back(new SymbolInfo(*arr_sym_ptr));
    } else {
        // local
        vector<string> code(arr_size, "PUSH 0");
        arr_sym_ptr->get_codegen_info_ptr()->set_stack_offset(current_stack_offset);
        current_stack_offset += arr_size;
        write_code(code, 1);
    }

    insert_into_symtable(arr_sym_ptr);
    delete arr_sym_ptr;
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