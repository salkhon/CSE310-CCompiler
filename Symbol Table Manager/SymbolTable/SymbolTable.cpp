#include "SymbolTable.hpp"

SymbolTable::SymbolTable() : scope_tables(), current_scope_table(nullptr) {}

SymbolTable::~SymbolTable() {
    ScopeTable* current = this->current_scope_table;

    while (current != nullptr) {
        ScopeTable* parent = current->get_parent_scope();
        
        delete current;

        current = parent;
    }
}

void SymbolTable::enter_scope() {

}

void SymbolTable::exit_scope() {

}

bool SymbolTable::insert(const string& symbol_info_name, const string& symbol_info_type) {

}

bool SymbolTable::remove(const string& symbol_info_name) {

}

SymbolInfo* SymbolTable::lookup(const string& symbol_info_name) {

}

void SymbolTable::print_current_scope_table() {

}

void SymbolTable::print_all_scope_tables() {

}