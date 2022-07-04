%option noyywrap
%option noinput
%option nounput

%{
    #include <iostream>
    #include <sstream>
    #include <string>
    #include <cctype>
    #include <stdlib.h>
    #include <cstring>
    #include "../Symbol Table Manager/include.hpp"
    #include "parser.tab.h"

    using namespace std;

    void yyerror(char*);

    // counts
    int line_count = 1;
    int pending_line_inc = 0;
    int error_count = 0;

    // buffer
    string matched_literal;

    char matched_char;
    string matched_str;
    string matched_comment;

    const int SYM_TABLE_BUCKETS = 10;

    void write_log(string token_name, string token_attr, string lexeme) {
    }

    void write_token_and_log(string token_name, string token_attr, string lexeme) {
    }

    void write_error_log(string log, string lexeme = "") {
        error_count++;
    }
%}


%x BLOCK_COMMENT
%x LINE_COMMENT
%x CHAR
%x ERR_MULTIPLE_CHAR
%x STRING

UNRECOGNIZED_CHARSET [^a-zA-Z0-9\a\b\f\n\r\t\v\0~@!$#\^\*%&\(\)\[\]\{\}<>\+=_\-\|\\;:'\",\.\? ]

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
INTNUM {DIGITS}
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

SINGLECHAR_LIT [ -~]{-}[\a\b\f\n\r\t\v\0]
ANY_ESCAPED_CHAR_LIT \\.

DOUBLEFORWARDSLASH \/\/ 


ESCAPED_LINE_BREAK {BACKSLASH}{NEWLINE}

ADDOP "+"|"-"
MULOP [\*\/%]
INCOP "++"
DECOP "--"
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
PRINTLN "printf"

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


{IF_KW} {
    string token_name = yytext;
    string token_type = "IF";
    write_token_and_log(token_type, token_name, string(yytext));

    return IF;
}

{FOR_KW} {
    string token_name = yytext;
    string token_type = "FOR";
    write_token_and_log(token_type, token_name, string(yytext));

    return FOR;
}

{INT_KW} {
    string token_name = yytext;
    string token_type = "INT";
    write_token_and_log(token_type, token_name, string(yytext));

    return INT; 
}

{FLOAT_KW} {
    string token_name = yytext;
    string token_type = "FLOAT";
    write_token_and_log(token_type, token_name, string(yytext));

    return FLOAT; 
}

{VOID_KW} {
    string token_name = yytext;
    string token_type = "VOID";
    write_token_and_log(token_type, token_name, string(yytext));

    return VOID;
}

{ELSE_KW} {
    string token_name = yytext;
    string token_type = "ELSE";
    write_token_and_log(token_type, token_name, string(yytext));

    return ELSE; 
}

{WHILE_KW} {
    string token_name = yytext;
    string token_type = "WHILE";
    write_token_and_log(token_type, token_name, string(yytext));

    return WHILE;
}

{RETURN_KW} {
    string token_name = yytext;
    string token_type = "RETURN";
    write_token_and_log(token_type, token_name, string(yytext));

    return RETURN;
}


{WHITESPACE} {

}


{INTNUM} {
    string token_name = yytext;
    string token_type = "CONST_INT";
    string token = string("<") + token_type + ", " + token_name + ">";
    write_token_and_log(token_type, token_name, string(yytext));

    yylval.syminfo_ptr = new SymbolInfo(token_name, token_type);

    return CONST_INT;
}

{FLOATNUM}|{EXPNUM} {
    string token_name = yytext;
    string token_type = "CONST_FLOAT";
    string token = string("<") + token_type + ", " + token_name + ">";
    write_token_and_log(token_type, token_name, string(yytext));

    yylval.syminfo_ptr = new SymbolInfo(token_name, token_type);

    return CONST_FLOAT;
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
        string token_name = string(1, matched_char);
        string token_type = "CONST_CHAR";
        string token = string("<") + token_type + ", " + token_name + ">";
        string lexeme = string("'") + matched_literal + string("'");
        write_token_and_log(token_type, token_name, lexeme);
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
        BEGIN ERR_MULTIPLE_CHAR;
    }
}

<CHAR>{ALERT_LIT} {
    if (matched_char == -1) {
        matched_char = '\a';
        matched_literal += string(yytext); // might need if error occurs
    } else {
        matched_literal += string(yytext);
        BEGIN ERR_MULTIPLE_CHAR;
    }
}

<CHAR>{BACKSPACE_LIT} {
    if (matched_char == -1) {
        matched_char = '\b';
        matched_literal += string(yytext); // might need if error occurs
    } else {
        matched_literal += string(yytext);
        BEGIN ERR_MULTIPLE_CHAR;
    }
}

<CHAR>{FORMFEED_LIT} {
    if (matched_char == -1) {
        matched_char = '\f';
        matched_literal += string(yytext); // might need if error occurs
    } else {
        matched_literal += string(yytext);
        BEGIN ERR_MULTIPLE_CHAR;
    }
}

<CHAR>{NEWLINE_LIT} {
    if (matched_char == -1) {
        matched_char = '\n';
        matched_literal += string(yytext); // might need if error occurs
    } else {
        matched_literal += string(yytext);
        BEGIN ERR_MULTIPLE_CHAR;
    }
}

<CHAR>{CR_LIT} {
    if (matched_char == -1) {
        matched_char = '\r';
        matched_literal += string(yytext); // might need if error occurs
    } else {
        matched_literal += string(yytext);
        BEGIN ERR_MULTIPLE_CHAR;
    }
}

