%option noyywrap

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <string>

using namespace std;

// counts
int line_count = 0;
int error_count = 0;

// write files
FILE* token_file;
FILE* log_file;

void write_files(char token[]) {
    fprintf(token_file, "%s", token);
    fprintf(log_file, "Line No. %d: Token %s Lexeme %s found.\n", line_count, token, yytext);
}

char get_char_from_literal_str(char char_literal[]) {
    char quotes_removed = 
}
%}


%x BLOCK_COMMENT
%x LINE_COMMENT
%x SINGLELINE_STRING
%X MULTILINE_STRING


IFKW if
FORKW for
DOKW do
INTKW int
FLOATKW float
VOIDKW void
SWITCHKW switch
DEFAULTKW default
ELSEKW else
WHILEKW while
BREAKKW break
CHARKW char
DOUBLEKW double
RETURNKW return
CASEKW case
CONTINUEKW continue

NEWLINE \n
WHITESPACE [ \t]*

DIGIT [0-9]
DIGITS {DIGIT}+
INTNUM [+-]?{DIGITS}
FLOATNUM {INTNUM}.{DIGITS}
EXPNUM ({INTNUM}|{FLOATNUM})[eE]{INTNUM}

CHARLIT '([ -~]{-}[\n\t\\\\\\\a\f\r\b\v\0])?'

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

ID ({ALPHABET}|_)({ALPHABET}|{DIGITS}|_)*


%%


{IFKW} {
    char token[] = "<IF>";
    write_files(token);
}

{FORKW} {
    char token[] = "<FOR>";
    write_files(token);
}

{DOKW} {
    char token[] = "<DO>";
    write_files(token);
}

{INTKW} {
    char token[] = "<INT>";
    write_files(token);
}

{FLOATKW} {
    char token[] = "<FLOAT>";
    write_files(token);
}

{VOIDKW} {
    char token[] = "<VOID>";
    write_files(token);
}

{SWITCHKW} {
    char token[] = "<SWITCH>";
    write_files(token);
}

{DEFAULTKW} {
    char token[] = "<DEFAULT>";
    write_files(token);
}

{ELSEKW} {
    char token[] = "<ELSE>";
    write_files(token);
}

{WHILEKW} {
    char token[] = "<WHILE>";
    write_files(token);
}

{BREAKKW} {
    char token[] = "<BREAK>";
    write_files(token);
}

{CHARKW} {
    char token[] = "<CHAR>";
    write_files(token);
}

{DOUBLEKW} {
    char token[] = "<DOUBLE>";
    write_files(token);
}

{RETURNKW} {
    char token[] = "<RETURN>";
    write_files(token);
}

{CASEKW} {
    char token[] = "<CASE>";
    write_files(token);
}

{CONTINUEKW} {
    char token[] = "<CONTINUE>";
    write_files(token);
}


{INTNUM} {
    char token[30] = "<CONST_INT,";
    strcat(token, yytext);
    strcat(token, ">");
    write_files(token);
}

{FLOATNUM} {
    char token[30] = "<CONST_FLOAT,";
    strcat(token, yytext);
    strcat(token, ">");
    write_files(token);
}

{CHARLIT} {
    char token[20]  = "<CONST_CHAR,";
    strcat(token, yytext);
    strcat(token, ">");
    write_files(token);
}


{NEWLINE} {
    line_count++;
}



%%


int main(int argc, char* argv[]) {
    if (argc != 4) {
        printf("ERROR: lexer needs input, token, log file names as argument\n");
        return 0;
    }

    FILE* input_file = fopen(argv[1], "r");
    token_file = fopen(argv[2], "w");
    log_file = fopen(argv[3], "w");

    if (input_file == NULL || token_file == NULL || log_file == NULL) {
        printf("ERROR: Could not open file\n");
        return 0;
    }

    yyin = input_file;
    yylineno = 1;
    yylex();

    fclose(yyin);
    fclose(token_file);
    fclose(log_file);
    return 0;
}
