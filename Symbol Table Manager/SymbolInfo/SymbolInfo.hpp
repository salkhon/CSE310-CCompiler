#pragma once
#include <string>

using namespace std;

/**
 * @brief Token class. Contains the name and type of the token. Also contains the pointer to the 
 * next SymbolInfo in the chain for the separately chained hashtable of the Scope table.
 */
class SymbolInfo {
    string name;
    string type;

public:
    // Not allocated or destroyed inside SymbolInfo class. 
    SymbolInfo* next_syminfo_ptr; 

    SymbolInfo(const string& name, const string& type, SymbolInfo* next_syminfo_ptr);

    ~SymbolInfo();

    string get_name_str();

    string get_type_str();

    void set_type_str(const string& type);
};
