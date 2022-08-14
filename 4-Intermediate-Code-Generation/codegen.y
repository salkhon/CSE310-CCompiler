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

    // only needed for code generation, referring to local variables with corresponding offset assigned
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

    enum Label {
        FOR_LOOP_CONDITION, FOR_LOOP_INCREMENT, FOR_LOOP_BODY, FOR_LOOP_END, WHILE_LOOP_CONDITION, 
        WHILE_LOOP_BODY, WHILE_LOOP_END, IF_BODY, ELSE_BODY, IF_ELSE_END
    };

    vector<string> split(string, char = ' ');
    string get_label(Label, int=-1);
    string _get_var_ref(SymbolInfo*);
    void _alloc_int_var(string);
    void _alloc_int_array(string, int);
    bool is_sym_func(SymbolInfo*);
    string vec_to_str(vector<string>);
    bool insert_into_symtable(string, string, string, vector<string> = {});
    bool insert_into_symtable(SymbolInfo*);
    void write_code(const string&, int=0);
    void write_code(const vector<string>&, int=0);
    bool is_file_empty(FILE*);
    void append_print_proc_def_to_codefile();
    void prepend_data_segment_to_codefile();
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

%type
    start code_segment program unit var_declaration func_declaration func_definition statements parameter_list
    declaration_list statement expression_statement expression compound_statement if_condition logic_expression
    rel_expression simple_expression term unary_expression factor arguments func_signature argument_list

%type<syminfo_ptr>
    type_specifier variable

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
    code_segment program {
        append_print_proc_def_to_codefile();
        prepend_data_segment_to_codefile();
        YYACCEPT;
    }
    ;

code_segment:
    %empty {
        vector<string> code{
            ".MODEL SMALL\n", 
            ".CODE\n"
        };
        write_code(code);
    }

program: 
    program unit {}   
    | unit {}
    ;

unit:
    var_declaration {}
    | func_declaration {}
    | func_definition {
        write_code("");
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
    So args are PUSHED arg_size times. So no need to insert function symbols into symbol table. 
**/
func_declaration: 
    func_signature SEMICOLON {
        delete current_func_sym_ptr;
        current_func_sym_ptr = nullptr;
        params_for_func_scope.clear();
    }
    ;

/**
    function call needs to push base pointer, and pop and set base pointer on return. 
    Doing this on stack enables recursive calls. 
    current_stack_pointer needn't be modified, because that's only relevant for code generation.
**/
func_definition:
    func_signature LCURL {
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
        func_name = func_name == "main" ? "MAIN" : func_name;
        string code = func_name + " PROC";
        write_code(code, label_depth++);
    } statements RCURL {
        delete current_func_sym_ptr;
        current_func_sym_ptr = nullptr;

        string code = "ENDP";
        write_code(code, --label_depth);
    }
    ;

func_signature:
    type_specifier ID LPAREN {
        string ret_type = $1->get_symbol();
        string func_name = $2->get_symbol();

        current_func_sym_ptr = new SymbolInfo(func_name, "ID", ret_type);
    } parameter_list RPAREN {}
    ;

parameter_list:
    parameter_list COMMA type_specifier ID {
        string param_type = $3->get_symbol();
        string param_name = $4->get_symbol();
        current_func_sym_ptr->add_data(param_type);
        
        params_for_func_scope.push_back(new SymbolInfo(param_name, "ID", param_type)); // .clear() calls delete
    }
    | parameter_list COMMA type_specifier {
        delete $3;
    }
    | type_specifier ID {
        string param_type = $1->get_symbol();
        string param_name = $2->get_symbol();
        current_func_sym_ptr->add_data(param_type);
        
        params_for_func_scope.push_back(new SymbolInfo(param_name, "ID", param_type));
    }
    | type_specifier {
        delete $1;
    }
    | %empty {
        // empty param list will be added VOID_TYPE in function_signture
        current_func_sym_ptr->add_data(VOID_TYPE);
    }
    ;

compound_statement:
    LCURL {
        // this is nested scope
        // no conflict with func_def because closure includes compound statement only after encountering statement non terminal.
        symbol_table.enter_scope();
    } statements RCURL {
        vector<string> code(symbol_table.get_current_scope_size(), "POP BX");
        symbol_table.exit_scope();
    }
    | LCURL RCURL {
    }
    ;

/**
    LCURL can mean 2 things. Start of a function, or a nested scope. If it's a functions, current_func_sym_ptr
    will have function signature. If so, write PROC code. 
    If it's just a nested scope, no new frame. Means no new base ptr. We can use the old stack offset. Just create
    new scope to refer to actual variables with proper offset. And the ability to declare same named variables as
    the outer scope. 
    To solve this, separate out nested scope and func_def in the grammar.
**/

var_declaration:
    type_specifier declaration_list SEMICOLON {
        delete $1;
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
    }
    | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
        _alloc_int_array($3->get_symbol(), stoi($5->get_symbol()));
    }
    | ID {
        _alloc_int_var($1->get_symbol());
    }
    | ID LTHIRD CONST_INT RTHIRD {
        _alloc_int_array($1->get_symbol(), stoi($3->get_symbol()));
    }
    ;

