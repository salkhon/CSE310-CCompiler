%option noyywrap
%option c++

%{
    #include <iostream>
    #include <string.h>
    #include <string>
    #include <fstream>

    using namespace std;

    // counts
    int line_count = 0;
    int error_count = 0;

    // string buffer
    string matched_str;

    // write files
    ofstream token_file;
    ofstream log_file;

    void write_files(string token, string lexeme) {
        token_file << token;
        log_file << "Line No. " << line_count << ": Token " << token << " Lexeme " << lexeme << " found.\n";
    }
%}


%x BLOCK_COMMENT
%x LINE_COMMENT
%x STRING
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

WHITESPACE [ \t]*

DIGIT [0-9]
DIGITS {DIGIT}+
INTNUM [-]?{DIGITS}
FLOATNUM {INTNUM}?\.{DIGITS}
EXPNUM ({INTNUM}|{FLOATNUM})[eE]{INTNUM}

ALERT \a
ALERTLIT \\a
BACKSPACE \b
BACKSPACELIT \\b
FORMFEED \f
FORMFEEDLIT \\f
NEWLINE \n
NEWLINELIT \\n
CR \r
CRLIT \\r
TAB \t
TABLIT \\t
VERTICALTAB \v
VERTICALTABLIT \\v
BACKSLASH \\
BACKSLASHLIT \\\\
SINGLEQUOTES \'
SINGLEQUOTESLIT \\'
DOUBLEQUOTES \"
DOUBLEQUOTESLIT \\\"

ESCAPEDCHARS {ALERT}|{BACKSPACE}|{FORMFEED}|{NEWLINE}|{CR}|{TAB}|{VERTICALTAB}|{BACKSLASH}|{SINGLEQUOTES}|{DOUBLEQUOTES}

ESCAPEDLINEBREAK \\\n
ESCAPEDTAB \\\t
SINGLECHARLIT [ -~]
MULTICHARLIT '{ESCAPECHARS}'

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

QUOTES \"


%%


{IFKW} {
    string token = "<IF>";
    write_files(token, YYText());
}

{FORKW} {
    string token = "<FOR>";
    write_files(token, YYText());
}

{DOKW} {
    string token = "<DO>";
    write_files(token, YYText());
}

{INTKW} {
    string token = "<INT>";
    write_files(token, YYText());
}

{FLOATKW} {
    string token = "<FLOAT>";
    write_files(token, YYText());
}

{VOIDKW} {
    string token = "<VOID>";
    write_files(token, YYText());
}

{SWITCHKW} {
    string token = "<SWITCH>";
    write_files(token, YYText());
}

{DEFAULTKW} {
    string token = "<DEFAULT>";
    write_files(token, YYText());
}

{ELSEKW} {
    string token = "<ELSE>";
    write_files(token, YYText());
}

{WHILEKW} {
    string token = "<WHILE>";
    write_files(token, YYText());
}

{BREAKKW} {
    string token = "<BREAK>";
    write_files(token, YYText());
}

{CHARKW} {
    string token = "<CHAR>";
    write_files(token, YYText());
}

{DOUBLEKW} {
    string token = "<DOUBLE>";
    write_files(token, YYText());
}

{RETURNKW} {
    string token = "<RETURN>";
    write_files(token, YYText());
}

{CASEKW} {
    string token = "<CASE>";
    write_files(token, YYText());
}

{CONTINUEKW} {
    string token = "<CONTINUE>";
    write_files(token, YYText());
}


{INTNUM} {
    string token = string("<CONST_INT,") + string(YYText()) + string(">");
    write_files(token, YYText());
}

{FLOATNUM} {
    string token = string("<CONST_FLOAT,") + string(YYText()) + string(">");
    write_files(token, YYText());
}

'{SINGLECHARLIT}' {
    char char_wo_quotes = string(YYText())[1];
    string token = string("<CONST_CHAR,") + char_wo_quotes + string(">");
    write_files(token, YYText());
}

'{ALERTLIT}' {
    string token = string("<CONST_CHAR,") + '\a' + string(">");
    write_files(token, YYText());
}

'{BACKSPACELIT}' {
    string token = string("<CONST_CHAR,") + '\b' + string(">");
    write_files(token, YYText());
}

'{FORMFEEDLIT}' {
    string token = string("<CONST_CHAR,") + '\f' + string(">");
    write_files(token, YYText());
}

'{NEWLINELIT}' {
    string token = string("<CONST_CHAR,") + '\t' + string(">");
    write_files(token, YYText());
}

'{CRLIT}' {
    string token = string("<CONST_CHAR,") + '\r' + string(">");
    write_files(token, YYText());
}

'{TABLIT}' {
    string token = string("<CONST_CHAR,") + '\t' + string(">");
    write_files(token, YYText());
}

'{VERTICALTABLIT}' {
    string token = string("<CONST_CHAR,") + '\v' + string(">");
    write_files(token, YYText());
}

'{BACKSLASHLIT}' {
    string token = string("<CONST_CHAR,") + '\\' + string(">");
    write_files(token, YYText());
}

'{SINGLEQUOTESLIT}' {
    string token = string("<CONST_CHAR,") + '\'' + string(">");
    write_files(token, YYText());
}

'({DOUBLEQUOTESLIT}|{DOUBLEQUOTES})' {
    string token = string("<CONST_CHAR,") + '\"' + string(">");
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


{QUOTES} {
    BEGIN STRING;
    matched_str = "";
}

<STRING>{QUOTES} {
    string token = string("<STRING,") + matched_str + string(">");
    write_files(token, matched_str);
    BEGIN INITIAL;
} 

<STRING>{NEWLINELIT} {
    matched_str += '\n';
}

<STRING>{TABLIT} {
    matched_str += '\t';
}

<STRING>{CRLIT} {
    matched_str += '\r';
}

<STRING>{BACKSPACELIT} {
    matched_str += '\b';
}

<STRING>{FORMFEEDLIT} {
    matched_str += '\f';
}

<STRING>\\. {
    matched_str += YYText()[1];
}

<STRING>[^\\\n\"] {
    matched_str += YYText();
}

{NEWLINE} {
    line_count++;
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
