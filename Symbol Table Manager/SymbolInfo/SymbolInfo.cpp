#include "SymbolInfo.hpp"

using namespace std;

SymbolInfo::SymbolInfo(const string& name, const string& type, SymbolInfo* next_syminfo_ptr)
    : name(name), type(type), next_syminfo_ptr(next_syminfo_ptr), func_types() {
}

SymbolInfo::SymbolInfo(const string& name, const string& type, vector<string>& func_types)
    : SymbolInfo(name, type) {
    this->func_types = func_types;
}

SymbolInfo::~SymbolInfo() {}

string SymbolInfo::get_name_str() {
    return this->name;
}

string SymbolInfo::get_type_str() {
    return this->type;
}

vector<string> SymbolInfo::get_func_types() {
    return this->func_types;
}

void SymbolInfo::set_type_str(const string& type) {
    this->type = type;
}

void SymbolInfo::add_func_type(string& func_type) {
    this->func_types.push_back(func_type);
}

ostream& operator<<(ostream& ostrm, SymbolInfo& syminfo) {
    ostrm << "<" << syminfo.get_name_str() << ", " << syminfo.get_type_str() << ">";
    return ostrm;
};