statements:
    statement {}
    | statements statement {}
    ;

/**
    Surprisingly, this if-else grammar automatically covers if-elseif ladder. Because if-elseif ladders
    can be broken down to nested if-else s.
        if (A) {

        } else if (B) {

        } else if (C) {

        } else {

        }
    To, 
        if (A) {

        } else {
            if (B) {

            } else {
                if (C) {

                } else {

                }
            }
        }
    If one of the if condition enters, no else-ifs enter. Amazing. 
**/
statement:
    var_declaration {}
    | expression_statement {}
    | compound_statement {}
    | FOR LPAREN expression_statement {
        // expression code written, value stored on AX (assignment mostly)
        // need label to comeback to following condition checking expression
        vector<string> code{
            "; FOR LOOP START", 
            get_label(FOR_LOOP_CONDITION) + ":"
        };
        // $S will be used as a label identifier, so we can label corresponding opening and closing labels with same id
        write_code(code, label_depth);

        $<int_val>$ = label_count - 1; 
    } expression_statement {
        // conditional statement value in AX, code written
        const int CURR_LABEL_ID = $<int_val>4;
        vector<string> code{
            "; FOR LOOP CONDITION CHECK",
            "CMP AX, 0", 
            "JNE " + get_label(FOR_LOOP_BODY, CURR_LABEL_ID), 
            "JMP " + get_label(FOR_LOOP_END, CURR_LABEL_ID),
            get_label(FOR_LOOP_INCREMENT, CURR_LABEL_ID) + ":"
        };
        write_code(code, label_depth);

        $<int_val>$ = $<int_val>4;
    } expression RPAREN {
        // expression val in AX, mostly assignment
        const int CURR_LABEL_ID = $<int_val>6;
        vector<string> code{
            "JMP " + get_label(FOR_LOOP_CONDITION, CURR_LABEL_ID),
            get_label(FOR_LOOP_BODY, CURR_LABEL_ID) + ":"
        };
        write_code(code, label_depth++);

        $<int_val>$ = $<int_val>6;
    } statement {
        const int CURR_LABEL_ID = $<int_val>9;
        vector<string> code{
            "JMP " + get_label(FOR_LOOP_INCREMENT, CURR_LABEL_ID), 
            get_label(FOR_LOOP_END, CURR_LABEL_ID) + ":"
        };
        write_code(code, --label_depth);
    }
    | if_condition statement 
    %prec SHIFT_ELSE {
        const int CURR_LABEL_ID = $<int_val>1;
        vector<string> code{
            get_label(ELSE_BODY, CURR_LABEL_ID) + ":", // if_condition always assumes if-else, so dummy else label
            get_label(IF_ELSE_END, CURR_LABEL_ID) + ":"
        };
        write_code(code, --label_depth);
    } 
    | if_condition statement ELSE {
        const int CURR_LABEL_ID = $<int_val>1;
        vector<string> code{
            "JMP " + get_label(IF_ELSE_END, CURR_LABEL_ID), // if body execution ends in jumping over else body
            get_label(ELSE_BODY, CURR_LABEL_ID) + ":"
        };
        write_code(code, label_depth-1);

        $<int_val>$ = $<int_val>1;
    } statement {
        const int CURR_LABEL_ID = $<int_val>4;
        string code = get_label(IF_ELSE_END, CURR_LABEL_ID) + ":";
        write_code(code, --label_depth);
    }
    | WHILE LPAREN {
        vector<string> code{
            "; WHILE LOOP START",
            get_label(WHILE_LOOP_CONDITION) + ":"
        };
        write_code(code, label_depth);

        $<int_val>$ = label_count - 1;
    } expression RPAREN {
        const int CURR_LABEL_ID = $<int_val>3;
        vector<string> code{
            "; WHILE LOOP CONDITION CHECK",
            "CMP AX, 0", 
            "JNE " + get_label(WHILE_LOOP_BODY, CURR_LABEL_ID), 
            "JMP " + get_label(WHILE_LOOP_END, CURR_LABEL_ID), 
            get_label(WHILE_LOOP_BODY, CURR_LABEL_ID) + ":"
        };
        write_code(code, label_depth++);

        $<int_val>$ = $<int_val>3;
    } statement {
        const int CURR_LABEL_ID = $<int_val>6;
        vector<string> code{
            "JMP " + get_label(WHILE_LOOP_CONDITION, CURR_LABEL_ID), 
            get_label(WHILE_LOOP_END, CURR_LABEL_ID) + ":"
        };
        write_code(code, --label_depth);
    }
    | PRINTLN LPAREN variable RPAREN SEMICOLON {
        SymbolInfo* var_sym = symbol_table.lookup($3->get_symbol());
        string var_ref = _get_var_ref(var_sym);
        vector<string> code{
            "; PRINT STATEMENT", 
            "MOV AX, " + var_ref, 
            "CALL PRINT_INT_IN_AX"
        };
        write_code(code, label_depth);
    }
    | RETURN expression SEMICOLON {
        // return expression already in AX, pop parameters and locals off stack.
        // everything on the current scope is a parameter or a local, just pop x sizeof currentscope
        vector<string> code(symbol_table.get_current_scope_size(), "POP BX");
        code.insert(code.begin(), "; ACTIVATION RECORD TEAR DOWN FOR FUNCTION " 
            + current_func_sym_ptr->get_symbol());
        code.push_back("RET");
        write_code(code, label_depth);
    }
    ;

