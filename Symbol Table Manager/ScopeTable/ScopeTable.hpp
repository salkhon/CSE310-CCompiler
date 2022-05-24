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
    SymbolInfoHashTable* hashtable;
    int current_id;
    string id;
    ScopeTable* parent_scope_ptr;

public:
    ScopeTable(int total_buckets, ScopeTable*);

    ~ScopeTable();

    ScopeTable* get_parent_scope();

    void set_parent_scope_ptr_with_id_currentid(ScopeTable*);

    string get_id();

    int get_current_id();

    bool insert(const string& symbol_info_name, const string& symbol_info_type);

    SymbolInfo* lookup(const string& symbol_info_name);

    bool delete_symbolinfo(const string& symbol_info_name);

    void print();
};