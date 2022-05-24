#include "ScopeTable.hpp"
#include <iostream>

using namespace std;

/**
 * @brief Allocates symbol info with provided args. Hashes them into the chain of the proper bucket.
 * 
 * @param symbol_info_name Name of the token to be allocated
 * @param symbol_info_type Type of the token to be allocated
 * @return true When insertion is successful. 
 * @return false When insertion is not successful. (Due to collision)
 */
bool ScopeTable::insert(const string& symbol_info_name, const string& symbol_info_type) {
    return this->hashtable.insert(symbol_info_name, symbol_info_type);
}

/**
 * @brief Looks up the token by name. 
 * 
 * @param symbol_info_name Name of token to search. 
 * @return SymbolInfo* Pointer to the searched token. If not found, nullptr is returned. 
 */
SymbolInfo* ScopeTable::lookup(const string& symbol_info_name) {
    return this->hashtable.lookup(symbol_info_name);
}

/**
 * @brief Deallocates the token of the provided name.
 * 
 * @param symbol_info_name Name of the token to be deleted
 * @return true When deletion was successful
 * @return false When deletion was not successful (Not found)
 */
bool ScopeTable::delete_symbolinfo(const string& symbol_info_name) {
    return this->hashtable.delete_symbolinfo(symbol_info_name);
}

void ScopeTable::print() {
    const string INDENT = "\t";
    cout << endl;
    cout << INDENT;
    cout << "Scopetable " << this->id << endl;
    this->hashtable.print();
}