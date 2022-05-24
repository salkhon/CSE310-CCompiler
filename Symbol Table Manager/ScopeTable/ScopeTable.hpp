#pragma once
#include <string>
#include "SymbolInfoHashTable/SymbolInfoHashTable.hpp"

using namespace std;

/**
 * @brief Wrapper class on the Hashtable that holds all the tokens for the current scope.
 * Holds the depth of this scope table in comparison to all previous scope tables.
 * Also has a more complete id that is unique to this scope tale, that represents the the
 * relative depth and sequence of this scope table in comparison to earlier scope tables.
 *
 * Can perform insertion, lookup, deletion for the tokens in the hashtable.
 */
class ScopeTable {
    SymbolInfoHashTable hashtable;
    ScopeTable* parent_scope_ptr;
    const int current_id;
    const string id;

public:
    ScopeTable(int total_buckets)
        : hashtable(total_buckets), parent_scope_ptr(nullptr), id(""), current_id(-1) {}

    bool insert(const string& symbol_info_name, const string& symbol_info_type);

    SymbolInfo* lookup(const string& symbol_info_name);

    bool delete_symbolinfo(const string& symbol_info_name);

    void print();
};