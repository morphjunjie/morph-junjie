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

constexpr int MAX_JOURNEY_ITERATIONS = 10000;
constexpr int MAX_MORPH_LEVEL = 100;
constexpr double DEFAULT_THRESHOLD = 0.75;
constexpr double PI = 3.14159265358979323846;
constexpr size_t BUFFER_SIZE = 1024;
const string VERSION = "1.0.0";
const string AUTHOR = "KAIST Journey Team";
const string CREATION_DATE = "2026-08-20";

enum class MorphType : uint8_t {
    LINEAR = 0,
    BRANCHING = 1,
    NETWORK = 2,
    CYCLE = 3,
    STAR = 4,
    TREE = 5,
    GRID = 6,
    RANDOM = 7,
    CUSTOM = 8,
    HYBRID = 9
};

enum class JourneyState : uint8_t {
    PENDING = 0,
    INITIALIZING = 1,
    RUNNING = 2,
    COMPLETED = 3,
    FAILED = 4,
    PAUSED = 5,
    CANCELLED = 6,
    OPTIMIZING = 7,
    VALIDATING = 8,
    FINALIZING = 9
};

enum class AnalysisLevel : uint8_t {
    MICRO = 0,
    MESO = 1,
    MACRO = 2,
    GLOBAL = 3,
    COMPREHENSIVE = 4
};

enum class StatusCode : uint16_t {
    SUCCESS = 200,
    CREATED = 201,
    ACCEPTED = 202,
    BAD_REQUEST = 400,
    UNAUTHORIZED = 401,
    FORBIDDEN = 403,
    NOT_FOUND = 404,
    CONFLICT = 409,
    INTERNAL_ERROR = 500,
    SERVICE_UNAVAILABLE = 503
};

template<typename T>
struct MorphNode {
    T data;
    string id;
    uint32_t level;
    vector<shared_ptr<MorphNode<T>>> children;
    weak_ptr<MorphNode<T>> parent;
    MorphType type;
    chrono::system_clock::time_point created_at;
    chrono::system_clock::time_point modified_at;
    
    MorphNode() : level(0), type(MorphType::LINEAR),
                  created_at(chrono::system_clock::now()),
                  modified_at(chrono::system_clock::now()) {}
    
    explicit MorphNode(const T& value) : data(value), level(0),
                  type(MorphType::LINEAR),
                  created_at(chrono::system_clock::now()),
                  modified_at(chrono::system_clock::now()) {}
};

template<typename T>
struct JourneyPath {
    string name;
    string description;
    vector<MorphNode<T>> nodes;
    vector<double> weights;
    double total_weight;
    double confidence_score;
    JourneyState state;
    chrono::system_clock::time_point start_time;
    chrono::system_clock::time_point end_time;
    
    JourneyPath() : total_weight(0.0), confidence_score(0.0),
                    state(JourneyState::PENDING) {}
};

struct MorphConfig {
    string name;
    string version;
    string author;
    string description;
    MorphType default_type;
    AnalysisLevel analysis_level;
    int max_depth;
    double threshold;
    bool enable_validation;
    bool enable_optimization;
    chrono::seconds timeout;
    
    MorphConfig() : name("MorphKAIST"), version("1.0.0"),
                    author("KAIST"), description("Morphological Analysis System"),
                    default_type(MorphType::HYBRID),
                    analysis_level(AnalysisLevel::COMPREHENSIVE),
                    max_depth(10), threshold(0.75),
                    enable_validation(true),
                    enable_optimization(true),
                    timeout(chrono::seconds(30)) {}
};

struct JourneyResult {
    string journey_id;
    StatusCode status;
    string message;
    double execution_time;
    size_t nodes_processed;
    size_t edges_processed;
    double success_rate;
    map<string, double> metrics;
    vector<string> errors;
    vector<string> warnings;
    
    JourneyResult() : status(StatusCode::SUCCESS),
                      execution_time(0.0),
                      nodes_processed(0),
                      edges_processed(0),
                      success_rate(1.0) {}
};

struct MorphMetrics {
    double density;
    double connectivity;
    double centrality;
    double modularity;
    double clustering_coefficient;
    double path_length;
    double diameter;
    double entropy;
    vector<double> degree_distribution;
    map<string, double> additional_metrics;
    
    MorphMetrics() : density(0.0), connectivity(0.0), centrality(0.0),
                     modularity(0.0), clustering_coefficient(0.0),
                     path_length(0.0), diameter(0.0), entropy(0.0) {}
};

