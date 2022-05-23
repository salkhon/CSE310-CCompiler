#pragma once
#include <memory>
#include <string>
#include <iostream>
#include "SymbolInfoHashTable/SymbolInfoHashTable.hpp"

using namespace std;

class ScopeTable;

using SymbolInfoPtr = shared_ptr<SymbolInfo>;
using ScopeTablePtr = shared_ptr<ScopeTable>;

class ScopeTable {
    SymbolInfoHashTable hashtable;
    ScopeTablePtr parent_scope;
    const string id;
    const int current_id;

public:
    ScopeTable(int total_buckets) : hashtable(total_buckets), parent_scope(nullptr), id(""), current_id(-1) {}

    bool insert(const SymbolInfoPtr symbol_info_ptr);

    SymbolInfoPtr lookup(const string& name);

    bool delete_symbolinfo(const string& name);

    void print();
};