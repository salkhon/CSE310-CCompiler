#pragma once
#include <memory>
#include <vector>
#include <iostream>
#include "../../SymbolInfo/SymbolInfo.hpp"
#include "../ScopeTable.hpp"

using namespace std;

// when ScopeTable is imported in main, this file is recursively imported BEFORE ScopeTable. 
// Which would mean ScopeTable* is used before declaration of class ScopeTable. 
class ScopeTable; 

/**
 * @brief Implementation for the token hash table of a Scope Table.
 */
class SymbolInfoHashTable {
    const int total_buckets;
    vector<SymbolInfo*> table;
public:
    ScopeTable* enclosing_scope_table_ptr;

    SymbolInfoHashTable(const int total_buckets);

    ~SymbolInfoHashTable();

    int get_num_buckets();

    bool insert(const string& symbol_info_name, const string& symbol_info_type, vector<string> = {});

    SymbolInfo* lookup(const string& symbol_info_name);

    bool delete_symbolinfo(const string& symbol_info_name);

    void print();

    friend ostream& operator<<(ostream&, SymbolInfoHashTable&);

private:
    int hash(const string& symbol_info_name);
};