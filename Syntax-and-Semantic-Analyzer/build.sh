bison -d parser.y
# g++ -w -c parser.tab.c ../Symbol\ Table\ Manager/ScopeTable/ScopeTable.cpp ../Symbol\ Table\ Manager/ScopeTable/SymbolInfoHashTable/SymbolInfoHashTable.cpp ../Symbol\ Table\ Manager/SymbolInfo/SymbolInfo.cpp ../Symbol\ Table\ Manager/SymbolTable/SymbolTable.cpp
g++ -w -c parser.tab.c
flex lexer.l
# g++ -w -c lex.yy.c ../Symbol\ Table\ Manager/ScopeTable/ScopeTable.cpp ../Symbol\ Table\ Manager/ScopeTable/SymbolInfoHashTable/SymbolInfoHashTable.cpp ../Symbol\ Table\ Manager/SymbolInfo/SymbolInfo.cpp ../Symbol\ Table\ Manager/SymbolTable/SymbolTable.cpp
g++ -w -c lex.yy.c
# g++ parser.tab.o lex.yy.o ScopeTable.o SymbolInfoHashTable.o SymbolInfo.o SymbolTable.o
g++ parser.tab.o lex.yy.o ../Symbol\ Table\ Manager/ScopeTable/ScopeTable.cpp ../Symbol\ Table\ Manager/ScopeTable/SymbolInfoHashTable/SymbolInfoHashTable.cpp ../Symbol\ Table\ Manager/SymbolInfo/SymbolInfo.cpp ../Symbol\ Table\ Manager/SymbolTable/SymbolTable.cpp
./a.out input.txt