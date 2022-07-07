%option noyywrap

%{
    #include <iostream>
    #include <sstream>
    #include <string>
    #include <cctype>
    #include <stdlib.h>
    #include <cstring>
    #include "./symbol-table/include.cpp"

    using namespace std;

    // counts
    int line_count = 1;
    int pending_line_inc = 0;
    int error_count = 0;

    // buffer
    string matched_literal;

    char matched_char;
    string matched_str;
    string matched_comment;

    // write files
    FILE* token_file;
    FILE* log_file;

    const int SYM_TABLE_BUCKETS = 10;

    SymbolTable symbol_table(SYM_TABLE_BUCKETS);
    
    void write_log(string token_name, string token_attr, string lexeme) {
        string token = string("<") + token_name + ", " + token_attr + ">";

        if (token_name == "STRING" || token_name == "CONST_CHAR") {
            fprintf(log_file, "Line no %d: Token <%s> Lexeme %s found. --> %s\n", line_count, token_name.c_str(), lexeme.c_str(), token.c_str());
        } else {
            fprintf(log_file, "Line no %d: Token <%s> Lexeme %s found.\n", line_count, token_name.c_str(), lexeme.c_str());
        }
    }

    void write_token_and_log(string token_name, string token_attr, string lexeme) {
        string token = string("<") + token_name + ", " + token_attr + ">";

        fprintf(token_file, "%s", token.c_str());
        write_log(token_name, token_attr, lexeme);
    }


    void write_error_log(string log, string lexeme = "") {
        error_count++;
        fprintf(log_file, "[ERROR]: Line no %d: %s Lexeme: %s\n", line_count, log.c_str(), lexeme.c_str());
    }
%}


%x BLOCK_COMMENT
%x LINE_COMMENT
%x CHAR
%x ERR_MULTIPLE_CHAR
%x STRING

