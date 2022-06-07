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

    // write files
    ofstream token_file;
    ofstream log_file;

    void write_files(string token, string lexeme) {
        token_file << token;
        log_file << "Line No. " << line_count << ": Token " << token << " Lexeme " << lexeme << " found.\n";
    }

    char get_ascii_char_from_escape_literal(string escape_literal) {
        string wo_quotes = escape_literal.substr(1, escape_literal.length()-2);
        cout << "heer: " << wo_quotes << endl;
        if (wo_quotes == "\\n") {
            return '\n';
        } else if (wo_quotes == "\\t") {
            return '\t';
        } else if (wo_quotes == "\\\\") {
            return '\\';
        } else if (wo_quotes == "\\'") {
            return '\'';    
        } else if (wo_quotes == "\\a") {
            return '\a';
        } else if (wo_quotes == "\\f") {
            return '\f';
        } else if (wo_quotes == "\\r") {
            return '\r';
        } else if (wo_quotes == "\\b") {
            return '\b';
        } else if (wo_quotes == "\\v") {
            return '\v';
        } else if (wo_quotes == "\\0") {
            return '\0';
        } else {
            return '\0';
        }
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
INTNUM [-]?{DIGITS}
FLOATNUM {INTNUM}?\.{DIGITS}
EXPNUM ({INTNUM}|{FLOATNUM})[eE]{INTNUM}

ESCAPECHARS \\n|\\t|\\\\|\\'|\\a|\\f|\\r|\\b|\\v|\\0
SINGLECHARLIT '[ -~]{-}[\\]'
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

{SINGLECHARLIT} {
    char char_wo_quotes = string(YYText())[1];
    if (char_wo_quotes == '\'') {
        char_wo_quotes = '\0';
    }
    string token = string("<CONST_CHAR,") + char_wo_quotes + string(">");
    write_files(token, YYText());
}

{MULTICHARLIT} {
    char escape_char = get_ascii_char_from_escape_literal(YYText());
    string token = string("<CONST_CHAR,") + escape_char + ">";
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
