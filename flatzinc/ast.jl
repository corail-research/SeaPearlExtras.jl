include("token.jl")
abstract type AST end
abstract type VAR  <: AST end

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

