#pragma once
#include <memory>
#include <vector>
#include <iostream>
#include "../../SymbolInfo/SymbolInfo.hpp"

using namespace std;

namespace printing_info {
    string _scope_table_id;
    int _chain_index;
}

/**
 * @brief Implementation for the token hash table of a Scope Table.
 */
class SymbolInfoHashTable {
    const int total_buckets;
    vector<SymbolInfo*> table;

public:
    SymbolInfoHashTable(const int total_buckets);

    ~SymbolInfoHashTable();

    int get_num_buckets();

    bool insert(const string& symbol_info_name, const string& symbol_info_type);

    SymbolInfo* lookup(const string& symbol_info_name);

    bool delete_symbolinfo(const string& symbol_info_name);

    void print();

private:
    int hash(const string& symbol_info_name);
};