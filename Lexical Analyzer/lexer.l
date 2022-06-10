%option noyywrap
%option c++

%{
    #include <iostream>
    #include <string.h>
    #include <string>
    #include <fstream>
    #include <cctype>
    #include "../Symbol Table Manager/include.cpp"

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
    ofstream token_file;
    ofstream log_file;

    const int SYM_TABLE_BUCKETS = 10;

    SymbolTable symbol_table(SYM_TABLE_BUCKETS, log_file);
    
    void write_token_and_log(string token, string lexeme) {
        token_file << token;
        log_file << "Line No. " << line_count << ": Token " << token << " Lexeme " << lexeme << " found.\n";
    }

    void write_error_log(string log, string lexeme = "") {
        error_count++;
        log_file << "Line No. " << line_count << ": [ERROR] " << log << " Lexeme: " << lexeme << endl;
    }
%}


%x BLOCK_COMMENT
%x LINE_COMMENT
%x CHAR
%x ERR_MULTIPLE_CHAR
%x STRING

UNRECOGNIZED_CHARSET [^a-zA-Z0-9\a\b\f\n\r\t\v\0~@!$#\^\*%&\(\)\[\]\{\}<>+=_\-\|\/\\;:'\",\.\? ]

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

SINGLECHAR_LIT [ -~]{-}[\a\b\f\n\r\t\v\0\\]
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
    write_error_log("Unrecognized character.", YYText());
}

{ALL_KW} {
    string token = string("<");
    for (char c : string(YYText())) {
        token += toupper(c);
    }
    token += ">";
    write_token_and_log(token, YYText());
}


{WHITESPACE} {

}


{INTNUM} {
    string token = string("<CONST_INT,") + string(YYText()) + string(">");
    write_token_and_log(token, YYText());
    if (symbol_table.insert(YYText(), "CONST_INT")) {
        log_file << symbol_table;
    }
}

