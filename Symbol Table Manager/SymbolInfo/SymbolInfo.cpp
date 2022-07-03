#include "SymbolInfo.hpp"

using namespace std;

SymbolInfo::SymbolInfo(const string& name, const string& type, SymbolInfo* next_syminfo_ptr=nullptr)
    : name(name), type(type), next_syminfo_ptr(next_syminfo_ptr) {}

SymbolInfo::~SymbolInfo() {}

string SymbolInfo::get_name_str() {
    return this->name;
}

string SymbolInfo::get_type_str() {
    return this->type;
}

void SymbolInfo::set_type_str(const string& type) {
    this->type = type;
}

ostream& operator<<(ostream& ostrm, SymbolInfo& syminfo) {
    ostrm << "<" << syminfo.get_name_str() << ", " << syminfo.get_type_str() << ">";
    return ostrm;
};