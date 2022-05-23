#pragma once
#include <memory>
#include <vector>
#include <iostream>
#include "../../SymbolInfo/SymbolInfo.hpp"

using namespace std;

using SymbolInfoPtr = shared_ptr<SymbolInfo>;

class SymbolInfoHashTable {
    const int total_buckets;
    vector<SymbolInfoPtr> table;

public:
    SymbolInfoHashTable(const int total_buckets) : total_buckets(total_buckets), table(total_buckets, nullptr) {}

    ~SymbolInfoHashTable();

    int get_num_buckets();

    bool insert(const SymbolInfoPtr symbol_info_ptr);

    SymbolInfoPtr lookup(const string symbol_name);

    bool delete_symbolinfo(const string symbol_name);

    void print();

private:
    int hash(const string& symbol_name);
};