{FLOATNUM} {
    string token = string("<CONST_FLOAT,") + string(YYText()) + string(">");
    write_token_and_log(token, YYText());
    if (symbol_table.insert(YYText(), "CONST_FLOAT")) {
        log_file << symbol_table;
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
        string token = string("<CONST_CHAR,") + matched_char + string(">");
        string lexeme = string("'") + matched_literal + string("'");
        write_token_and_log(token, lexeme);
        if (symbol_table.insert(string(1, matched_char), "CONST_CHAR")) {
            log_file << symbol_table;
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
    write_error_log("Not a valid character.", YYText());
}

<CHAR>{SINGLECHAR_LIT} {
    if (matched_char == -1) {
        matched_char = YYText()[0];
        matched_literal += YYText(); // might need if error occurs
    } else {
        matched_literal += YYText(); 
        BEGIN INITIAL;
        BEGIN ERR_MULTIPLE_CHAR;
    }
}

<CHAR>{ALERT_LIT} {
    if (matched_char == -1) {
        matched_char = '\a';
        matched_literal += YYText(); // might need if error occurs
    } else {
        matched_literal += YYText();
        BEGIN INITIAL;
        BEGIN ERR_MULTIPLE_CHAR;
    }
}

<CHAR>{BACKSPACE_LIT} {
    if (matched_char == -1) {
        matched_char = '\b';
        matched_literal += YYText(); // might need if error occurs
    } else {
        matched_literal += YYText();
        BEGIN INITIAL;
        BEGIN ERR_MULTIPLE_CHAR;
    }
}

<CHAR>{FORMFEED_LIT} {
    if (matched_char == -1) {
        matched_char = '\f';
        matched_literal += YYText(); // might need if error occurs
    } else {
        matched_literal += YYText();
        BEGIN INITIAL;
        BEGIN ERR_MULTIPLE_CHAR;
    }
}

<CHAR>{NEWLINE_LIT} {
    if (matched_char == -1) {
        matched_char = '\n';
        matched_literal += YYText(); // might need if error occurs
    } else {
        matched_literal += YYText();
        BEGIN INITIAL;
        BEGIN ERR_MULTIPLE_CHAR;
    }
}

<CHAR>{CR_LIT} {
    if (matched_char == -1) {
        matched_char = '\r';
        matched_literal += YYText(); // might need if error occurs
    } else {
        matched_literal += YYText();
        BEGIN INITIAL;
        BEGIN ERR_MULTIPLE_CHAR;
    }
}

<CHAR>{TAB_LIT} {
    if (matched_char == -1) {
        matched_char = '\t';
        matched_literal += YYText(); // might need if error occurs
    } else {
        matched_literal += YYText();
        BEGIN INITIAL;
        BEGIN ERR_MULTIPLE_CHAR;
    }
}

<CHAR>{VERTICALTAB_LIT} {
    if (matched_char == -1) {
        matched_char = '\v';
        matched_literal += YYText(); // might need if error occurs
    } else {
        matched_literal += YYText();
        BEGIN INITIAL;
        BEGIN ERR_MULTIPLE_CHAR;
    }
}

<CHAR>{NULLCHAR_LIT} {
    if (matched_char == -1) {
        matched_char = '\0';
        matched_literal += YYText(); // might need if error occurs
    } else {
        matched_literal += YYText();
        BEGIN INITIAL;
        BEGIN ERR_MULTIPLE_CHAR;
    }
}

<CHAR>{ANY_ESCAPED_CHAR_LIT} {
    if (matched_char == -1) {
        matched_char = YYText()[1];
        matched_literal += YYText(); // might need if error occurs
    } else {
        matched_literal += YYText();
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
    matched_literal += YYText();
}


{ADDOP} {
    string token = string("<ADDOP,") + YYText() + string(">");
    write_token_and_log(token, YYText());
}

{MULOP} {
    string token = string("<MULOP,") + YYText() + string(">");
    write_token_and_log(token, YYText());
}

{INCOP} {
    string token = string("<INCOP,") + YYText() + string(">");
    write_token_and_log(token, YYText());
}

{RELOP} {
    string token = string("<RELOP,") + YYText() + string(">");
    write_token_and_log(token, YYText());
}

{ASSIGNOP} {
    string token = string("<ASSIGNOP,") + YYText() + string(">");
    write_token_and_log(token, YYText());
}

{LOGICOP} {
    string token = string("<LOGICOP,") + YYText() + string(">");
    write_token_and_log(token, YYText());
}

{NOT} {
    string token = string("<NOT,") + YYText() + string(">");
    write_token_and_log(token, YYText());
}

{LPAREN} {
    string token = string("<LPAREN,") + YYText() + string(">");
    write_token_and_log(token, YYText());
}

{RPAREN} {
    string token = string("<RPAREN,") + YYText() + string(">");
    write_token_and_log(token, YYText());
}

{LCURL} {
    string token = string("<LCURL,") + YYText() + string(">");
    write_token_and_log(token, YYText());
    symbol_table.enter_scope();
}

{RCURL} {
    string token = string("<RCURL,") + YYText() + string(">");
    write_token_and_log(token, YYText());
    symbol_table.exit_scope();
}

{LTHIRD} {
    string token = string("<LTHIRD,") + YYText() + string(">");
    write_token_and_log(token, YYText());
}

{RTHIRD} {
    string token = string("<RTHIRD,") + YYText() + string(">");
    write_token_and_log(token, YYText());
}

{COMMA} {
    string token = string("<COMMA,") + YYText() + string(">");
    write_token_and_log(token, YYText());
}

{SEMICOLON} {
    string token = string("<SEMICOLON,") + YYText() + string(">");
    write_token_and_log(token, YYText());
}


{ID} {
    string token = string("<ID,") + YYText() + string(">");
    write_token_and_log(token, YYText());
    if (symbol_table.insert(YYText(), "ID")) {
        log_file << symbol_table;
    }
}


{DOUBLEQUOTES} {
    BEGIN STRING;
    matched_str = "";
    matched_literal = "";
    pending_line_inc = 0;
}

<STRING>{DOUBLEQUOTES} {
    string token = string("<STRING,") + matched_str + string(">");
    string lexeme = string("\"") + matched_literal + string("\"");
    write_token_and_log(token, lexeme);

    line_count += pending_line_inc;

    BEGIN INITIAL;
} 

<STRING>{ESCAPED_LINE_BREAK} {
    pending_line_inc++;
    matched_literal += YYText();
}

<STRING>{NEWLINE_LIT} {
    matched_str += '\n';
    matched_literal += YYText();
}

<STRING>{TAB_LIT} {
    matched_str += '\t';
    matched_literal += YYText();
}

<STRING>{CR_LIT} {
    pending_line_inc++;
    matched_str += '\r';
    matched_literal += YYText();
}

<STRING>{BACKSPACE_LIT} {
    matched_str += '\b';
    matched_literal += YYText();
}

<STRING>{FORMFEED_LIT} {
    matched_str += '\f';
    matched_literal += YYText();
}

<STRING>{ANY_ESCAPED_CHAR_LIT} {
    matched_str += YYText()[1];
    matched_literal += YYText();
}

<STRING>{STRING_NORMAL_CHAR} {
    matched_str += YYText();
    matched_literal += YYText();
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
    string token = "<COMMENT," + matched_comment + string(">");
    string lexeme = "//" + matched_comment;
    log_file << "Line No. " << line_count << ": Token " << token << " Lexeme " << lexeme << " found.\n";

    line_count += pending_line_inc + 1;
    pending_line_inc = 0;

    BEGIN INITIAL;
}

<LINE_COMMENT>{ESCAPED_LINE_BREAK} {
    pending_line_inc++;
    matched_comment += YYText();
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
    string lexeme = string("\\**") + matched_comment + string("**\\");
    log_file << "Line No. " << line_count << ": Token " << token << " Lexeme " << lexeme << " found.\n";

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
    matched_comment += YYText();
}


{NEWLINE} {
    line_count++;
}

{ERR_TOO_MANY_DECIMAL} {
    write_error_log("Too many decimals.", YYText());    
}

{ERR_ILL_FORMED_NUM} {
    write_error_log("Ill formed number.", YYText());
}

{ERR_INVALID_SUFF_PREF} {
    write_error_log("Invalid suffix on numberic constant or invalid prefix on identifier.", YYText());
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

    log_file << "Total lines: " << line_count << endl;
    log_file << "Total errors: " << error_count; 

    input_file.close();
    token_file.close();
    log_file.close();

    return 0;
}
