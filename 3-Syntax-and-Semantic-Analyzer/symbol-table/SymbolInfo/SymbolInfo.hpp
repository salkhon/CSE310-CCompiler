#pragma once
#include <string>
#include <ostream>
#include <vector>

using namespace std;

/**
 * @brief Token class. Contains the name and type of the token. Also contains the pointer to the
 * next SymbolInfo in the chain for the separately chained hashtable of the Scope table.
 * 
 * Contains the name of the symbol, type of the token, semantic type and additional data strings 
 * for semantic analysis.
 */
class SymbolInfo {
    string symbol;
    string token_type;
    string semantic_type;
    vector<string> data;

public:
    // Not allocated or destroyed inside SymbolInfo class. 
    SymbolInfo* next_syminfo_ptr;

    SymbolInfo(const string&, const string&);

    SymbolInfo(const string&, const string&, SymbolInfo*);

    SymbolInfo(const string&, const string&, const string&);

    SymbolInfo(const string&, const string&, const string&, const vector<string>&);

    SymbolInfo(const string&, const string&, const string&, const vector<string>&, SymbolInfo*);

    ~SymbolInfo();

    string get_symbol();

    string get_token_type();

    string get_semantic_type();

    void set_semantic_type(string type);

    vector<string> get_all_data();

    void set_all_data(vector<string>);

    void add_data(string);

    friend ostream& operator<<(ostream& ostrm, SymbolInfo& syminfo);
};