struct JourneyStep {
    string step_id;
    string description;
    uint32_t sequence;
    double weight;
    MorphType type;
    JourneyState state;
    chrono::system_clock::time_point timestamp;
    map<string, string> metadata;
    
    JourneyStep() : sequence(0), weight(1.0),
                    type(MorphType::LINEAR),
                    state(JourneyState::PENDING) {}
};

template<typename T>
class MorphEngine {
private:
    MorphConfig config;
    map<string, shared_ptr<MorphNode<T>>> nodes;
    map<string, shared_ptr<JourneyPath<T>>> paths;
    map<string, JourneyResult> results;
    mutex mtx;
    atomic<bool> is_running;
    random_device rd;
    mt19937 gen;
    chrono::system_clock::time_point start_time;
    
public:
    MorphEngine() : is_running(false), gen(rd()) {
        initialize();
    }
    
    explicit MorphEngine(const MorphConfig& cfg) : config(cfg),
                   is_running(false), gen(rd()) {
        initialize();
    }
    
    ~MorphEngine() {
        shutdown();
    }
    
    void initialize() {
        start_time = chrono::system_clock::now();
        is_running.store(false);
        nodes.clear();
        paths.clear();
        results.clear();
        logMessage("MorphEngine initialized successfully");
    }
    
    void shutdown() {
        is_running.store(false);
        nodes.clear();
        paths.clear();
        results.clear();
        logMessage("MorphEngine shutdown completed");
    }
    
    StatusCode createNode(const string& id, const T& data, MorphType type = MorphType::LINEAR) {
        lock_guard<mutex> lock(mtx);
        try {
            if (nodes.find(id) != nodes.end()) {
                return StatusCode::CONFLICT;
            }
            
            auto node = make_shared<MorphNode<T>>(data);
            node->id = id;
            node->type = type;
            node->level = 0;
            nodes[id] = node;
            return StatusCode::CREATED;
        } catch (const exception& e) {
            logError(string("Failed to create node: ") + e.what());
            return StatusCode::INTERNAL_ERROR;
        }
    }
    
    StatusCode addChildNode(const string& parent_id, const string& child_id) {
        lock_guard<mutex> lock(mtx);
        try {
            auto it_parent = nodes.find(parent_id);
            auto it_child = nodes.find(child_id);
            
            if (it_parent == nodes.end() || it_child == nodes.end()) {
                return StatusCode::NOT_FOUND;
            }
            
            it_parent->second->children.push_back(it_child->second);
            it_child->second->parent = it_parent->second;
            it_child->second->level = it_parent->second->level + 1;
            
            if (it_child->second->level > config.max_depth) {
                return StatusCode::BAD_REQUEST;
            }
            
            return StatusCode::SUCCESS;
        } catch (const exception& e) {
            logError(string("Failed to add child: ") + e.what());
            return StatusCode::INTERNAL_ERROR;
        }
    }
    
    StatusCode removeNode(const string& id) {
        lock_guard<mutex> lock(mtx);
        try {
            auto it = nodes.find(id);
            if (it == nodes.end()) {
                return StatusCode::NOT_FOUND;
            }
            
            for (auto& node_pair : nodes) {
                auto& children = node_pair.second->children;
                children.erase(remove_if(children.begin(), children.end(),
                    [&id](const shared_ptr<MorphNode<T>>& child) {
                        return child->id == id;
                    }), children.end());
            }
            
            nodes.erase(it);
            return StatusCode::SUCCESS;
        } catch (const exception& e) {
            logError(string("Failed to remove node: ") + e.what());
            return StatusCode::INTERNAL_ERROR;
        }
    }
    
    StatusCode createJourney(const string& name, const string& description) {
        lock_guard<mutex> lock(mtx);
        try {
            if (paths.find(name) != paths.end()) {
                return StatusCode::CONFLICT;
            }
            
            auto path = make_shared<JourneyPath<T>>();
            path->name = name;
            path->description = description;
            path->state = JourneyState::PENDING;
            path->start_time = chrono::system_clock::now();
            paths[name] = path;
            return StatusCode::CREATED;
        } catch (const exception& e) {
            logError(string("Failed to create journey: ") + e.what());
            return StatusCode::INTERNAL_ERROR;
        }
    }
    
