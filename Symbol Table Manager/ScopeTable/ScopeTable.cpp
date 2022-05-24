#include "ScopeTable.hpp"
#include <iostream>

using namespace std;

ScopeTable::ScopeTable(const int total_buckets, ScopeTable* parent_scope_ptr)
    : hashtable(new SymbolInfoHashTable(total_buckets)), num_deleted_children(0) {
    this->set_parent_scope_ptr_with_id_currentid(parent_scope_ptr);

    cout << "New ScopeTable with id " << this->id << " created\n";
}

ScopeTable::~ScopeTable() {
    delete this->hashtable;
    cout << "ScopeTable with " << this->id << " removed\n";
}

/**
 * @brief Allocates symbol info with provided args. Hashes them into the chain of the proper bucket.
 *
 * @param symbol_info_name Name of the token to be allocated
 * @param symbol_info_type Type of the token to be allocated
 * @return true When insertion is successful.
 * @return false When insertion is not successful. (collision)
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
 * When parent scope ptr is set to nullptr, it is interpreted that the scope table has no parent
 * scope, therefore is of depth 1. 
 */
void ScopeTable::set_parent_scope_ptr_with_id_currentid(ScopeTable* parent_scope_ptr) {
    this->parent_scope_ptr = parent_scope_ptr;

    if (this->parent_scope_ptr != nullptr) {
        this->current_id = this->parent_scope_ptr->current_id + 1;
        this->id = this->parent_scope_ptr->get_id() + "." +
            to_string(this->parent_scope_ptr->get_num_deleted_children() + 1);
    } else {
        this->current_id = 1;
        this->id = "1";
    }

    printing_info::_scope_table_id = this->id;
}

int ScopeTable::get_num_deleted_children() {
    return this->num_deleted_children;
}

void ScopeTable::set_num_deleted_children(int num_deleted_childred) {
    this->num_deleted_children = num_deleted_childred;
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