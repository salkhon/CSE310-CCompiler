#include "SymbolTable.hpp"

using namespace std;

SymbolTable::SymbolTable(int total_buckets)
    : scope_tables(),
    total_buckets(total_buckets) {
    this->scope_tables.push_back(new ScopeTable(total_buckets, nullptr));
    this->current_scope_table = this->scope_tables[0];
}

SymbolTable::~SymbolTable() {
    ScopeTable* current = this->current_scope_table;

    while (current != nullptr) {
        ScopeTable* parent = current->get_parent_scope();

        delete current;

        current = parent;
    }
}

/**
 * @brief Pushes a new scope table on top of the scope table stack.
 */
void SymbolTable::enter_scope() {
    ScopeTable* new_scope_table = new ScopeTable(this->total_buckets, this->current_scope_table);
    this->scope_tables.push_back(new_scope_table);
    this->current_scope_table = new_scope_table;
}

/**
 * @brief Pops the current top scope from the scope table stack.
 *
 */
void SymbolTable::exit_scope() {
    if (this->current_scope_table == nullptr) {
        return;
    }

    ScopeTable* old_current_scope_table = this->current_scope_table;
    this->current_scope_table = this->current_scope_table->get_parent_scope();
    this->scope_tables.pop_back();

    delete old_current_scope_table;
    this->current_scope_table->set_num_deleted_children(
        this->current_scope_table->get_num_deleted_children() + 1
    );
}

/**
 * @brief Inserts the provided token into the current scope table.
 *
 * @param symbol_info_name Token name
 * @param symbol_info_type Token type
 * @return true When insertion is successful
 * @return false When insertion is not successful (collision or no scope table)
 */
bool SymbolTable::insert(const string& symbol_info_name, const string& symbol_info_type) {
    if (this->current_scope_table == nullptr) {
        return false;
    }

    return this->current_scope_table->insert(symbol_info_name, symbol_info_type);
}

/**
 * @brief Removes a token from the current scope table.
 *
 * @param symbol_info_name Token to delete
 * @return true When delete is successful
 * @return false When delete is not successful (Not found or no scope table)
 */
bool SymbolTable::remove(const string& symbol_info_name) {
    if (this->current_scope_table == nullptr) {
        return false;
    }

    return this->current_scope_table->delete_symbolinfo(symbol_info_name);
}

/**
 * @brief Searches for a token by name. Searches from the current scope. Traverses the scope stack
 * top to bottom until token is found. If not found, nullptr is returned.
 *
 * @param symbol_info_name Token name
 * @return SymbolInfo* Target token. If not found, nullptr is returned.
 */
SymbolInfo* SymbolTable::lookup(const string& symbol_info_name) {
    if (current_scope_table == nullptr) {
        return nullptr;
    }

    SymbolInfo* target = nullptr;
    ScopeTable* current = this->current_scope_table;

    while (current != nullptr) {
        printing_info::_scope_table_id = current->get_id();
        target = current->lookup(symbol_info_name);
        if (target != nullptr) {
            break;
        }
        current = current->get_parent_scope();
    }

    if (target == nullptr) {
        cout << "Not found\n";
    }

    return target;
}

void SymbolTable::print_current_scope_table() {
    this->current_scope_table->print();
}

void SymbolTable::print_all_scope_tables() {
    cout << "==========================Symbol Table==================================\n";
    for (auto rev_iter = this->scope_tables.rbegin(); rev_iter != this->scope_tables.rend(); rev_iter++) {
        ScopeTable* scope_table = *rev_iter;

        cout << "\nScopetable: " << scope_table->get_id() << endl;
        scope_table->print();
    }
    cout << "==========================------X-----==================================\n";
}