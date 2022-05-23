#include "SymbolInfo.hpp"

string SymbolInfo::get_name_str() {
    return this->name;
}

string SymbolInfo::get_type_str() {
    return this->type;
}

void SymbolInfo::set_type_str(const string& type) {
    this->type = type;
}