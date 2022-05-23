#include "ScopeTable.hpp"

using namespace std;

bool ScopeTable::insert(const SymbolInfoPtr symbol_info_ptr) {
    return this->hashtable.insert(symbol_info_ptr);
}

SymbolInfoPtr ScopeTable::lookup(const string& symbol_name) {
    return this->hashtable.lookup(symbol_name);
}

bool ScopeTable::delete_symbolinfo(const string& symbol_name) {
    return this->hashtable.delete_symbolinfo(symbol_name);
}

void ScopeTable::print() {
    const string INDENT = "\t";
    cout << endl;
    cout << INDENT;
    cout << "Scopetable " << this->id << endl;
    this->hashtable.print();
}