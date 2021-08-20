include("token.jl")
abstract type AST end

struct BasicType <: AST
    name
end

struct BasicParType <: AST
    name
end

struct Interval <: AST
    type 
    start_value
    end_value
end

struct Domain <:AST
    type
    value
end

struct BasicLiteralExpr <: AST
    type 
    value
end

struct BasicExpr <: AST
    type
    value
end

struct ArrayLiteral <: AST
    values::Array
end

struct Annotation <: AST
    id
    value
end

struct Annotations <: AST
    annotationsList::Array{Annotation}
end

struct IndexSet <: AST
    start_value
    end_value
end

struct ArrayVarType <: AST
    range::IndexSet
    type
end

struct VarDeclItem<:AST
    type
    id
    annotations
    annotations_values
end

struct ArrayParType<:AST
    type
    index
end

struct ParArrayLiteral <: AST
    values
end

struct ParDeclItem <: AST
    type
    id
    expression
end

struct Constraint <: AST
    id
    expressions
    annotations
end

struct Satisfy <: AST
    annotations
end

struct Minimize <: AST
    annotations
    expressions
end

struct Maximize <: AST
    annotations
    expressions
end

struct BasicPredParamType <: AST
    type
    index
end

struct PredParamType <: AST
    type
    id
end

struct Predicate <: AST
    id
    items
end

struct PredIndexSet <: AST
    id
end

struct ArrayPredParamType <: AST
    type
    index
end

struct Model <: AST
    predicates
    parameters
    variables
    constraints
    solves
end