if_condition:
    IF LPAREN expression RPAREN {
        // if_condition assumes if-else. If condition is false, jump to ELSE_BODY label, which will exist for
        // if without else as a dummy. 
        vector<string> code{
            "; IF STATEMENT START",
            "CMP AX, 0", 
            "JNE " + get_label(IF_BODY),
            "JMP " + get_label(ELSE_BODY, label_count-1),
        };
        write_code(code, label_depth++);

        $<int_val>$ = label_count - 1;
    }

expression_statement:
    SEMICOLON {}
    | expression SEMICOLON {}
    ;

/**
    variable can be global or local. Global is stored by name, can be called in x86 by name. Local has to 
    be popped from the stack. So the stack offset would be it's identifier. 
    If its local, put stack offset in x86, if its global put name in x86. 
**/
/**
    expression value cannot be evaluated in compile time.
    expression code needs to store result in AX. Since we know the latest expression value is in AX, 
    if we need to store 2 expressions, we can just add a midrule code in the earlier expression to push
    the AX val to stack.  
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
    logic_expression {}   
    | variable ASSIGNOP logic_expression {
        // variable can be an array, if so, index is in SI.
        SymbolInfo* var_sym_ptr = symbol_table.lookup($1->get_symbol());
        string var_ref = _get_var_ref(var_sym_ptr);
        string code = "MOV " + var_ref + ", AX";
        write_code(code, label_depth);
    }
    ;

logic_expression:
    rel_expression {}
    | rel_expression {
        // make expression value persist
        // AFTER EACH EXPRESSION part, STACK NEEDS TO BE AS IT WAS BEFORE. That way current_stack_offset needn't be changed
        string code = "PUSH AX";
        write_code(code, 1);
    } LOGICOP rel_expression {
        vector<string> code{
            "MOV BX, AX", 
            "POP AX"
        };
        if ($3->get_symbol() == "&&") {
            code.push_back("AND AX, BX");
        } else if ($3->get_symbol() == "||") {
            code.push_back("OR AX, BX");
        }
        write_code(code, label_depth);
    }
    ;

rel_expression:
    simple_expression {}
    | simple_expression {
        string code = "PUSH AX";
        write_code(code, label_depth);
    } RELOP simple_expression {
        string relop = $3->get_symbol();
        vector<string> code = {
            "MOV BX, AX", 
            "POP AX",
            "CMP AX, BX", 
            "MOV AX, 0"
        };

        if (relop == "<") {
            code.push_back("SETL AL");
        } else if (relop == "<=") {
            code.push_back("SETLE AL");
        } else if (relop == ">") {
            code.push_back("SETG AL");
        } else if (relop == ">=") {
            code.push_back("SETGE AL");
        } else if (relop == "==") {
            code.push_back("SETE AL");
        } else if (relop == "!=") {
            code.push_back("SETNE AL");
        }
        write_code(code, label_depth);
    }
    ;

simple_expression:
    term {}
    | simple_expression {
        string code = "PUSH AX";
        write_code(code, label_depth);
    } ADDOP term {
        string addop = $3->get_symbol();
        vector<string> code{
            "MOV BX, AX", 
            "POP AX"
        };

        if (addop == "+") {
            code.push_back("ADD AX, BX");
        } else if (addop == "-") {
            code.push_back("SUB AX, BX");
        }
        write_code(code, label_depth);
    }
    ;

term:
    unary_expression {}
    | term {
        string code = "PUSH AX";
        write_code(code, 1);
    } MULOP unary_expression {
        string mulop = $3->get_symbol();
        vector<string> code = {
            "MOV BX, AX", 
            "POP AX",
        }; 

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
    }
    ;

unary_expression:
    ADDOP unary_expression 
    %prec UNARY {
        string addop = $1->get_symbol();
        if (addop == "-") {
            string code = "NEG AX";
            write_code(code, label_depth);
        }
    }
    | NOT unary_expression {
        vector<string> code = {
            "CMP AX, 0",
            "MOV AX, 0", 
            "SETE AL"
        };
        write_code(code, 1);
    }
    | factor {}
    ;

factor:
    variable {
        // when variable reduces to factor, it's symbol table info is no longer needed, just the value on AX. 
        SymbolInfo* var_sym_ptr = symbol_table.lookup($1->get_symbol());
        string var_ref = _get_var_ref(var_sym_ptr);
        string code = "MOV AX, " + var_ref;
        write_code(code, label_depth);
    }
    | ID LPAREN {
        // the code for the procedure we are calling is independent, written with its own current_stack_offset, 
        // which we don't need
        string func_name = $1->get_symbol();
        vector<string> code{
            "; ACTIVATION RECORD SETUP FOR FUNCTION " + func_name,
            "PUSH BP", 
            "MOV BP, SP"
        };
        write_code(code, label_depth);
    } argument_list RPAREN {
        string func_name = $1->get_symbol();
        vector<string> code{
            "CALL " + func_name, 
            "POP BP", 
            "; EXECUTION COMPLETE FOR FUNCTION " + func_name
        };
        write_code(code, label_depth);
    }
    | LPAREN expression RPAREN {}
    | CONST_INT {
        string code = "MOV AX, " + $1->get_symbol();
        write_code(code, label_depth);
    }
    | variable INCOP {
        SymbolInfo* var_sym_ptr = symbol_table.lookup($1->get_symbol());
        string var_ref = _get_var_ref(var_sym_ptr);
        vector<string> code = {
            "MOV AX, " + var_ref, 
            "INC " + var_ref
        };
        write_code(code, label_depth);
    }
    | variable DECOP {
        SymbolInfo* var_sym_ptr = symbol_table.lookup($1->get_symbol());
        string var_ref = _get_var_ref(var_sym_ptr);
        vector<string> code = {
            "MOV AX, " + var_ref, 
            "DEC " + var_ref
        };
        write_code(code, label_depth);
    }
    ;

argument_list:
    arguments {}
    | %empty {}
    ;

arguments:
    arguments COMMA logic_expression {
        string code = "PUSH AX";
        write_code(code, label_depth);
    }
    | logic_expression {
        string code = "PUSH AX";
        write_code(code, label_depth);
    }
    ;

%%

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

/**
    utils
**/

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
    Generates label, with new id if label id is not provided or with provided id otherwise. 
    If new label is generated, global label_count is incremented. 

    @param Label Label type to generate
    @param label_id Label id to append after label name
    @return The label string with id appended
