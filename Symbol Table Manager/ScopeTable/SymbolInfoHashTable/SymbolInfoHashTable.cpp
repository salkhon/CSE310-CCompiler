#include "SymbolInfoHashTable.hpp"

using namespace std;

SymbolInfoHashTable::SymbolInfoHashTable(const int total_buckets)
    : total_buckets(total_buckets), table(total_buckets, nullptr) {}

void _delete_chain(SymbolInfo* const chain_root) {
    SymbolInfo* current = chain_root;
    while (current != nullptr) {
        SymbolInfo* next = current->next_syminfo_ptr;
        delete current;
        current = next;
    }
}

SymbolInfoHashTable::~SymbolInfoHashTable() {
    for (SymbolInfo* chain_root : this->table) {
        _delete_chain(chain_root);
    }
}

SymbolInfo* find_syminfo_name_in_chain(const string& symbol_info_name, SymbolInfo* const chain_root) {
    SymbolInfo* current = chain_root;
    int idx = 0;
    while (current != nullptr) {
        if (current->get_name_str() == symbol_info_name) {
            break;
        }
        current = current->next_syminfo_ptr;
        idx++;
    }
    printing_info::_chain_index = idx;

    return current;
}

int SymbolInfoHashTable::get_num_buckets() {
    return this->total_buckets;
}

bool SymbolInfoHashTable::insert(const string& symbol_info_name, const string& symbol_info_type) {
    int bucket = this->hash(symbol_info_name);

    SymbolInfo* old_chain_root = this->table[bucket];

    SymbolInfo* collision = find_syminfo_name_in_chain(symbol_info_name, old_chain_root);

    if (collision == nullptr) {
        // no collision
        SymbolInfo* insertion = new SymbolInfo(symbol_info_name, symbol_info_type, old_chain_root);
        this->table[bucket] = insertion;

        cout << "Inserted in ScopeTable# " << printing_info::_scope_table_id << " at position "
            << bucket << ", " << printing_info::_chain_index << endl;

        return true;
    } else {
        cout << "<" << collision->get_name_str() << ", " << collision->get_type_str()
            << "> already exists in the current ScopeTable\n";

        return false;
    }
}

SymbolInfo* SymbolInfoHashTable::lookup(const string& symbol_info_name) {
    int bucket = this->hash(symbol_info_name);
    SymbolInfo* target = find_syminfo_name_in_chain(symbol_info_name, this->table[bucket]);

    if (target != nullptr) {
        cout << "Found in ScopeTable# " << printing_info::_scope_table_id << " at position "
            << bucket << ", " << printing_info::_chain_index << endl;
    }

    return target;
}

bool SymbolInfoHashTable::delete_symbolinfo(const string& symbol_info_name) {
    int bucket = this->hash(symbol_info_name);

    SymbolInfo* current = this->table[bucket];

    bool is_successful_delete = false;

    if (current != nullptr && current->get_name_str() == symbol_info_name) {
        this->table[bucket] = current->next_syminfo_ptr;

        delete current;
        is_successful_delete = true;

        printing_info::_chain_index = 0;
    } else {
        // keep track of prev to connect chain after removing target.
        SymbolInfo* prev = nullptr;

        int idx = 0;
        while (current != nullptr) {
            if (current->get_name_str() == symbol_info_name) {
                break;
            }
            prev = current;
            current = current->next_syminfo_ptr;
            idx++;
        }

        if (current != nullptr) {
            prev->next_syminfo_ptr = current->next_syminfo_ptr;

            delete current;
            is_successful_delete = true;
            printing_info::_chain_index = idx;
        }
    }

    if (is_successful_delete) {
        cout << "Deleted Entry " << bucket << ", " << printing_info::_chain_index << " from current ScopeTable\n";
    } else {
        cout << "Not found\n";
    }

    return is_successful_delete;
}

int SymbolInfoHashTable::hash(const string& symbol_info_name) {
    unsigned long hash = 0;
    for (auto ch : symbol_info_name) {
        hash = ch + (hash << 6) + (hash << 16) - hash;
    }
    return hash % this->total_buckets;
}

void _print_chain(SymbolInfo* const symbol_info_ptr) {
    SymbolInfo* current = symbol_info_ptr;
    while (current != nullptr) {
        cout << "<" << current->get_name_str() << ", " << current->get_type_str() << ">  ";
        
        current = current->next_syminfo_ptr;
    }
}

void SymbolInfoHashTable::print() {
    const string INDENT = "\t\t";
    cout << endl;
    for (int i = 0; i < this->total_buckets; i++) {
        cout << INDENT;
        cout << "Bucket " << i << " : ";
        _print_chain(this->table[i]);
        cout << endl;
    }
}