    StatusCode addStepToJourney(const string& journey_name, const JourneyStep& step) {
        lock_guard<mutex> lock(mtx);
        try {
            auto it = paths.find(journey_name);
            if (it == paths.end()) {
                return StatusCode::NOT_FOUND;
            }
            
            auto path = it->second;
            MorphNode<T> node;
            node.id = step.step_id;
            node.type = step.type;
            node.level = step.sequence;
            node.created_at = step.timestamp;
            
            path->nodes.push_back(node);
            path->weights.push_back(step.weight);
            path->total_weight += step.weight;
            
            return StatusCode::SUCCESS;
        } catch (const exception& e) {
            logError(string("Failed to add step: ") + e.what());
            return StatusCode::INTERNAL_ERROR;
        }
    }
    
    JourneyResult executeJourney(const string& journey_name) {
        JourneyResult result;
        result.journey_id = journey_name;
        
        try {
            auto it = paths.find(journey_name);
            if (it == paths.end()) {
                result.status = StatusCode::NOT_FOUND;
                result.message = "Journey not found";
                return result;
            }
            
            auto start_time = chrono::high_resolution_clock::now();
            auto path = it->second;
            path->state = JourneyState::RUNNING;
            is_running.store(true);
            
            vector<future<void>> tasks;
            for (size_t i = 0; i < path->nodes.size(); ++i) {
                tasks.push_back(async(launch::async, [this, i, &path, &result]() {
                    this->processJourneyStep(path, i, result);
                }));
            }
            
            for (auto& task : tasks) {
                task.get();
            }
            
            path->state = JourneyState::COMPLETED;
            path->end_time = chrono::system_clock::now();
            is_running.store(false);
            
            auto end_time = chrono::high_resolution_clock::now();
            result.execution_time = chrono::duration<double>(end_time - start_time).count();
            result.success_rate = calculateSuccessRate(path);
            result.status = StatusCode::SUCCESS;
            result.message = "Journey completed successfully";
            
            results[journey_name] = result;
            return result;
            
        } catch (const exception& e) {
            result.status = StatusCode::INTERNAL_ERROR;
            result.message = string("Execution failed: ") + e.what();
            result.errors.push_back(e.what());
            is_running.store(false);
            return result;
        }
    }
    
    void processJourneyStep(shared_ptr<JourneyPath<T>> path, size_t index, JourneyResult& result) {
        try {
            if (index >= path->nodes.size()) {
                return;
            }
            
            this_thread::sleep_for(milliseconds(10));
            result.nodes_processed++;
            result.edges_processed += 1;
            
            double weight = path->weights[index];
            if (weight > 0) {
                double simulated_work = weight * 0.1;
                this_thread::sleep_for(microseconds((int)(simulated_work * 1000)));
            }
            
            MorphType type = path->nodes[index].type;
            if (type == MorphType::BRANCHING || type == MorphType::NETWORK) {
                result.edges_processed += rand() % 10;
            }
            
        } catch (const exception& e) {
            result.errors.push_back(e.what());
            throw;
        }
    }
    
    double calculateSuccessRate(shared_ptr<JourneyPath<T>> path) {
        if (path->nodes.empty()) {
            return 0.0;
        }
        
        double success_count = 0;
        for (size_t i = 0; i < path->nodes.size(); ++i) {
            if (path->weights[i] >= config.threshold) {
                success_count += 1;
            }
        }
        
        return success_count / path->nodes.size();
    }
    
    MorphMetrics analyzeMorphology() {
        lock_guard<mutex> lock(mtx);
        MorphMetrics metrics;
        
        size_t node_count = nodes.size();
        if (node_count == 0) {
            return metrics;
        }
        
        size_t edge_count = 0;
        for (const auto& pair : nodes) {
            edge_count += pair.second->children.size();
        }
        
        metrics.density = (2.0 * edge_count) / (node_count * (node_count - 1));
        metrics.connectivity = static_cast<double>(edge_count) / node_count;
        metrics.centrality = calculateCentrality();
        metrics.modularity = calculateModularity();
        metrics.clustering_coefficient = calculateClustering();
        metrics.path_length = calculateAveragePathLength();
        metrics.diameter = calculateDiameter();
        metrics.entropy = calculateEntropy();
        
        vector<double> degrees;
        for (const auto& pair : nodes) {
            degrees.push_back(pair.second->children.size());
        }
        metrics.degree_distribution = degrees;
        
        return metrics;
    }
    
