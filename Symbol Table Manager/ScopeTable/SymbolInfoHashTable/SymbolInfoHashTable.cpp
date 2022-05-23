#include "SymbolInfoHashTable.hpp"

using namespace std;

SymbolInfoPtr find_syminfo_name_in_chain(const string& name, SymbolInfoPtr chain_root) {
    SymbolInfoPtr current = chain_root;
    while (current != nullptr) {
        if (current->get_name_str() == name) {
            break;
        }
        current = current->next;
    }
    return current;
}

SymbolInfoHashTable::~SymbolInfoHashTable() {}

int SymbolInfoHashTable::get_num_buckets() {
    return this->total_buckets;
}

bool SymbolInfoHashTable::insert(const SymbolInfoPtr symbol_info_ptr) {
    // check for null TODO
    int bucket = this->hash(symbol_info_ptr->get_name_str());

    SymbolInfoPtr old_chain_root = this->table[bucket];

    SymbolInfoPtr collision = find_syminfo_name_in_chain(symbol_info_ptr->get_name_str(), old_chain_root);

    if (collision == nullptr) {
        // no collision
        this->table[bucket] = symbol_info_ptr;
        symbol_info_ptr->next = old_chain_root;

        return true;
    } else {
        collision->set_type_str(symbol_info_ptr->get_type_str());
        return false;
    }
}


SymbolInfoPtr SymbolInfoHashTable::lookup(const string symbol_name) {
    int bucket = this->hash(symbol_name);
    return find_syminfo_name_in_chain(symbol_name, this->table[bucket]);
}

bool SymbolInfoHashTable::delete_symbolinfo(const string symbol_name) {
    int bucket = this->hash(symbol_name);

    SymbolInfoPtr current = this->table[bucket];

    bool is_successful_delete = false;

    if (current != nullptr && current->get_name_str() == symbol_name) {
        this->table[bucket] = nullptr;
        is_successful_delete = true;
    } else {
        SymbolInfoPtr prev = nullptr;

        while (current != nullptr) {
            if (current->get_name_str() == symbol_name) {
                break;
            }
            current = current->next;
            prev = current;
        }

        if (current != nullptr) {
            prev->next = current->next;
            is_successful_delete = true;
        }
    }

    return is_successful_delete;
}

int SymbolInfoHashTable::hash(const string& symbol_name) {
    unsigned long hash = 0;
    for (auto ch : symbol_name) {
        hash = ch + (hash << 6) + (hash << 16) - hash;
    }
    return hash % this->total_buckets;
}

void print_chain(SymbolInfoPtr symbolinfo_ptr) {
    SymbolInfoPtr current = symbolinfo_ptr;
    while (current != nullptr) {
        cout << "<" << current->get_name_str() << ", " << current->get_type_str() << ">";
        if (current->next != nullptr) {
            cout << " -> ";
        }
        current = current->next;
    }
}

void SymbolInfoHashTable::print() {
    const string INDENT = "\t\t";
    cout << endl;
    for (int i = 0; i < this->total_buckets; i++) {
        cout << INDENT;
        cout << "Bucket " << i << " : ";
        print_chain(this->table[i]);
        cout << endl;
    }
}
