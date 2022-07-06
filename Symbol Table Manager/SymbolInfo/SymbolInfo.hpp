#pragma once
#include <string>
#include <ostream>
#include <vector>

using namespace std;

/**
 * @brief Token class. Contains the name and type of the token. Also contains the pointer to the
 * next SymbolInfo in the chain for the separately chained hashtable of the Scope table.
 */
class SymbolInfo {
    string name;
    string type;
    vector<string> func_types;

public:
    // Not allocated or destroyed inside SymbolInfo class. 
    SymbolInfo* next_syminfo_ptr;

    SymbolInfo(const string&, const string&, SymbolInfo* next_syminfo_ptr=nullptr);

    SymbolInfo(const string&, const string&, vector<string>&);

    ~SymbolInfo();

    string get_name_str();

    string get_type_str();

    vector<string> get_func_types();

    void set_type_str(const string& type);

    void add_func_type(string&);

    friend ostream& operator<<(ostream& ostrm, SymbolInfo& syminfo);
};
