%option noyywrap
%option c++

%{
    #include <iostream>
    #include <string.h>
    #include <string>
    #include <fstream>
    #include <cctype>

    using namespace std;

    // counts
    int line_count = 1;
    int pending_line_inc = 0;
    int error_count = 0;

    // string buffer
    string matched_str;
    string matched_comment;

    // write files
    ofstream token_file;
    ofstream log_file;
    
    void write_files(string token, string lexeme) {
        token_file << token;
        log_file << "Line No. " << line_count << ": Token " << token << " Lexeme " << lexeme << " found.\n";
    }

    void write_log_only(string log) {
        log_file << "Line No. " << line_count << ": [ERROR] " << log << endl;
    }
%}


%x BLOCK_COMMENT
%x LINE_COMMENT
%x STRING


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

ESCAPED_CHARS {ALERT}|{BACKSPACE}|{FORMFEED}|{NEWLINE}|{CR}|{TAB}|{VERTICALTAB}|{BACKSLASH}|{SINGLEQUOTES}|{DOUBLEQUOTES}|{NULLCHAR}

SINGLECHAR [ -~]

SINGLECHAR_LIT [ -~]{-}[\a\b\f\n\r\t\v\0\\]
ANY_ESCAPED_CHAR_LIT \\.

DOUBLEFORWARDSLASH \/\/ 


ESCAPED_LINE_BREAK {BACKSLASH}{NEWLINE}
ESCAPED_TAB \\\t

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

BLOCK_COMMENT_START \/\*\*
BLOCK_COMMENT_END \*\*\/

STRING_NORMAL_CHAR [^\\\n\"]
LINE_COMMENT_NORMAL_CHAR [^\n]

ERR_MULTIPLE_CHAR '{SINGLECHAR_LIT}{2,}|{ANY_ESCAPED_CHAR_LIT}{2,}'
ERR_UNFINISHED_CHAR '(([ -~]{-}[\a\b\f\n\r\t\v\0\\'])|{ANY_ESCAPED_CHAR_LIT})?
ERR_EMPTY_CHAR ''
ERR_UNRECOGNIZED_CHAR '([^ -~]|{ESCAPED_CHARS})'
ERR_TOO_MANY_DECIMAL ({DIGITS}?\.{DIGITS}?){2,}
ERR_ILL_FORMED_NUM {EXPNUM}{FLOATNUM}
ERR_INVALID_SUFF_PREF {DIGITS}{ID}


%%

{ALL_KW} {
    string token = string("<");
    for (char c : string(YYText())) {
        token += toupper(c);
    }
    token += ">";
    write_files(token, YYText());
}


{WHITESPACE} {

}


{INTNUM} {
    string token = string("<CONST_INT,") + string(YYText()) + string(">");
    write_files(token, YYText());
}

{FLOATNUM} {
    string token = string("<CONST_FLOAT,") + string(YYText()) + string(">");
    write_files(token, YYText());
}

'{SINGLECHAR_LIT}' {
    char char_wo_quotes = string(YYText())[1];
    string token = string("<CONST_CHAR,") + char_wo_quotes + string(">");
    write_files(token, YYText());
}

'{ALERT_LIT}' {
    string token = string("<CONST_CHAR,") + '\a' + string(">");
    write_files(token, YYText());
}

'{BACKSPACE_LIT}' {
    string token = string("<CONST_CHAR,") + '\b' + string(">");
    write_files(token, YYText());
}

'{FORMFEED_LIT}' {
    string token = string("<CONST_CHAR,") + '\f' + string(">");
    write_files(token, YYText());
}

'{NEWLINE_LIT}' {
    string token = string("<CONST_CHAR,") + '\n' + string(">");
    write_files(token, YYText());
}

'{CR_LIT}' {
    string token = string("<CONST_CHAR,") + '\r' + string(">");
    write_files(token, YYText());
}

'{TAB_LIT}' {
    string token = string("<CONST_CHAR,") + '\t' + string(">");
    write_files(token, YYText());
}

'{VERTICALTAB_LIT}' {
    string token = string("<CONST_CHAR,") + '\v' + string(">");
    write_files(token, YYText());
}

'{NULLCHAR_LIT}' {
    string token = string("<CONST_CHAR,") + '\0' + string(">");
    write_files(token, YYText());
}

'{ANY_ESCAPED_CHAR_LIT}' {
    string token = string("<CONST_CHAR,") + YYText()[2] + string(">");
    write_files(token, YYText());
}


{ADDOP} {
    string token = string("<ADDOP,") + YYText() + string(">");
    write_files(token, YYText());
}

{MULOP} {
    string token = string("<MULOP,") + YYText() + string(">");
    write_files(token, YYText());
}

{INCOP} {
    string token = string("<INCOP,") + YYText() + string(">");
    write_files(token, YYText());
}

{RELOP} {
    string token = string("<RELOP,") + YYText() + string(">");
    write_files(token, YYText());
}

{ASSIGNOP} {
    string token = string("<ASSIGNOP,") + YYText() + string(">");
    write_files(token, YYText());
}

{LOGICOP} {
    string token = string("<LOGICOP,") + YYText() + string(">");
    write_files(token, YYText());
}

{NOT} {
    string token = string("<NOT,") + YYText() + string(">");
    write_files(token, YYText());
}

