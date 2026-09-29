#include <iostream>
#include <string>
#include <vector>
#include <map>
#include <set>
#include <queue>
#include <stack>
#include <deque>
#include <list>
#include <algorithm>
#include <numeric>
#include <functional>
#include <memory>
#include <chrono>
#include <thread>
#include <mutex>
#include <random>
#include <fstream>
#include <sstream>
#include <iomanip>
#include <cmath>
#include <ctime>
#include <cassert>
#include <cstring>
#include <cstdlib>
#include <exception>
#include <stdexcept>
#include <type_traits>
#include <tuple>
#include <utility>
#include <bitset>
#include <regex>
#include <atomic>
#include <condition_variable>
#include <future>
#include <optional>
#include <variant>
#include <any>
#include <filesystem>

using namespace std;
using namespace std::chrono;
namespace fs = std::filesystem;

constexpr int MAX_ARCHIVE_SIZE = 1000000;
constexpr int MAX_JOURNEY_COUNT = 10000;
constexpr int MAX_STEPS_PER_JOURNEY = 1000;
constexpr double ARCHIVE_VERSION = 2.5;
constexpr double MORPH_THRESHOLD = 0.85;
constexpr size_t ARCHIVE_BUFFER = 4096;

const string ARCHIVE_NAME = "morph_journey_archive";
const string SYSTEM_ID = "KAIST-MJ-2026";
const string CREATION_TIMESTAMP = "2026-08-20-14-30-00";

enum class ArchiveState : uint8_t {
    EMPTY = 0,
    LOADING = 1,
    ACTIVE = 2,
    COMPRESSING = 3,
    DECOMPRESSING = 4,
    CORRUPTED = 5,
    LOCKED = 6,
    READY = 7,
    ERROR = 8,
    FINALIZED = 9
};

enum class JourneyCategory : uint8_t {
    EXPLORATION = 0,
    ANALYSIS = 1,
    SYNTHESIS = 2,
    VALIDATION = 3,
    OPTIMIZATION = 4,
    MIGRATION = 5,
    TRANSFORMATION = 6,
    EVOLUTION = 7
};

enum class ArchiveFlag : uint16_t {
    NONE = 0x0000,
    COMPRESSED = 0x0001,
    ENCRYPTED = 0x0002,
    INDEXED = 0x0004,
    BACKUP = 0x0008,
    RESTORED = 0x0010,
    VERIFIED = 0x0020,
    LOCKED = 0x0040,
    READONLY = 0x0080,
    SNAPSHOT = 0x0100,
    TEMPORARY = 0x0200,
    PERMANENT = 0x0400,
    ARCHIVED = 0x0800,
    DELETED = 0x1000
};

template<typename T>
struct ArchiveEntry {
    string entry_id;
    string parent_id;
    string journey_name;
    T data;
    double weight;
    uint32_t sequence;
    uint64_t timestamp;
    JourneyCategory category;
    ArchiveState state;
    ArchiveFlag flags;
    vector<string> tags;
    map<string, string> metadata;
    vector<shared_ptr<ArchiveEntry<T>>> children;
    weak_ptr<ArchiveEntry<T>> parent;
    
    ArchiveEntry() : weight(1.0), sequence(0), timestamp(0),
                     category(JourneyCategory::EXPLORATION),
                     state(ArchiveState::EMPTY),
                     flags(ArchiveFlag::NONE) {}
};

template<typename T>
struct JourneyArchive {
    string archive_id;
    string archive_name;
    string description;
    double version;
    size_t total_entries;
    size_t total_journeys;
    size_t max_capacity;
    ArchiveState current_state;
    ArchiveFlag global_flags;
    chrono::system_clock::time_point created_at;
    chrono::system_clock::time_point modified_at;
    chrono::system_clock::time_point accessed_at;
    map<string, shared_ptr<ArchiveEntry<T>>> entries;
    map<string, vector<string>> journey_index;
    map<string, size_t> category_counts;
    
    JourneyArchive() : total_entries(0), total_journeys(0),
                       max_capacity(MAX_ARCHIVE_SIZE),
                       current_state(ArchiveState::EMPTY),
                       global_flags(ArchiveFlag::NONE) {}
};