**/
string get_label(Label label, int label_id) {
    if (label_id < 0) {
        label_id = label_count++; // no label_id provided, generate new label_id
    }

    string label_str;
    switch(label) {
        case FOR_LOOP_CONDITION:
            label_str = "FOR_LOOP_CND_";
            break;
        case FOR_LOOP_INCREMENT:
            label_str = "FOR_LOOP_INC_";
            break;
        case FOR_LOOP_BODY:
            label_str = "FOR_LOOP_BODY_";
            break;
        case FOR_LOOP_END:
            label_str = "FOR_LOOP_END_";
            break;
        case WHILE_LOOP_CONDITION:
            label_str = "WHILE_LOOP_CND_";
            break;
        case WHILE_LOOP_BODY:
            label_str = "WHILE_LOOP_BODY_";
            break;
        case WHILE_LOOP_END:
            label_str = "WHILE_LOOP_END_";
            break;
        case IF_BODY:
            label_str = "IF_BODY_";
            break;
        case ELSE_BODY:
            label_str = "ELSE_BODY_";
            break;
        case IF_ELSE_END:
            label_str = "IF_ELSE_END_";
            break;
    }

    return label_str + to_string(label_id);
}

/**
    Resolves the identifier of a variable in assembly, based on if it's local or global and if it's an array or 
    not. 

    @param var_sym_ptr Pointer to the SymbolInfo of the variable from the symbol table whose identifier needs to be resolved.
    @return string Identifier that can be included in assembly code
**/
string _get_var_ref(SymbolInfo* var_sym_ptr) {
    string var_type = var_sym_ptr->get_semantic_type();
    CodeGenInfo* var_cgi_ptr = var_sym_ptr->get_codegen_info_ptr();
    string var_ref;
    if (var_cgi_ptr->is_local()) {
        var_ref = "BP+" + to_string(var_cgi_ptr->get_stack_offset());
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
        var_sym_ptr->get_codegen_info_ptr()->add_code(code);
        // write data segment code at the end
        globals.push_back(new SymbolInfo(*var_sym_ptr)); // .clear() calls delete
    } else {
        // local
        vector<string> code{
            "; INITIALIZING BASIC VARIABLE " + var_name + " at stack offset " + to_string(current_stack_offset), 
            "PUSH 0"
        };
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
        arr_sym_ptr->get_codegen_info_ptr()->add_code(code);
        globals.push_back(new SymbolInfo(*arr_sym_ptr));
    } else {
        // local
        vector<string> code(arr_size, "PUSH 0");
        code.insert(code.begin(), "; INTIALIZING ARRAY VARIABLE " + arr_name + "[" + arr_sz_str + "]" + 
            " at stack offset " + to_string(current_stack_offset));
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

void write_code(const string& code, int indentation) {
    string indent = "";
    for (int i = 0; i < indentation; i++) {
        indent += "\t";
    }
    fprintf(code_file, "%s%s\n", indent.c_str(), code.c_str());
    fflush(code_file); // normally does not flush if buffer is not full enough
}

void write_code(const vector<string>& code, int indentation) {
    for (string code_line : code) {
        write_code(code_line, indentation);
    }
}

bool is_file_empty(FILE* file) {
    char c;
    for (c = fgetc(file); c != EOF && c != ' ' && c != '\t' && c != '\n'; c = fgetc(file)) {
    }
    return c == EOF;
}

void prepend_data_segment_to_codefile() {
    write_code("\n.DATA");
    vector<string> code;
    for (SymbolInfo* global_sym_ptr : globals) {
        code.push_back(global_sym_ptr->get_codegen_info_ptr()->get_all_code()[0]);
    }
    write_code(code, 1);
    globals.clear();
}

void append_print_proc_def_to_codefile() {
    write_code("PRINT_INT_IN_AX PROC");
    // divide and push the remainder
    vector<string> code{
        "MOV CX, 0",
        "TEST AX, AX",
        "JNS POSITIVE_NUM",
        "MOV BX, 1",
        "NEG AX",
        "JMP OUTPUT_STACK_START",
        "POSITIVE_NUM:",
        "MOV BX, 0",
        "OUTPUT_STACK_START:",
        "INC CX",
        "PUSH CX",
        "MOV CX, 10",
        "MOV DX, 0",
        "DIV CX",
        "POP CX",
        "PUSH DX",
        "CMP AX, 0",
        "JNE OUTPUT_STACK_START",
        "CMP BX, 1",
        "JNE STACK_PRINT_LOOP",
        "MOV DX, -3",
        "PUSH DX",
        "INC CX",
        "STACK_PRINT_LOOP:",
        "POP DX",
        "ADD DL, '0'",
        "MOV AH, 2",
        "INT 21H", 
        "LOOP STACK_PRINT_LOOP",
        "RET"    
    };
    write_code(code, 1);
}

/**
    x86 assembly instructions: http://www.mathemainzel.info/files/x86asmref.html#idiv
    x86 assembly registers: https://www.eecg.utoronto.ca/~amza/www.mindsec.com/files/x86regs.html#:~:text=The%20main%20tools%20to%20write,the%20process%20faster%20and%20cleaner.
**/