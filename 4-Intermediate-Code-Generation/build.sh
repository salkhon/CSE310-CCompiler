#!/bin/bash

inputfile="./test/Sample Input/temp.c"

# analysis
bison -d analysis.y
flex -o analysis.yy.c analysis.l

# synthesis
bison -d synthesis.y
flex -o synthesis.yy.c synthesis.l 

g++ main.cpp analysis.tab.c analysis.yy.c synthesis.tab.c synthesis.yy.c \
    ./symbol-table/ScopeTable/ScopeTable.cpp \
    ./symbol-table/ScopeTable/SymbolInfoHashTable/SymbolInfoHashTable.cpp \
    ./symbol-table/SymbolInfo/SymbolInfo.cpp \
    ./symbol-table/SymbolTable/SymbolTable.cpp \
    ./symbol-table/SymbolInfo/CodeGenInfo/CodeGenInfo.cpp \
    -o subccompiler.out
./subccompiler.out "$inputfile"

# if i remove the main funcs of the parsers, non of them will have entry points, then i can 
# create a script to call yyparse() of those different parsers. my scripts will combine them. 