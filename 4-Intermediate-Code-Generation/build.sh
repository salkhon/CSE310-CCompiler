#!/bin/bash

inputfile="./test/Sample Input/loop.c"

# analysis
bison -d parser.y
g++ -w -c parser.tab.c

flex lexer.l
g++ -w -c lex.yy.c

g++ parser.tab.o lex.yy.o \
    ./symbol-table/ScopeTable/ScopeTable.cpp \
    ./symbol-table/ScopeTable/SymbolInfoHashTable/SymbolInfoHashTable.cpp \
    ./symbol-table/SymbolInfo/SymbolInfo.cpp \
    ./symbol-table/SymbolTable/SymbolTable.cpp \
    ./symbol-table/SymbolInfo/CodeGenInfo/CodeGenInfo.cpp \
    -o analysis.out
./analysis.out "$inputfile"

# synthesis
bison -d codegen.y
g++ -w -c codegen.tab.c

flex -o codegenlex.yy.c codegen.l 
g++ -w -c codegenlex.yy.c

g++ codegen.tab.o codegenlex.yy.o \
    ./symbol-table/ScopeTable/ScopeTable.cpp \
    ./symbol-table/ScopeTable/SymbolInfoHashTable/SymbolInfoHashTable.cpp \
    ./symbol-table/SymbolInfo/SymbolInfo.cpp \
    ./symbol-table/SymbolTable/SymbolTable.cpp \
    ./symbol-table/SymbolInfo/CodeGenInfo/CodeGenInfo.cpp \
    -o synthesis.out
./synthesis.out "$inputfile"