<CHAR>{TAB_LIT} {
    if (matched_char == -1) {
        matched_char = '\t';
        matched_literal += string(yytext); // might need if error occurs
    } else {
        matched_literal += string(yytext);
        BEGIN ERR_MULTIPLE_CHAR;
    }
}

<CHAR>{VERTICALTAB_LIT} {
    if (matched_char == -1) {
        matched_char = '\v';
        matched_literal += string(yytext); // might need if error occurs
    } else {
        matched_literal += string(yytext);
        BEGIN ERR_MULTIPLE_CHAR;
    }
}

<CHAR>{NULLCHAR_LIT} {
    if (matched_char == -1) {
        matched_char = '\0';
        matched_literal += string(yytext); // might need if error occurs
    } else {
        matched_literal += string(yytext);
        BEGIN ERR_MULTIPLE_CHAR;
    }
}

<CHAR>{ANY_ESCAPED_CHAR_LIT} {
    if (matched_char == -1) {
        matched_char = string(yytext)[1];
        matched_literal += string(yytext); // might need if error occurs
    } else {
        matched_literal += string(yytext);
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
    string token_name = string(yytext);
    string token_type = "ADDOP";
    write_token_and_log(token_type, token_name, string(yytext));

    yylval.syminfo_ptr = new SymbolInfo(token_name, token_type);

    return ADDOP;
}

{MULOP} {
    string token_name = string(yytext);
    string token_type = "MULOP";
    write_token_and_log(token_type, token_name, string(yytext));

    yylval.syminfo_ptr = new SymbolInfo(token_name, token_type);

    return MULOP;
}

{INCOP} {
    string token_name = string(yytext);
    string token_type = "INCOP";
    write_token_and_log(token_type, token_name, string(yytext));

    return INCOP;
}

{DECOP} {
    string token_name = string(yytext);
    string token_type = "DECOP";
    write_token_and_log(token_type, token_name, string(yytext));

    return DECOP;
}

{RELOP} {
    string token_name = string(yytext);
    string token_type = "RELOP";
    write_token_and_log(token_type, token_name, string(yytext));

    yylval.syminfo_ptr = new SymbolInfo(token_name, token_type);

    return RELOP;
}

{ASSIGNOP} {
    string token_name = string(yytext);
    string token_type = "ASSIGNOP";
    write_token_and_log(token_type, token_name, string(yytext));

    return ASSIGNOP;
}

{LOGICOP} {
    string token_name = string(yytext);
    string token_type = "LOGICOP";
    write_token_and_log(token_type, token_name, string(yytext));

    yylval.syminfo_ptr = new SymbolInfo(token_name, token_type);

    return LOGICOP;
}

{NOT} {
    string token_name = string(yytext);
    string token_type = "NOT";
    write_token_and_log(token_type, token_name, string(yytext));

    return NOT;
}

{LPAREN} {
    string token_name = string(yytext);
    string token_type = "LPAREN";
    write_token_and_log(token_type, token_name, string(yytext));

    return LPAREN;
}

{RPAREN} {
    string token_name = string(yytext);
    string token_type = "RPAREN";
    write_token_and_log(token_type, token_name, string(yytext));

    return RPAREN;
}

{LCURL} {
    string token_name = string(yytext);
    string token_type = "LCURL";
    write_token_and_log(token_type, token_name, string(yytext));
    
    return LCURL;
}

{RCURL} {
    string token_name = string(yytext);
    string token_type = "RCURL";
    write_token_and_log(token_type, token_name, string(yytext));
    
    return RCURL;
}

{LTHIRD} {
    string token_name = string(yytext);
    string token_type = "LTHIRD";
    write_token_and_log(token_type, token_name, string(yytext));

    return LTHIRD;
}

{RTHIRD} {
    string token_name = string(yytext);
    string token_type = "RTHIRD";
    write_token_and_log(token_type, token_name, string(yytext));

    return RTHIRD;
}

{COMMA} {
    string token_name = string(yytext);
    string token_type = "COMMA";
    write_token_and_log(token_type, token_name, string(yytext));

    return COMMA;
}

{SEMICOLON} {
    string token_name = string(yytext);
    string token_type = "SEMICOLON";
    write_token_and_log(token_type, token_name, string(yytext));

    return SEMICOLON;
}

{PRINTLN} {
    string token_name = string(yytext);
    string token_type = "PRINTLN";
    write_token_and_log(token_type, token_name, string(yytext));

    return PRINTLN;
}


{ID} {
    string token_name = string(yytext);
    string token_type = "ID";
    string token = string("<") + token_type + ", " + token_name + ">";
    write_token_and_log(token_type, token_name, string(yytext));
   
    yylval.syminfo_ptr = new SymbolInfo(token_name, token_type);

    return ID;
}


{DOUBLEQUOTES} {
    BEGIN STRING;
    matched_str = "";
    matched_literal = "";
    pending_line_inc = 0;
}

<STRING>{DOUBLEQUOTES} {
    string token_name = matched_str;
    string token_type = "STRING";
    string lexeme = string("\"") + matched_literal + "\"";
    write_token_and_log(token_type, token_name, lexeme);

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
    string token_name = matched_comment;
    string token_type = "COMMENT";
    string lexeme = "//" + matched_comment;
    write_log(token_type, token_name, lexeme);

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
    string token_name = matched_comment;
    string token_type = "COMMENT";
    string lexeme = "//" + matched_comment;
    write_log(token_type, token_name, lexeme);

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