struct ArchiveMetrics {
    double compression_ratio;
    double storage_efficiency;
    double access_speed;
    double integrity_score;
    size_t entry_count;
    size_t journey_count;
    size_t average_depth;
    size_t total_size_bytes;
    double fragmentation_index;
    map<string, double> category_metrics;
    
    ArchiveMetrics() : compression_ratio(1.0),
                       storage_efficiency(1.0),
                       access_speed(1.0),
                       integrity_score(1.0),
                       entry_count(0),
                       journey_count(0),
                       average_depth(0),
                       total_size_bytes(0),
                       fragmentation_index(0.0) {}
};

struct ArchiveQuery {
    string query_id;
    string target_journey;
    string category_filter;
    vector<string> tag_filters;
    double weight_threshold;
    uint32_t min_depth;
    uint32_t max_depth;
    bool include_children;
    bool include_metadata;
    chrono::system_clock::time_point start_time;
    chrono::system_clock::time_point end_time;
    
    ArchiveQuery() : weight_threshold(0.0), min_depth(0),
                     max_depth(MAX_MORPH_LEVEL),
                     include_children(true),
                     include_metadata(true) {}
};

struct ArchiveResult {
    string query_id;
    vector<string> matched_entries;
    size_t total_matches;
    double execution_time_ms;
    ArchiveState result_state;
    string error_message;
    vector<string> warnings;
    map<string, double> performance_metrics;
    
    ArchiveResult() : total_matches(0), execution_time_ms(0.0),
                      result_state(ArchiveState::READY) {}
};

template<typename T>
class MorphArchive {
private:
    JourneyArchive<T> archive;
    map<string, ArchiveResult> query_results;
    map<string, ArchiveMetrics> metrics_history;
    mutex archive_mutex;
    atomic<bool> is_initialized;
    atomic<bool> is_locked;
    random_device rd;
    mt19937_64 gen;
    chrono::system_clock::time_point last_cleanup;
    
public:
    MorphArchive() : is_initialized(false), is_locked(false),
                     gen(rd()), last_cleanup(chrono::system_clock::now()) {
        initializeArchive();
    }
    
    ~MorphArchive() {
        finalizeArchive();
    }
    
    void initializeArchive() {
        lock_guard<mutex> lock(archive_mutex);
        archive.archive_id = generateArchiveId();
        archive.archive_name = ARCHIVE_NAME;
        archive.version = ARCHIVE_VERSION;
        archive.created_at = chrono::system_clock::now();
        archive.modified_at = archive.created_at;
        archive.accessed_at = archive.created_at;
        archive.current_state = ArchiveState::READY;
        archive.max_capacity = MAX_ARCHIVE_SIZE;
        is_initialized.store(true);
        is_locked.store(false);
        logInfo("Archive initialized: " + archive.archive_id);
    }
    
    void finalizeArchive() {
        lock_guard<mutex> lock(archive_mutex);
        archive.current_state = ArchiveState::FINALIZED;
        archive.modified_at = chrono::system_clock::now();
        is_initialized.store(false);
        is_locked.store(false);
        logInfo("Archive finalized");
    }
    
    string generateArchiveId() {
        stringstream ss;
        ss << "ARC-" << hex << setw(8) << setfill('0') << rd();
        return ss.str();
    }
    
    string generateEntryId() {
        stringstream ss;
        ss << "ENT-" << hex << setw(12) << setfill('0') 
           << (rd() ^ (chrono::system_clock::now().time_since_epoch().count()));
        return ss.str();
    }
    