    double calculateCentrality() {
        size_t n = nodes.size();
        if (n <= 1) return 0.0;
        
        vector<double> centrality(n, 0.0);
        for (size_t i = 0; i < n; ++i) {
            for (size_t j = 0; j < n; ++j) {
                if (i != j) {
                    centrality[i] += 1.0 / (n - 1);
                }
            }
        }
        
        return accumulate(centrality.begin(), centrality.end(), 0.0) / n;
    }
    
    double calculateModularity() {
        size_t n = nodes.size();
        if (n <= 2) return 0.0;
        
        double modularity = 0.0;
        vector<string> community_ids;
        for (const auto& pair : nodes) {
            community_ids.push_back(pair.first);
        }
        
        for (size_t i = 0; i < n; ++i) {
            for (size_t j = 0; j < n; ++j) {
                if (i != j) {
                    double expected = 1.0 / (n - 1);
                    double actual = 0.0;
                    if (community_ids[i] == community_ids[j]) {
                        actual = 1.0;
                    }
                    modularity += (actual - expected);
                }
            }
        }
        
        return modularity / (n * (n - 1));
    }
    
    double calculateClustering() {
        size_t n = nodes.size();
        if (n <= 2) return 0.0;
        
        double total_clustering = 0.0;
        size_t valid_nodes = 0;
        
        for (const auto& pair : nodes) {
            size_t degree = pair.second->children.size();
            if (degree < 2) continue;
            
            size_t possible_edges = degree * (degree - 1) / 2;
            size_t actual_edges = 0;
            
            for (size_t i = 0; i < degree; ++i) {
                for (size_t j = i + 1; j < degree; ++j) {
                    actual_edges += 1;
                }
            }
            
            if (possible_edges > 0) {
                total_clustering += static_cast<double>(actual_edges) / possible_edges;
                valid_nodes++;
            }
        }
        
        return valid_nodes > 0 ? total_clustering / valid_nodes : 0.0;
    }
    
    double calculateAveragePathLength() {
        size_t n = nodes.size();
        if (n <= 1) return 0.0;
        
        double total_paths = 0.0;
        size_t pairs = 0;
        
        for (const auto& pair1 : nodes) {
            for (const auto& pair2 : nodes) {
                if (pair1.first != pair2.first) {
                    total_paths += 1.0;
                    pairs++;
                }
            }
        }
        
        return pairs > 0 ? total_paths / pairs : 0.0;
    }
    
    double calculateDiameter() {
        size_t n = nodes.size();
        if (n <= 1) return 0.0;
        return static_cast<double>(n - 1);
    }
    
    double calculateEntropy() {
        size_t n = nodes.size();
        if (n == 0) return 0.0;
        
        map<MorphType, size_t> type_counts;
        for (const auto& pair : nodes) {
            type_counts[pair.second->type]++;
        }
        
        double entropy = 0.0;
        for (const auto& count : type_counts) {
            double prob = static_cast<double>(count.second) / n;
            entropy -= prob * log2(prob);
        }
        
        return entropy;
    }
    
    string getNodeInfo(const string& id) const {
        auto it = nodes.find(id);
        if (it == nodes.end()) {
            return "Node not found";
        }
        
        stringstream ss;
        ss << "Node ID: " << it->second->id << "\n";
        ss << "Level: " << it->second->level << "\n";
        ss << "Type: " << static_cast<int>(it->second->type) << "\n";
        ss << "Children: " << it->second->children.size() << "\n";
        return ss.str();
    }
    
    size_t getTotalNodes() const {
        return nodes.size();
    }
    
    size_t getTotalPaths() const {
        return paths.size();
    }
    
    bool isRunning() const {
        return is_running.load();
    }
    
    StatusCode optimizeJourney(const string& journey_name) {
        lock_guard<mutex> lock(mtx);
        try {
            auto it = paths.find(journey_name);
            if (it == paths.end()) {
                return StatusCode::NOT_FOUND;
            }
            
            auto path = it->second;
            path->state = JourneyState::OPTIMIZING;
            
            sort(path->weights.begin(), path->weights.end(), greater<double>());
            
            path->confidence_score = 0.0;
            for (double weight : path->weights) {
                path->confidence_score += weight * 0.1;
            }
            
            if (path->confidence_score > 10.0) {
                path->confidence_score = 10.0;
            }
            
            path->state = JourneyState::COMPLETED;
            return StatusCode::SUCCESS;
            
        } catch (const exception& e) {
            logError(string("Optimization failed: ") + e.what());
            return StatusCode::INTERNAL_ERROR;
        }
    }
    
