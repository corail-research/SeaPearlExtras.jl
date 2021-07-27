include("lexer.jl")
include("ast.jl")

mutable struct Parser
    lexer::Lexer
    currentToken
    Parser(lexer) = new(lexer, getNextToken(lexer))
end

function error()
    throw(ArgumentError("Invalide Charatere"))
end

function eat(parser::Parser, tokenType::TokenType)
    if parser.currentToken.type == tokenType
        parser.currentToken = getNextToken(parser.lexer)
    else 
        error()
    end
end


function variable(parser::Parser)
    eat(parser, var)
    if parser.currentToken.type == bool || parser.currentToken.type == int || parser.currentToken.type == float
        type = parser.currentToken.type
        eat(parser, parser.currentToken.type)
        eat(parser, COLON)
        id = parser.currentToken.value
        eat(parser, ID)
        annotation = nothing
        if (parser.currentToken.type == DOUBLE_COLON)
            eat(parser, DOUBLE_COLON)
            annotation = parser.currentToken.value
            eat(parser, ID)
        end
        eat(parser, SEMICOLON)
        return VarUnbounded(id, type, annotation)
    elseif parser.currentToken.type == INT_CONST || parser.currentToken.type == REAL_CONST
        startToken = parser.currentToken
        eat(parser, startToken.type)
        eat(parser, PP)
        endToken = parser.currentToken
        eat(parser, parser.currentToken.type)
        eat(parser, COLON)
        id = parser.currentToken.value
        eat(parser, ID)
        annotation = nothing
        if (parser.currentToken.type == DOUBLE_COLON)
            eat(parser, DOUBLE_COLON)
            annotation = parser.currentToken.value
            eat(parser, ID)
        end
        if (startToken.type == INT_CONST && endToken.type == INT_CONST)
            type = INT_CONST
        else
            type = REAL_CONST
        end
        eat(parser, SEMICOLON)

        return VarInterval(id, annotation, type, startToken.value, endToken.value)
    elseif parser.currentToken.type == LCB
        domain = []
        eat(parser, LCB)
        push!(domain, parser.currentToken.value)
        eat(parser, INT_CONST)
        while (parser.currentToken.type == COMMA)
            eat(parser, COMMA)
            push!(domain, parser.currentToken.value)
            eat(parser, INT_CONST)
        end
        eat(parser, RCB)
        eat(parser, COLON)
        id = parser.currentToken.value
        eat(parser, ID)
        annotation = nothing
        if (parser.currentToken.type == DOUBLE_COLON)
            eat(parser, DOUBLE_COLON)
            annotation = parser.currentToken.value
            eat(parser, ID)
        end
        eat(parser, SEMICOLON)

        return VarDomain(id, annotation, domain)
    else
        error()
    end
    return node
end