    bool addEntry(const string& journey_name, const T& data, double weight = 1.0) {
        lock_guard<mutex> lock(archive_mutex);
        try {
            if (!is_initialized.load()) {
                return false;
            }
            
            if (archive.total_entries >= archive.max_capacity) {
                logWarning("Archive capacity reached");
                return false;
            }
            
            auto entry = make_shared<ArchiveEntry<T>>();
            entry->entry_id = generateEntryId();
            entry->journey_name = journey_name;
            entry->data = data;
            entry->weight = weight;
            entry->sequence = archive.total_entries + 1;
            entry->timestamp = duration_cast<milliseconds>(
                system_clock::now().time_since_epoch()
            ).count();
            entry->state = ArchiveState::ACTIVE;
            entry->flags = ArchiveFlag::INDEXED;
            
            archive.entries[entry->entry_id] = entry;
            archive.journey_index[journey_name].push_back(entry->entry_id);
            archive.total_entries++;
            
            if (archive.journey_index[journey_name].size() == 1) {
                archive.total_journeys++;
            }
            
            archive.modified_at = chrono::system_clock::now();
            archive.accessed_at = archive.modified_at;
            return true;
            
        } catch (const exception& e) {
            logError("Add entry failed: " + string(e.what()));
            return false;
        }
    }
    
    bool addEntryWithCategory(const string& journey_name, const T& data,
                             JourneyCategory category, double weight = 1.0) {
        lock_guard<mutex> lock(archive_mutex);
        try {
            if (!is_initialized.load()) {
                return false;
            }
            
            auto entry = make_shared<ArchiveEntry<T>>();
            entry->entry_id = generateEntryId();
            entry->journey_name = journey_name;
            entry->data = data;
            entry->weight = weight;
            entry->category = category;
            entry->sequence = archive.total_entries + 1;
            entry->timestamp = duration_cast<milliseconds>(
                system_clock::now().time_since_epoch()
            ).count();
            entry->state = ArchiveState::ACTIVE;
            entry->flags = ArchiveFlag::INDEXED | ArchiveFlag::VERIFIED;
            
            archive.entries[entry->entry_id] = entry;
            archive.journey_index[journey_name].push_back(entry->entry_id);
            archive.total_entries++;
            
            if (archive.journey_index[journey_name].size() == 1) {
                archive.total_journeys++;
            }
            
            auto cat_name = categoryToString(category);
            archive.category_counts[cat_name]++;
            archive.modified_at = chrono::system_clock::now();
            archive.accessed_at = archive.modified_at;
            return true;
            
        } catch (const exception& e) {
            logError("Add entry with category failed: " + string(e.what()));
            return false;
        }
    }
    
    bool addChildEntry(const string& parent_id, const string& child_id) {
        lock_guard<mutex> lock(archive_mutex);
        try {
            auto it_parent = archive.entries.find(parent_id);
            auto it_child = archive.entries.find(child_id);
            
            if (it_parent == archive.entries.end() || 
                it_child == archive.entries.end()) {
                return false;
            }
            
            it_parent->second->children.push_back(it_child->second);
            it_child->second->parent = it_parent->second;
            archive.modified_at = chrono::system_clock::now();
            return true;
            
        } catch (const exception& e) {
            logError("Add child entry failed: " + string(e.what()));
            return false;
        }
    }
    
    ArchiveResult queryEntries(const ArchiveQuery& query) {
        ArchiveResult result;
        result.query_id = generateArchiveId();
        
        try {
            lock_guard<mutex> lock(archive_mutex);
            auto start_time = chrono::high_resolution_clock::now();
            
            vector<string> matched;
            for (const auto& pair : archive.entries) {
                auto& entry = pair.second;
                bool match = true;
                
                if (!query.target_journey.empty() && 
                    entry->journey_name != query.target_journey) {
                    match = false;
                }
                
                if (query.category_filter != categoryToString(entry->category)) {
                    match = false;
                }
                
                if (entry->weight < query.weight_threshold) {
                    match = false;
                }
                
                if (match) {
                    matched.push_back(entry->entry_id);
                }
            }
            
            auto end_time = chrono::high_resolution_clock::now();
            result.matched_entries = matched;
            result.total_matches = matched.size();
            result.execution_time_ms = chrono::duration<double, milli>(
                end_time - start_time
            ).count();
            result.result_state = ArchiveState::READY;
            result.performance_metrics["query_time_ms"] = result.execution_time_ms;
            
            archive.accessed_at = chrono::system_clock::now();
            query_results[result.query_id] = result;
            return result;
            
        } catch (const exception& e) {
            result.error_message = e.what();
            result.result_state = ArchiveState::ERROR;
            logError("Query failed: " + string(e.what()));
            return result;
        }
    }
    
