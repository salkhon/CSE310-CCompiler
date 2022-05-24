// headers
#include "ScopeTable/ScopeTable.hpp"
#include "SymbolInfo/SymbolInfo.hpp"
#include "SymbolTable/SymbolTable.hpp"

// cpp for linker
#include "ScopeTable/ScopeTable.cpp"
#include "ScopeTable/SymbolInfoHashTable/SymbolInfoHashTable.cpp"
#include "SymbolInfo/SymbolInfo.cpp"
#include "SymbolTable/SymbolTable.cpp"

#include <iostream>
#include <fstream>
#include <string>

using namespace std;

int main() {
    ifstream ifs("input.txt");

    if (ifs.is_open()) {
        string input;

        ifs >> input;
        cout << input << endl;

        const int total_buckets = stoi(input);

        SymbolTable symbol_table(total_buckets);

        string symbol_name, symbol_type;

        while (ifs.good()) {
            ifs >> input;
            cout << input << " ";

            if (input == "I") {
                ifs >> symbol_name >> symbol_type;
                cout << symbol_name << " " << symbol_type << endl;

                symbol_table.insert(symbol_name, symbol_type);
            } else if (input == "L") {
                ifs >> symbol_name;
                cout << symbol_name << endl;

                symbol_table.lookup(symbol_name);
            } else if (input == "D") {
                ifs >> symbol_name;
                cout << symbol_name << endl;

                symbol_table.lookup(symbol_name);
            } else if (input == "P") {
                ifs >> input;
                cout << input << endl;

                if (input == "A") {
                    symbol_table.print_all_scope_tables();
                } else if (input == "C") {
                    symbol_table.print_current_scope_table();
                }
            } else if (input == "S") {
                cout << endl;

                symbol_table.enter_scope();
            } else if (input == "E") {
                cout << endl;

                symbol_table.exit_scope();
            }
        }
    }

    return 0;
}