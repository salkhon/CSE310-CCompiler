#include "SymbolInfo.hpp"

using namespace std;

SymbolInfo::SymbolInfo(const string& symbol, const string& token_type)
    : symbol(symbol), token_type(token_type) {
}

SymbolInfo::SymbolInfo(const string& symbol, const string& token_type, SymbolInfo* next_syminfo_ptr)
    : SymbolInfo(symbol, token_type) {
    this->next_syminfo_ptr = next_syminfo_ptr;
}

SymbolInfo::SymbolInfo(const string& symbol, const string& token_type, const string& semantic_type)
    : SymbolInfo(symbol, token_type) {
    this->semantic_type = semantic_type;
}

SymbolInfo::SymbolInfo(const string& symbol, const string& token_type, const string& semantic_type, 
    const vector<string>& data)
    : SymbolInfo(symbol, token_type, semantic_type) {
    this->data = data;
}

SymbolInfo::SymbolInfo(const string& symbol, const string& token_type, const string& semantic_type,
    const vector<string>& data, SymbolInfo* next_syminfo_ptr)
    : SymbolInfo(symbol, token_type, semantic_type, data) {
    this->next_syminfo_ptr = next_syminfo_ptr;
}

SymbolInfo::~SymbolInfo() {}

string SymbolInfo::get_symbol() {
    return this->symbol;
}

string SymbolInfo::get_token_type() {
    return this->token_type;
}

string SymbolInfo::get_semantic_type() {
    return this->semantic_type;
}

vector<string> SymbolInfo::get_all_data() {
    return this->data;
}

void SymbolInfo::set_all_data(vector<string> data) {
    this->data = data;
}

void SymbolInfo::set_semantic_type(string semantic_type) {
    this->semantic_type = semantic_type;
}

void SymbolInfo::add_data(string data_str) {
    this->data.push_back(data_str);
}

ostream& operator<<(ostream& ostrm, SymbolInfo& syminfo) {
    ostrm << "<" << syminfo.get_symbol() << ", " << syminfo.get_token_type() << ">";
    return ostrm;
};