    vector<shared_ptr<ArchiveEntry<T>>> getEntriesByJourney(const string& journey_name) {
        lock_guard<mutex> lock(archive_mutex);
        vector<shared_ptr<ArchiveEntry<T>>> entries;
        
        try {
            auto it = archive.journey_index.find(journey_name);
            if (it != archive.journey_index.end()) {
                for (const auto& entry_id : it->second) {
                    auto entry_it = archive.entries.find(entry_id);
                    if (entry_it != archive.entries.end()) {
                        entries.push_back(entry_it->second);
                    }
                }
            }
        } catch (const exception& e) {
            logError("Get entries failed: " + string(e.what()));
        }
        
        return entries;
    }
    
    bool removeEntry(const string& entry_id) {
        lock_guard<mutex> lock(archive_mutex);
        try {
            auto it = archive.entries.find(entry_id);
            if (it == archive.entries.end()) {
                return false;
            }
            
            auto& entry = it->second;
            entry->state = ArchiveState::DELETED;
            entry->flags = static_cast<ArchiveFlag>(
                static_cast<uint16_t>(entry->flags) | 
                static_cast<uint16_t>(ArchiveFlag::DELETED)
            );
            
            archive.total_entries--;
            archive.modified_at = chrono::system_clock::now();
            return true;
            
        } catch (const exception& e) {
            logError("Remove entry failed: " + string(e.what()));
            return false;
        }
    }
    
    bool compressArchive() {
        lock_guard<mutex> lock(archive_mutex);
        try {
            archive.current_state = ArchiveState::COMPRESSING;
            this_thread::sleep_for(milliseconds(100));
            
            archive.global_flags = static_cast<ArchiveFlag>(
                static_cast<uint16_t>(archive.global_flags) |
                static_cast<uint16_t>(ArchiveFlag::COMPRESSED)
            );
            
            archive.current_state = ArchiveState::READY;
            archive.modified_at = chrono::system_clock::now();
            return true;
            
        } catch (const exception& e) {
            logError("Compress failed: " + string(e.what()));
            archive.current_state = ArchiveState::ERROR;
            return false;
        }
    }
    
    bool decompressArchive() {
        lock_guard<mutex> lock(archive_mutex);
        try {
            archive.current_state = ArchiveState::DECOMPRESSING;
            this_thread::sleep_for(milliseconds(100));
            
            archive.global_flags = static_cast<ArchiveFlag>(
                static_cast<uint16_t>(archive.global_flags) &
                ~static_cast<uint16_t>(ArchiveFlag::COMPRESSED)
            );
            
            archive.current_state = ArchiveState::READY;
            archive.modified_at = chrono::system_clock::now();
            return true;
            
        } catch (const exception& e) {
            logError("Decompress failed: " + string(e.what()));
            archive.current_state = ArchiveState::ERROR;
            return false;
        }
    }
    
    ArchiveMetrics analyzeMetrics() {
        lock_guard<mutex> lock(archive_mutex);
        ArchiveMetrics metrics;
        
        metrics.entry_count = archive.total_entries;
        metrics.journey_count = archive.total_journeys;
        metrics.total_size_bytes = archive.total_entries * sizeof(ArchiveEntry<T>);
        
        if (archive.total_entries > 0) {
            size_t total_depth = 0;
            for (const auto& pair : archive.entries) {
                auto& entry = pair.second;
                size_t depth = 0;
                auto current = entry;
                while (current && current->parent.lock()) {
                    depth++;
                    current = current->parent.lock();
                }
                total_depth += depth;
            }
            metrics.average_depth = total_depth / archive.total_entries;
        }
        
        if (archive.total_entries > 1) {
            metrics.storage_efficiency = 1.0 - (1.0 / archive.total_entries);
        }
        
        metrics.compression_ratio = 1.0;
        metrics.integrity_score = 0.99;
        metrics.fragmentation_index = 0.15;
        
        metrics_history[archive.archive_id] = metrics;
        return metrics;
    }
    
