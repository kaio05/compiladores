#include <string>
#include <optional>
#include <memory>
using namespace std;

struct Node {
    int lineStart;
    int lineEnd;

    virtual ~Node() = default;
};

enum class ClassStereotype {
    EVENT,
    SITUATION,
    PROCESS,
    CATEGORY,
    MIXIN,
    PHASE_MIXIN,
    ROLE_MIXIN,
    HISTORICAL_MIXIN,
    HISTORICAL_ROLE,
    HISTORICAL_ROLE_MIXIN,
    KIND,
    COLLECTIVE,
    QUANTITY,
    QUALITY,
    MODE,
    INTRINSIC_MODES,
    EXTRINSIC_MODES,
    SUBKIND,
    PHASE,
    ROLE,
    RELATOR
};

enum class GensetModifier {
    DISJOINT,
    COMPLETE,
    OVERLAPPING,
    INCOMPLETE
};

struct GensetNode : public Node {
    string name;

    vector<GensetModifier> modifiers;

    string general;
    vector<string>* specifics;
};

struct GensetBody {
    string general;
    vector<string> specifics;
};

enum class RelationKind {
    INTERNAL,
    EXTERNAL
};

enum class RelationStereotype {
    COMPONENT_OF,
    MEMBER_OF,
    SUB_COLLECTION_OF,
    SUB_QUALITY_OF,
    MEDIATION,
    MATERIAL,
    DERIVATION,
    COMPARATIVE,
    CHARACTERIZATION,
    EXTERNAL_DEPENDENCE,
    INSTANTIATION,
    TERMINATION,
    PARTICIPATIONAL,
    PARTICIPATION,
    HISTORICAL_DEPENDENCE,
    CREATION,
    MANIFESTATION,
    BRINGS_ABOUT,
    TRIGGERS,
    COMPOSITION,
    AGGREGATION,
    INHERENCE,
    VALUE,
    FORMAL,
    CONSTITUTION,
    DEFAULT
};

// struct Cardinality {
//     int min;
//     optional<int> max; // nullopt representa *
// };

struct RelationNode : public Node {
    RelationKind kind;
    RelationStereotype stereotype;

    string sourceClass;
    string targetClass;

    optional<string> relationName;

    optional<string> sourceCardinality;
    optional<string> targetCardinality;
};

struct ClassNode : public Node {
    string name;
    ClassStereotype stereotype;

    vector<string> superclasses;

    vector<string> attributes;

    vector<unique_ptr<RelationNode>> internalRelations;
};

struct PackageNode : public Node {
    string name;

    vector<unique_ptr<ClassNode>> classes;
    vector<unique_ptr<GensetNode>> gensets;
    vector<unique_ptr<RelationNode>> externalRelations;
};

struct ProgramNode : public Node {
    vector<PackageNode*> imports;
    PackageNode* package;
};