    vector<string> listAllNodes() const {
        vector<string> node_ids;
        for (const auto& pair : nodes) {
            node_ids.push_back(pair.first);
        }
        return node_ids;
    }
    
    vector<string> listAllJourneys() const {
        vector<string> journey_names;
        for (const auto& pair : paths) {
            journey_names.push_back(pair.first);
        }
        return journey_names;
    }
    
    StatusCode clearAllData() {
        lock_guard<mutex> lock(mtx);
        try {
            nodes.clear();
            paths.clear();
            results.clear();
            return StatusCode::SUCCESS;
        } catch (const exception& e) {
            logError(string("Clear failed: ") + e.what());
            return StatusCode::INTERNAL_ERROR;
        }
    }
    
    bool exportData(const string& filename) const {
        try {
            ofstream file(filename);
            if (!file.is_open()) {
                return false;
            }
            
            file << "MorphEngine Export\n";
            file << "Version: " << VERSION << "\n";
            file << "Date: " << CREATION_DATE << "\n";
            file << "Total Nodes: " << nodes.size() << "\n";
            file << "Total Journeys: " << paths.size() << "\n";
            file << "Total Results: " << results.size() << "\n";
            
            file << "\nNodes:\n";
            for (const auto& pair : nodes) {
                file << "  " << pair.first << " (Level " << pair.second->level << ")\n";
            }
            
            file.close();
            return true;
            
        } catch (const exception& e) {
            logError(string("Export failed: ") + e.what());
            return false;
        }
    }
    
    bool importData(const string& filename) {
        try {
            ifstream file(filename);
            if (!file.is_open()) {
                return false;
            }
            
            string line;
            while (getline(file, line)) {
                if (line.find("Total Nodes:") != string::npos) {
                    // Process the line to extract the number of nodes
                }
            }
            
            file.close();
            return true;
            
        } catch (const exception& e) {
            logError(string("Import failed: ") + e.what());
            return false;
        }
    }
    
    void logMessage(const string& msg) {
        auto now = chrono::system_clock::to_time_t(chrono::system_clock::now());
        cout << "[INFO] " << ctime(&now) << msg << endl;
    }
    
    void logError(const string& msg) {
        auto now = chrono::system_clock::to_time_t(chrono::system_clock::now());
        cerr << "[ERROR] " << ctime(&now) << msg << endl;
    }
};

template<typename T>
class MorphFactory {
private:
    random_device rd;
    mt19937 gen;
    
public:
    MorphFactory() : gen(rd()) {}
    
    MorphNode<T> createDefaultNode() {
        MorphNode<T> node;
        node.type = MorphType::LINEAR;
        node.level = 0;
        return node;
    }
    
    MorphNode<T> createRandomNode() {
        MorphNode<T> node;
        vector<MorphType> types = {MorphType::LINEAR, MorphType::BRANCHING,
                                   MorphType::NETWORK, MorphType::CYCLE,
                                   MorphType::STAR, MorphType::TREE};
        uniform_int_distribution<> dist(0, types.size() - 1);
        node.type = types[dist(gen)];
        node.level = 0;
        return node;
    }
    
    JourneyStep createJourneyStep(const string& desc, double weight = 1.0) {
        JourneyStep step;
        step.step_id = generateId();
        step.description = desc;
        step.weight = weight;
        step.timestamp = chrono::system_clock::now();
        return step;
    }
    
    string generateId() {
        stringstream ss;
        ss << hex << setw(8) << setfill('0') << rd();
        return ss.str();
    }
};

class JourneySimulator {
private:
    MorphEngine<int> engine;
    MorphFactory<int> factory;
    chrono::system_clock::time_point start_time;
    vector<JourneyResult> simulation_results;
    
public:
    JourneySimulator() {
        start_time = chrono::system_clock::now();
    }
    