{LPAREN} {
    string token = string("<LPAREN,") + YYText() + string(">");
    write_files(token, YYText());
}

{RPAREN} {
    string token = string("<RPAREN,") + YYText() + string(">");
    write_files(token, YYText());
}

{LCURL} {
    string token = string("<LCURL,") + YYText() + string(">");
    write_files(token, YYText());
}

{RCURL} {
    string token = string("<RCURL,") + YYText() + string(">");
    write_files(token, YYText());
}

{LTHIRD} {
    string token = string("<LTHIRD,") + YYText() + string(">");
    write_files(token, YYText());
}

{RTHIRD} {
    string token = string("<RTHIRD,") + YYText() + string(">");
    write_files(token, YYText());
}

{COMMA} {
    string token = string("<COMMA,") + YYText() + string(">");
    write_files(token, YYText());
}

{SEMICOLON} {
    string token = string("<SEMICOLON,") + YYText() + string(">");
    write_files(token, YYText());
}


{ID} {
    string token = string("<ID,") + YYText() + string(">");
    write_files(token, YYText());
}


{DOUBLEQUOTES} {
    BEGIN STRING;
    matched_str = "";
    pending_line_inc = 0;
}

<STRING>{DOUBLEQUOTES} {
    string token = string("<STRING,") + matched_str + string(">");
    write_files(token, matched_str);
    line_count += pending_line_inc;
    BEGIN INITIAL;
} 

<STRING>{ESCAPED_LINE_BREAK} {
    pending_line_inc++;
    matched_str += '\n';
}

<STRING>{NEWLINE_LIT} {
    matched_str += '\n';
}

<STRING>{TAB_LIT} {
    matched_str += '\t';
}

<STRING>{CR_LIT} {
    pending_line_inc++;
    matched_str += '\r';
}

<STRING>{BACKSPACE_LIT} {
    matched_str += '\b';
}

<STRING>{FORMFEED_LIT} {
    matched_str += '\f';
}

<STRING>{ANY_ESCAPED_CHAR_LIT} {
    matched_str += YYText()[1];
}

<STRING>{STRING_NORMAL_CHAR} {
    matched_str += YYText();
}

<STRING>{NEWLINE} {
    line_count += pending_line_inc; // so error can point to actual line
    write_log_only("Unfinished string");
    line_count -= pending_line_inc;
    pending_line_inc++;
    // not exiting string state, allows detection of further errors after string has been terminated
}


{DOUBLEFORWARDSLASH} {
    BEGIN LINE_COMMENT;
    matched_comment = "";
    pending_line_inc = 0;
}

<LINE_COMMENT>{NEWLINE} {
    string token = "<COMMENT," + matched_comment + string(">");
    write_files(token, matched_comment);
    line_count += pending_line_inc + 1;
    pending_line_inc = 0;
    BEGIN INITIAL;
}

<LINE_COMMENT>{ESCAPED_LINE_BREAK} {
    pending_line_inc++;
    matched_comment += '\n';
}

<LINE_COMMENT>{LINE_COMMENT_NORMAL_CHAR} {
    matched_comment += YYText();
}


{BLOCK_COMMENT_START} {
    BEGIN BLOCK_COMMENT;
    matched_comment = "";
    pending_line_inc = 0;
}

<BLOCK_COMMENT>{BLOCK_COMMENT_END} {
    string token = "<COMMENT," + matched_comment + string(">");
    write_files(token, matched_comment);
    line_count += pending_line_inc;
    pending_line_inc = 0;
    BEGIN INITIAL;
}

<BLOCK_COMMENT>{NEWLINE} {
    matched_comment += '\n';
    pending_line_inc++;
}

<BLOCK_COMMENT><<EOF>> {
    write_log_only("Unfinished comment.");
    line_count += pending_line_inc;
    pending_line_inc = 0;
    BEGIN INITIAL;
}

<BLOCK_COMMENT>. {
    matched_comment += YYText();
}


{NEWLINE} {
    line_count++;
}


{ERR_MULTIPLE_CHAR} {
    write_log_only("Multiple character constant.");
}

{ERR_UNFINISHED_CHAR} {
    write_log_only("Unfinished character.");
}

{ERR_EMPTY_CHAR} {
    write_log_only("Empty character constant.");
}

{ERR_UNRECOGNIZED_CHAR} {
    if (YYText()[1] == '\n') {
        line_count++;
    }
    write_log_only("Unrecognized character.");
}

{ERR_TOO_MANY_DECIMAL} {
    write_log_only("Too many decimals");    
}

{ERR_ILL_FORMED_NUM} {
    write_log_only("Ill formed number.");
}

{ERR_INVALID_SUFF_PREF} {
    write_log_only("Invalid suffix on numberic constant or invalid prefix on identifier.");
}


%%


int main(int argc, char* argv[]) {
    if (argc != 4) {
        cout << "ERROR: lexer needs input, token, log file names as argument\n";
        return 0;
    }

    ifstream input_file(argv[1]);
    token_file.open(argv[2]);
    log_file.open(argv[3]);

    if (!input_file || !token_file || !log_file) {
        cout << "ERROR: Could not open file\n";
        return 0;
    }

    yyFlexLexer lexer(&input_file);
    while (lexer.yylex()) {}

    input_file.close();
    token_file.close();
    log_file.close();

    return 0;
}