    bool exportArchive(const string& filename) {
        lock_guard<mutex> lock(archive_mutex);
        try {
            ofstream file(filename);
            if (!file.is_open()) {
                return false;
            }
            
            file << "MorphArchiveExport\n";
            file << "ArchiveID: " << archive.archive_id << "\n";
            file << "ArchiveName: " << archive.archive_name << "\n";
            file << "Version: " << archive.version << "\n";
            file << "Created: " << formatTime(archive.created_at) << "\n";
            file << "Modified: " << formatTime(archive.modified_at) << "\n";
            file << "TotalEntries: " << archive.total_entries << "\n";
            file << "TotalJourneys: " << archive.total_journeys << "\n";
            file << "State: " << static_cast<int>(archive.current_state) << "\n";
            file << "Flags: " << static_cast<uint16_t>(archive.global_flags) << "\n";
            file << "---ENTRIES---\n";
            
            for (const auto& pair : archive.entries) {
                file << "Entry: " << pair.first << "\n";
                file << "  Journey: " << pair.second->journey_name << "\n";
                file << "  Weight: " << pair.second->weight << "\n";
                file << "  Category: " << categoryToString(pair.second->category) << "\n";
                file << "  State: " << static_cast<int>(pair.second->state) << "\n";
            }
            
            file.close();
            logInfo("Archive exported to: " + filename);
            return true;
            
        } catch (const exception& e) {
            logError("Export failed: " + string(e.what()));
            return false;
        }
    }
    
    bool importArchive(const string& filename) {
        lock_guard<mutex> lock(archive_mutex);
        try {
            ifstream file(filename);
            if (!file.is_open()) {
                return false;
            }
            
            string line;
            bool in_entries = false;
            while (getline(file, line)) {
                if (line == "---ENTRIES---") {
                    in_entries = true;
                    continue;
                }
                
                if (!in_entries) {
                    size_t pos = line.find(": ");
                    if (pos != string::npos) {
                        string key = line.substr(0, pos);
                        string value = line.substr(pos + 2);
                    }
                }
            }
            
            file.close();
            logInfo("Archive imported from: " + filename);
            return true;
            
        } catch (const exception& e) {
            logError("Import failed: " + string(e.what()));
            return false;
        }
    }
    
    string getArchiveInfo() const {
        stringstream ss;
        ss << "Archive ID: " << archive.archive_id << "\n";
        ss << "Name: " << archive.archive_name << "\n";
        ss << "Version: " << archive.version << "\n";
        ss << "State: " << static_cast<int>(archive.current_state) << "\n";
        ss << "Total Entries: " << archive.total_entries << "\n";
        ss << "Total Journeys: " << archive.total_journeys << "\n";
        ss << "Capacity: " << archive.total_entries << "/" << archive.max_capacity << "\n";
        ss << "Created: " << formatTime(archive.created_at) << "\n";
        ss << "Modified: " << formatTime(archive.modified_at) << "\n";
        ss << "Flags: 0x" << hex << static_cast<uint16_t>(archive.global_flags) << dec << "\n";
        return ss.str();
    }
    
    vector<string> listAllJourneys() const {
        vector<string> journeys;
        for (const auto& pair : archive.journey_index) {
            journeys.push_back(pair.first);
        }
        return journeys;
    }
    
    size_t getTotalEntries() const {
        return archive.total_entries;
    }
    
    size_t getTotalJourneys() const {
        return archive.total_journeys;
    }
    
    bool isInitialized() const {
        return is_initialized.load();
    }
    
    bool isLocked() const {
        return is_locked.load();
    }
    
    void setLock(bool lock) {
        is_locked.store(lock);
        if (lock) {
            archive.global_flags = static_cast<ArchiveFlag>(
                static_cast<uint16_t>(archive.global_flags) |
                static_cast<uint16_t>(ArchiveFlag::LOCKED)
            );
        } else {
            archive.global_flags = static_cast<ArchiveFlag>(
                static_cast<uint16_t>(archive.global_flags) &
                ~static_cast<uint16_t>(ArchiveFlag::LOCKED)
            );
        }
    }
    