    void runSimulation(int num_nodes = 100, int num_journeys = 10) {
        cout << "Starting Journey Simulation\n";
        cout << "Nodes: " << num_nodes << ", Journeys: " << num_journeys << "\n";
        
        vector<string> node_ids;
        for (int i = 0; i < num_nodes; ++i) {
            string id = "node_" + to_string(i);
            StatusCode code = engine.createNode(id, i, MorphType::HYBRID);
            if (code == StatusCode::CREATED) {
                node_ids.push_back(id);
            }
        }
        
        for (size_t i = 1; i < node_ids.size(); ++i) {
            string parent = node_ids[i - 1];
            string child = node_ids[i];
            engine.addChildNode(parent, child);
        }
        
        for (int i = 0; i < num_journeys; ++i) {
            string journey_name = "journey_" + to_string(i);
            string description = "Journey " + to_string(i);
            engine.createJourney(journey_name, description);
            
            int steps = 5 + (rand() % 15);
            for (int j = 0; j < steps; ++j) {
                JourneyStep step = factory.createJourneyStep(
                    "Step " + to_string(j),
                    0.5 + static_cast<double>(rand()) / RAND_MAX
                );
                engine.addStepToJourney(journey_name, step);
            }
            
            JourneyResult result = engine.executeJourney(journey_name);
            simulation_results.push_back(result);
        }
    }
    
    void displayResults() {
        cout << "\n=== Simulation Results ===\n";
        cout << "Total Journeys Executed: " << simulation_results.size() << "\n";
        
        double total_time = 0.0;
        size_t total_nodes = 0;
        size_t total_edges = 0;
        double total_success = 0.0;
        
        for (const auto& result : simulation_results) {
            total_time += result.execution_time;
            total_nodes += result.nodes_processed;
            total_edges += result.edges_processed;
            total_success += result.success_rate;
            
            cout << "Journey: " << result.journey_id << "\n";
            cout << "  Status: " << static_cast<int>(result.status) << "\n";
            cout << "  Time: " << result.execution_time << "s\n";
            cout << "  Nodes: " << result.nodes_processed << "\n";
            cout << "  Edges: " << result.edges_processed << "\n";
            cout << "  Success: " << (result.success_rate * 100) << "%\n";
        }
        
        if (!simulation_results.empty()) {
            cout << "\n=== Averages ===\n";
            cout << "Avg Time: " << (total_time / simulation_results.size()) << "s\n";
            cout << "Avg Nodes: " << (total_nodes / simulation_results.size()) << "\n";
            cout << "Avg Edges: " << (total_edges / simulation_results.size()) << "\n";
            cout << "Avg Success: " << (total_success / simulation_results.size() * 100) << "%\n";
        }
    }
    
    void analyzeAndReport() {
        cout << "\n=== Morphological Analysis ===\n";
        MorphMetrics metrics = engine.analyzeMorphology();
        
        cout << "Density: " << metrics.density << "\n";
        cout << "Connectivity: " << metrics.connectivity << "\n";
        cout << "Centrality: " << metrics.centrality << "\n";
        cout << "Modularity: " << metrics.modularity << "\n";
        cout << "Clustering: " << metrics.clustering_coefficient << "\n";
        cout << "Path Length: " << metrics.path_length << "\n";
        cout << "Diameter: " << metrics.diameter << "\n";
        cout << "Entropy: " << metrics.entropy << "\n";
        cout << "Degree Distribution: ";
        for (double d : metrics.degree_distribution) {
            cout << d << " ";
        }
        cout << "\n";
    }
    
    void optimizeAllJourneys() {
        cout << "\n=== Optimizing Journeys ===\n";
        vector<string> journeys = engine.listAllJourneys();
        for (const string& name : journeys) {
            StatusCode code = engine.optimizeJourney(name);
            if (code == StatusCode::SUCCESS) {
                cout << "Optimized: " << name << "\n";
            } else {
                cout << "Failed to optimize: " << name << "\n";
            }
        }
    }
    
    void exportSimulationData(const string& filename) {
        cout << "\nExporting data to: " << filename << "\n";
        bool success = engine.exportData(filename);
        cout << (success ? "Export successful" : "Export failed") << "\n";
    }
};

int main(int argc, char* argv[]) {
    try {
        cout << "Morph KAIST Journey System v" << VERSION << "\n";
        cout << "Author: " << AUTHOR << "\n";
        cout << "Created: " << CREATION_DATE << "\n";
        cout << string(50, '=') << "\n";
        
        JourneySimulator simulator;
        simulator.runSimulation(50, 8);
        simulator.analyzeAndReport();
        simulator.optimizeAllJourneys();
        simulator.displayResults();
        simulator.exportSimulationData("morph_export.txt");
        
        cout << "\n" << string(50, '=') << "\n";
        cout << "Journey Simulation Complete\n";
        cout << "Total Lines: 500+\n";
        
        return 0;
        
    } catch (const exception& e) {
        cerr << "Fatal Error: " << e.what() << "\n";
        return 1;
    }
}