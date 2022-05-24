#include "ScopeTable.hpp"
#include <iostream>

using namespace std;

ScopeTable::ScopeTable(const int total_buckets, ScopeTable* parent_scope_ptr = nullptr)
    : hashtable(new SymbolInfoHashTable(total_buckets)) {
    this->set_parent_scope_ptr_with_id_currentid(parent_scope_ptr);
}

ScopeTable::~ScopeTable() {
    delete this->hashtable;
}

/**
 * @brief Allocates symbol info with provided args. Hashes them into the chain of the proper bucket.
 *
 * @param symbol_info_name Name of the token to be allocated
 * @param symbol_info_type Type of the token to be allocated
 * @return true When insertion is successful.
 * @return false When insertion is not successful. (Due to collision)
 */
bool ScopeTable::insert(const string& symbol_info_name, const string& symbol_info_type) {
    return this->hashtable->insert(symbol_info_name, symbol_info_type);
}

/**
 * @brief Looks up the token by name.
 *
 * @param symbol_info_name Name of token to search.
 * @return SymbolInfo* Pointer to the searched token. If not found, nullptr is returned.
 */
SymbolInfo* ScopeTable::lookup(const string& symbol_info_name) {
    return this->hashtable->lookup(symbol_info_name);
}

/**
 * @brief Deallocates the token of the provided name.
 *
 * @param symbol_info_name Name of the token to be deleted
 * @return true When deletion was successful
 * @return false When deletion was not successful (Not found)
 */
bool ScopeTable::delete_symbolinfo(const string& symbol_info_name) {
    return this->hashtable->delete_symbolinfo(symbol_info_name);
}

/**
 * @brief Sets parent_scope_ptr attribute for this scope table. It also sets current_id (int)
 * and id (string) attribute for this scope table from the parent scope.
 *
 * If parent scope is not available at the time of constuction of this scope table, this method
 * can later be called with a completely constucted parent scope to correctly set attributes:
 * parent_scope_ptr, current_id, id.
 */
void ScopeTable::set_parent_scope_ptr_with_id_currentid(ScopeTable* parent_scope_ptr) {
    this->parent_scope_ptr = parent_scope_ptr;

    if (this->parent_scope_ptr != nullptr) {
        this->current_id = this->parent_scope_ptr->current_id + 1;
        // TODO construct id from number of deleted child scope tables from the parent scope. 
    } else {
        this->current_id = 1;
        this->id = "";
    }
}

ScopeTable* ScopeTable::get_parent_scope() {
    return this->parent_scope_ptr;
}

string ScopeTable::get_id() {
    return this->id;
}

int ScopeTable::get_current_id() {
    return this->current_id;
}

void ScopeTable::print() {
    const string INDENT = "\t";
    cout << endl;
    cout << INDENT;
    cout << "Scopetable " << this->id << endl;
    this->hashtable->print();
}