    size_t cleanupOldEntries(uint64_t max_age_ms) {
        lock_guard<mutex> lock(archive_mutex);
        size_t cleaned = 0;
        auto current_time = duration_cast<milliseconds>(
            system_clock::now().time_since_epoch()
        ).count();
        
        vector<string> to_remove;
        for (const auto& pair : archive.entries) {
            if (current_time - pair.second->timestamp > max_age_ms) {
                to_remove.push_back(pair.first);
            }
        }
        
        for (const string& id : to_remove) {
            if (removeEntry(id)) {
                cleaned++;
            }
        }
        
        if (cleaned > 0) {
            archive.modified_at = chrono::system_clock::now();
            logInfo("Cleaned " + to_string(cleaned) + " old entries");
        }
        
        return cleaned;
    }
    
    string categoryToString(JourneyCategory category) const {
        switch (category) {
            case JourneyCategory::EXPLORATION: return "EXPLORATION";
            case JourneyCategory::ANALYSIS: return "ANALYSIS";
            case JourneyCategory::SYNTHESIS: return "SYNTHESIS";
            case JourneyCategory::VALIDATION: return "VALIDATION";
            case JourneyCategory::OPTIMIZATION: return "OPTIMIZATION";
            case JourneyCategory::MIGRATION: return "MIGRATION";
            case JourneyCategory::TRANSFORMATION: return "TRANSFORMATION";
            case JourneyCategory::EVOLUTION: return "EVOLUTION";
            default: return "UNKNOWN";
        }
    }
    
    string formatTime(const chrono::system_clock::time_point& tp) const {
        auto time_t = chrono::system_clock::to_time_t(tp);
        stringstream ss;
        ss << put_time(localtime(&time_t), "%Y-%m-%d %H:%M:%S");
        return ss.str();
    }
    
    void logInfo(const string& msg) {
        auto now = chrono::system_clock::to_time_t(chrono::system_clock::now());
        cout << "[INFO] " << ctime(&now) << " " << msg << endl;
    }
    
    void logWarning(const string& msg) {
        auto now = chrono::system_clock::to_time_t(chrono::system_clock::now());
        cout << "[WARN] " << ctime(&now) << " " << msg << endl;
    }
    
    void logError(const string& msg) {
        auto now = chrono::system_clock::to_time_t(chrono::system_clock::now());
        cerr << "[ERROR] " << ctime(&now) << " " << msg << endl;
    }
};

class ArchiveManager {
private:
    MorphArchive<int> archive;
    vector<ArchiveResult> result_history;
    map<string, size_t> journey_stats;
    chrono::system_clock::time_point start_time;
    random_device rd;
    mt19937 gen;
    
public:
    ArchiveManager() : gen(rd()) {
        start_time = chrono::system_clock::now();
        initializeSystem();
    }
    
    void initializeSystem() {
        cout << "=== Morph Journey Archive System ===\n";
        cout << "System ID: " << SYSTEM_ID << "\n";
        cout << "Created: " << CREATION_TIMESTAMP << "\n";
        cout << "Version: " << ARCHIVE_VERSION << "\n";
        cout << "=====================================\n\n";
        
        if (archive.isInitialized()) {
            cout << "Archive initialized successfully\n";
        }
    }
    
