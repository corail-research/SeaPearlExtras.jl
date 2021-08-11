include("token.jl")
abstract type AST end
abstract type VAR  <: AST end
abstract type PARAM  <: AST end

struct BasicType <: AST
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

struct VarUnbounded <: VAR
    id::String
    type::TokenType
    annotation
end


struct VarInterval <: VAR
    id::String
    annotation
    type::TokenType
    min
    max
end

struct VarDomain <: VAR
    id::String
    annotation
    domain
end


struct paramType <: PARAM
    id
    type::TokenType
    value
end

struct arrayNode <: AST
    start_index
    end_index
    variable_node 
end