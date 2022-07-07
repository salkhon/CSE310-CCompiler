bison -d parser.y
g++ -w -c parser.tab.c

flex lexer.l
g++ -w -c lex.yy.c

g++ parser.tab.o lex.yy.o ./symbol-table/ScopeTable/ScopeTable.cpp ./symbol-table/ScopeTable/SymbolInfoHashTable/SymbolInfoHashTable.cpp ./symbol-table/SymbolInfo/SymbolInfo.cpp ./symbol-table/SymbolTable/SymbolTable.cpp

./a.out input.txt