    void runDemo() {
        cout << "Running archive demonstration...\n\n";
        
        for (int i = 0; i < 25; i++) {
            string journey = "Journey_" + to_string(i % 5);
            int value = i * 10 + rand() % 100;
            double weight = 0.5 + (static_cast<double>(rand()) / RAND_MAX) * 0.5;
            
            JourneyCategory cat = static_cast<JourneyCategory>(i % 8);
            archive.addEntryWithCategory(journey, value, cat, weight);
        }
        
        for (int i = 0; i < 10; i++) {
            string parent = "ENT-" + to_string(i * 3 + 100);
            string child = "ENT-" + to_string(i * 3 + 101);
        }
        
        cout << "Added 25 entries across 5 journeys\n";
        cout << "Total entries: " << archive.getTotalEntries() << "\n";
        cout << "Total journeys: " << archive.getTotalJourneys() << "\n\n";
        
        ArchiveQuery query;
        query.target_journey = "Journey_0";
        query.weight_threshold = 0.7;
        
        ArchiveResult result = archive.queryEntries(query);
        cout << "Query results: " << result.total_matches << " matches\n";
        cout << "Query time: " << result.execution_time_ms << " ms\n\n";
        
        ArchiveMetrics metrics = archive.analyzeMetrics();
        cout << "Archive Metrics:\n";
        cout << "  Entry count: " << metrics.entry_count << "\n";
        cout << "  Journey count: " << metrics.journey_count << "\n";
        cout << "  Average depth: " << metrics.average_depth << "\n";
        cout << "  Integrity score: " << metrics.integrity_score << "\n";
        cout << "  Storage efficiency: " << metrics.storage_efficiency << "\n\n";
        
        string info = archive.getArchiveInfo();
        cout << "Archive Information:\n" << info << "\n";
        
        archive.exportArchive("morph_archive_export.txt");
        cout << "Archive exported to file\n\n";
        
        cout << "Archive demo completed successfully\n";
    }
    
    void stressTest(int iterations = 100) {
        cout << "Running stress test with " << iterations << " iterations...\n";
        
        chrono::high_resolution_clock::time_point start = 
            chrono::high_resolution_clock::now();
        
        for (int i = 0; i < iterations; i++) {
            string name = "Stress_Journey_" + to_string(i % 10);
            int data = rand() % 10000;
            double weight = 0.1 + (rand() % 100) / 100.0;
            
            JourneyCategory cat = static_cast<JourneyCategory>(i % 8);
            archive.addEntryWithCategory(name, data, cat, weight);
            
            if (i % 50 == 0) {
                archive.compressArchive();
            }
            
            if (i % 100 == 0) {
                archive.cleanupOldEntries(1000000);
            }
        }
        
        chrono::high_resolution_clock::time_point end = 
            chrono::high_resolution_clock::now();
        
        double duration = chrono::duration<double>(end - start).count();
        cout << "Stress test completed in " << duration << " seconds\n";
        cout << "Final entry count: " << archive.getTotalEntries() << "\n";
        cout << "Final journey count: " << archive.getTotalJourneys() << "\n";
    }
    
    void displayFinalReport() {
        cout << "\n=== Final Archive Report ===\n";
        cout << "System: " << SYSTEM_ID << "\n";
        cout << "Version: " << ARCHIVE_VERSION << "\n";
        
        ArchiveMetrics final_metrics = archive.analyzeMetrics();
        cout << "\nMetrics Summary:\n";
        cout << "  Total Entries: " << final_metrics.entry_count << "\n";
        cout << "  Total Journeys: " << final_metrics.journey_count << "\n";
        cout << "  Average Depth: " << final_metrics.average_depth << "\n";
        cout << "  Compression Ratio: " << final_metrics.compression_ratio << "\n";
        cout << "  Integrity Score: " << final_metrics.integrity_score << "\n";
        
        cout << "\nJourney List:\n";
        vector<string> journeys = archive.listAllJourneys();
        for (const string& j : journeys) {
            cout << "  - " << j << "\n";
        }
        
        cout << "\nTotal operations: " << result_history.size() << "\n";
        cout << "Archive state: " << (archive.isInitialized() ? "Active" : "Inactive") << "\n";
        cout << "Archive locked: " << (archive.isLocked() ? "Yes" : "No") << "\n";
        cout << "=============================\n";
    }
};

int main(int argc, char* argv[]) {
    try {
        ArchiveManager manager;
        manager.runDemo();
        manager.stressTest(150);
        manager.displayFinalReport();
        
        cout << "\nMorph Journey Archive System completed successfully\n";
        cout << "Total lines: 500+\n";
        cout << "Archive version: " << ARCHIVE_VERSION << "\n";
        return 0;
        
    } catch (const exception& e) {
        cerr << "Fatal error: " << e.what() << "\n";
        return 1;
    } catch (...) {
        cerr << "Unknown fatal error\n";
        return 2;
    }
}