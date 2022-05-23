#pragma once
#include <memory>
#include <string>

using namespace std;

class SymbolInfo;

using SymbolInfoPtr = shared_ptr<SymbolInfo>;

class SymbolInfo {
    string name;
    string type;

public:
    SymbolInfoPtr next;

    SymbolInfo(const string& name, const string& type) : name(name), type(type), next(nullptr) {}

    string get_name_str();

    string get_type_str();

    void set_type_str(const string& type);
};