UNRECOGNIZED_CHARSET [^a-zA-Z0-9\a\b\f\n\r\t\v\0~@!$#\^\*%&\(\)\[\]\{\}<>+=_\-\|\\;:'\",\.\? ]

IF_KW if
FOR_KW for
DO_KW do
INT_KW int
FLOAT_KW float
VOID_KW void
SWITCH_KW switch
DEFAULT_KW default
ELSE_KW else
WHILE_KW while
BREAK_KW break
CHAR_KW char
DOUBLE_KW double
RETURN_KW return
CASE_KW case
CONTINUE_KW continue

ALL_KW {IF_KW}|{FOR_KW}|{DO_KW}|{INT_KW}|{FLOAT_KW}|{VOID_KW}|{SWITCH_KW}|{DEFAULT_KW}|{ELSE_KW}|{WHILE_KW}|{BREAK_KW}|{CHAR_KW}|{DOUBLE_KW}|{RETURN_KW}|{CASE_KW}|{CONTINUE_KW}

WHITESPACE [ \t]*

DIGIT [0-9]
DIGITS {DIGIT}+
INTNUM [-]?{DIGITS}
FLOATNUM {INTNUM}?\.{DIGITS}
EXPNUM ({INTNUM}|{FLOATNUM})[eE]{INTNUM}

ALERT \a
ALERT_LIT \\a
BACKSPACE \b
BACKSPACE_LIT \\b
FORMFEED \f
FORMFEED_LIT \\f
NEWLINE \n
NEWLINE_LIT \\n
CR \r
CR_LIT \\r
TAB \t
TAB_LIT \\t
VERTICALTAB \v
VERTICALTAB_LIT \\v
NULLCHAR \0
NULLCHAR_LIT \\0
BACKSLASH \\
BACKSLASH_LIT \\\\
SINGLEQUOTES \'
SINGLEQUOTES_LIT \\'
DOUBLEQUOTES \"
DOUBLEQUOTES_LIT \\\"

ESCAPED_CHARS_SPECIAL {ALERT}|{BACKSPACE}|{FORMFEED}|{NEWLINE}|{CR}|{TAB}|{VERTICALTAB}|{NULLCHAR}
ESCAPED_CHARS_SPECIAL_EXCEPT_NL {ALERT}|{BACKSPACE}|{FORMFEED}|{TAB}|{VERTICALTAB}|{NULLCHAR}

SINGLECHAR [ -~]

SINGLECHAR_LIT [ -~]{-}[\a\b\f\n\r\t\v\0]
ANY_ESCAPED_CHAR_LIT \\.

DOUBLEFORWARDSLASH \/\/ 


ESCAPED_LINE_BREAK {BACKSLASH}{NEWLINE}

ADDOP [+-]
MULOP [*/%]
INCOP "++"|"--"
RELOP <|<=|>|>=|==|!=
ASSIGNOP =
LOGICOP &&|"||"
NOT !
LPAREN "("
RPAREN ")"
LCURL "{"
RCURL "}"
LTHIRD "["
RTHIRD "]"
COMMA ","
SEMICOLON ";"

ALPHABET [a-zA-Z]
ALPHABETS {ALPHABET}+

ID ({ALPHABET}|_)({ALPHABET}|{DIGIT}|_)*

BLOCK_COMMENT_START \/\*
BLOCK_COMMENT_END \*\/

STRING_NORMAL_CHAR [^\\\n\"]
LINE_COMMENT_NORMAL_CHAR [^\n]

ERR_TOO_MANY_DECIMAL ({DIGITS}?\.{DIGITS}?){2,}
ERR_ILL_FORMED_NUM {EXPNUM}\.{DIGITS}?
ERR_INVALID_SUFF_PREF {DIGITS}{ID}


%%

{UNRECOGNIZED_CHARSET} {
    write_error_log("Unrecognized character.", string(yytext));
}

{ALL_KW} {
    string token_name = "";
    for (char c : string(yytext)) {
        token_name += toupper(c);
    }
    write_token_and_log(token_name, "", string(yytext));
}


{WHITESPACE} {

}


{INTNUM} {
    string token_name = "CONST_INT";
    string token_attr = yytext;
    string token = string("<") + token_name + ", " + token_attr + ">";
    write_token_and_log(token_name, token_attr, string(yytext));

    ostringstream osstrm;
    if (symbol_table.insert(token_attr, "CONST_INT")) {
        osstrm << symbol_table;
        fprintf(log_file, "%s\n", osstrm.str().c_str());
    } else {
        fprintf(log_file, "[REDEFINITION] Cannot insert %s into symbol table.\n", token.c_str());
    }
}

{FLOATNUM}|{EXPNUM} {
    string token_name = "CONST_FLOAT";
    string token_attr = yytext;
    string token = string("<") + token_name + ", " + token_attr + ">";
    write_token_and_log(token_name, token_attr, string(yytext));

    ostringstream osstrm;
    if (symbol_table.insert(token_attr, "CONST_FLOAT")) {
        osstrm << symbol_table;
        fprintf(log_file, "%s\n", osstrm.str().c_str());
    } else {
        fprintf(log_file, "[REDEFINITION] Cannot insert %s into symbol table.\n", token.c_str());
    }
}


{SINGLEQUOTES} {
    matched_char = -1; // used fo matching chars
    matched_literal = ""; // used for error lexeme
    BEGIN CHAR;
}

<CHAR>{SINGLEQUOTES} {
    if (matched_char == -1) {
        string lexeme = "''";
        write_error_log("Empty character constant.", lexeme);
    } else {
        string token_name = "CONST_CHAR";
        string token_attr = string(1, matched_char);
        string token = string("<") + token_name + ", " + token_attr + ">";
        string lexeme = string("'") + matched_literal + string("'");
        write_token_and_log(token_name, token_attr, lexeme);

        ostringstream osstrm;
        if (symbol_table.insert(token_attr, "CONST_CHAR")) {
            osstrm << symbol_table;
            fprintf(log_file, "%s\n", osstrm.str().c_str());
        } else {
            fprintf(log_file, "[REDEFINITION] Cannot insert %s into symbol table.\n", token.c_str());
        }
    }

    BEGIN INITIAL;
}

<CHAR>{NEWLINE} {
    string lexeme = string("'") + matched_literal;
    write_error_log("Unterminated character.", lexeme);

    line_count++;

    BEGIN INITIAL;
}

<CHAR,ERR_MULTIPLE_CHAR>{ESCAPED_CHARS_SPECIAL_EXCEPT_NL} {
    write_error_log("Not a valid character.", string(yytext));
}

<CHAR>{SINGLECHAR_LIT} {
    if (matched_char == -1) {
        matched_char = string(yytext)[0];
        matched_literal += string(yytext); // might need if error occurs
    } else {
        matched_literal += string(yytext); 
        BEGIN INITIAL;
        BEGIN ERR_MULTIPLE_CHAR;
    }
}

<CHAR>{ALERT_LIT} {
    if (matched_char == -1) {
        matched_char = '\a';
        matched_literal += string(yytext); // might need if error occurs
    } else {
        matched_literal += string(yytext);
        BEGIN INITIAL;
        BEGIN ERR_MULTIPLE_CHAR;
    }
}

<CHAR>{BACKSPACE_LIT} {
    if (matched_char == -1) {
        matched_char = '\b';
        matched_literal += string(yytext); // might need if error occurs
    } else {
        matched_literal += string(yytext);
        BEGIN INITIAL;
        BEGIN ERR_MULTIPLE_CHAR;
    }
}

<CHAR>{FORMFEED_LIT} {
    if (matched_char == -1) {
        matched_char = '\f';
        matched_literal += string(yytext); // might need if error occurs
    } else {
        matched_literal += string(yytext);
        BEGIN INITIAL;
        BEGIN ERR_MULTIPLE_CHAR;
    }
}

<CHAR>{NEWLINE_LIT} {
    if (matched_char == -1) {
        matched_char = '\n';
        matched_literal += string(yytext); // might need if error occurs
    } else {
        matched_literal += string(yytext);
        BEGIN INITIAL;
        BEGIN ERR_MULTIPLE_CHAR;
    }
}

<CHAR>{CR_LIT} {
    if (matched_char == -1) {
        matched_char = '\r';
        matched_literal += string(yytext); // might need if error occurs
    } else {
        matched_literal += string(yytext);
        BEGIN INITIAL;
        BEGIN ERR_MULTIPLE_CHAR;
    }
}

<CHAR>{TAB_LIT} {
    if (matched_char == -1) {
        matched_char = '\t';
        matched_literal += string(yytext); // might need if error occurs
    } else {
        matched_literal += string(yytext);
        BEGIN INITIAL;
        BEGIN ERR_MULTIPLE_CHAR;
    }
}

<CHAR>{VERTICALTAB_LIT} {
    if (matched_char == -1) {
        matched_char = '\v';
        matched_literal += string(yytext); // might need if error occurs
    } else {
        matched_literal += string(yytext);
        BEGIN INITIAL;
        BEGIN ERR_MULTIPLE_CHAR;
    }
}

<CHAR>{NULLCHAR_LIT} {
    if (matched_char == -1) {
        matched_char = '\0';
        matched_literal += string(yytext); // might need if error occurs
    } else {
        matched_literal += string(yytext);
        BEGIN INITIAL;
        BEGIN ERR_MULTIPLE_CHAR;
    }
}

<CHAR>{ANY_ESCAPED_CHAR_LIT} {
    if (matched_char == -1) {
        matched_char = string(yytext)[1];
        matched_literal += string(yytext); // might need if error occurs
    } else {
        matched_literal += string(yytext);
        BEGIN INITIAL;
        BEGIN ERR_MULTIPLE_CHAR;
    }
}

<ERR_MULTIPLE_CHAR>{SINGLEQUOTES} {
    string lexeme = string("'") + matched_literal + string("'");
    write_error_log("Multiple character constant error.", lexeme);

    BEGIN INITIAL;
}

<ERR_MULTIPLE_CHAR>{NEWLINE} {
    string lexeme = string("'") + matched_literal;
    write_error_log("Unterminated character.", lexeme);

    line_count++;

    BEGIN INITIAL;
}

<ERR_MULTIPLE_CHAR>[ -~]{-}[\n\'] {
    matched_literal += string(yytext);
}


{ADDOP} {
    string token_name = "ADDOP";
    string token_attr = string(yytext);
    write_token_and_log(token_name, token_attr, string(yytext));
}

{MULOP} {
    string token_name = "MULOP";
    string token_attr = string(yytext);
    write_token_and_log(token_name, token_attr, string(yytext));
}

{INCOP} {
    string token_name = "INCOP";
    string token_attr = string(yytext);
    write_token_and_log(token_name, token_attr, string(yytext));
}

{RELOP} {
    string token_name = "RELOP";
    string token_attr = string(yytext);
    write_token_and_log(token_name, token_attr, string(yytext));
}

{ASSIGNOP} {
    string token_name = "ASSIGNOP";
    string token_attr = string(yytext);
    write_token_and_log(token_name, token_attr, string(yytext));
}

{LOGICOP} {
    string token_name = "LOGICOP";
    string token_attr = string(yytext);
    write_token_and_log(token_name, token_attr, string(yytext));
}

{NOT} {
    string token_name = "NOT";
    string token_attr = string(yytext);
    write_token_and_log(token_name, token_attr, string(yytext));
}

{LPAREN} {
    string token_name = "LPAREN";
    string token_attr = string(yytext);
    write_token_and_log(token_name, token_attr, string(yytext));
}

{RPAREN} {
    string token_name = "RPAREN";
    string token_attr = string(yytext);
    write_token_and_log(token_name, token_attr, string(yytext));
}

{LCURL} {
    string token_name = "LCURL";
    string token_attr = string(yytext);
    write_token_and_log(token_name, token_attr, string(yytext));
    symbol_table.enter_scope();
}

{RCURL} {
    string token_name = "RCURL";
    string token_attr = string(yytext);
    write_token_and_log(token_name, token_attr, string(yytext));
    symbol_table.exit_scope();
}

{LTHIRD} {
    string token_name = "LTHIRD";
    string token_attr = string(yytext);
    write_token_and_log(token_name, token_attr, string(yytext));
}

{RTHIRD} {
    string token_name = "RTHIRD";
    string token_attr = string(yytext);
    write_token_and_log(token_name, token_attr, string(yytext));
}

{COMMA} {
    string token_name = "COMMA";
    string token_attr = string(yytext);
    write_token_and_log(token_name, token_attr, string(yytext));
}

{SEMICOLON} {
    string token_name = "SEMICOLON";
    string token_attr = string(yytext);
    write_token_and_log(token_name, token_attr, string(yytext));
}


{ID} {
    string token_name = "ID";
    string token_attr = string(yytext);
    string token = string("<") + token_name + ", " + token_attr + ">";
    write_token_and_log(token_name, token_attr, string(yytext));
    
    ostringstream osstrm;
    if (symbol_table.insert(token_attr, token_name)) {
        osstrm << symbol_table;
        fprintf(log_file, "%s\n", osstrm.str().c_str());
    } else {
        fprintf(log_file, "[REDEFINITION] Cannot insert %s into symbol table.\n", token.c_str());
    }
}


{DOUBLEQUOTES} {
    BEGIN STRING;
    matched_str = "";
    matched_literal = "";
    pending_line_inc = 0;
}

<STRING>{DOUBLEQUOTES} {
    string token_name = "STRING";
    string token_attr = matched_str;
    string lexeme = string("\"") + matched_literal + "\"";
    write_token_and_log(token_name, token_attr, lexeme);

    line_count += pending_line_inc;

    BEGIN INITIAL;
} 

<STRING>{ESCAPED_LINE_BREAK} {
    pending_line_inc++;
    matched_literal += string(yytext);
}

<STRING>{NEWLINE_LIT} {
    matched_str += '\n';
    matched_literal += string(yytext);
}

<STRING>{TAB_LIT} {
    matched_str += '\t';
    matched_literal += string(yytext);
}

<STRING>{CR_LIT} {
    pending_line_inc++;
    matched_str += '\r';
    matched_literal += string(yytext);
}

<STRING>{BACKSPACE_LIT} {
    matched_str += '\b';
    matched_literal += string(yytext);
}

<STRING>{FORMFEED_LIT} {
    matched_str += '\f';
    matched_literal += string(yytext);
}

<STRING>{ANY_ESCAPED_CHAR_LIT} {
    matched_str += string(yytext)[1];
    matched_literal += string(yytext);
}

<STRING>{STRING_NORMAL_CHAR} {
    matched_str += string(yytext);
    matched_literal += string(yytext);
}

<STRING>{NEWLINE} {
    line_count += pending_line_inc; // so error can point to actual line
    string lexeme = string("\"") + matched_literal;
    write_error_log("Unterminated string.", lexeme);

    line_count++;

    BEGIN INITIAL;
}


{DOUBLEFORWARDSLASH} {
    BEGIN LINE_COMMENT;
    matched_comment = "";
    pending_line_inc = 0;
}

<LINE_COMMENT>{NEWLINE} {
    string token_name = "COMMENT";
    string token_attr = matched_comment;
    string lexeme = "//" + matched_comment;
    write_log(token_name, token_attr, lexeme);

    line_count += pending_line_inc + 1;

    BEGIN INITIAL;
}

<LINE_COMMENT>{ESCAPED_LINE_BREAK} {
    pending_line_inc++;
    matched_comment += string(yytext);
}

<LINE_COMMENT>{LINE_COMMENT_NORMAL_CHAR} {
    matched_comment += string(yytext);
}


{BLOCK_COMMENT_START} {
    BEGIN BLOCK_COMMENT;
    matched_comment = "";
    pending_line_inc = 0;
}

<BLOCK_COMMENT>{BLOCK_COMMENT_END} {
    string token_name = "COMMENT";
    string token_attr = matched_comment;
    string lexeme = "//" + matched_comment;
    write_log(token_name, token_attr, lexeme);

    line_count += pending_line_inc;

    BEGIN INITIAL;
}

<BLOCK_COMMENT>{NEWLINE} {
    pending_line_inc++;
}

<BLOCK_COMMENT><<EOF>> {
    string lexeme = string("\\**") + matched_comment;
    write_error_log("Unterminated comment.", lexeme);

    line_count += pending_line_inc;
    pending_line_inc = 0;

    BEGIN INITIAL;
}

<BLOCK_COMMENT>. {
    matched_comment += string(yytext);
}


{NEWLINE} {
    line_count++;
}

{ERR_TOO_MANY_DECIMAL} {
    write_error_log("Too many decimals.", string(yytext));    
}

{ERR_ILL_FORMED_NUM} {
    write_error_log("Ill formed number.", string(yytext));
}

{ERR_INVALID_SUFF_PREF} {
    write_error_log("Invalid suffix on numeric constant or invalid prefix on identifier.", string(yytext));
}


%%


int main(int argc, char* argv[]) {
    if (argc != 4) {
        cout << "ERROR: lexer needs input, token, log file names as argument\n";
        return 0;
    }

    FILE* input_file = fopen(argv[1], "r");
    token_file = fopen(argv[2], "w");
    log_file = fopen(argv[3], "w");

    if (!input_file || !token_file || !log_file) {
        cout << "ERROR: Could not open file\n";
        return 0;
    }

    yyin = input_file;
    yylex();

    fprintf(log_file, "Total lines: %d\n", line_count);
    fprintf(log_file, "Total errors: %d\n", error_count);

    fclose(input_file);
    fclose(token_file);
    fclose(log_file);

    return 0;
}
