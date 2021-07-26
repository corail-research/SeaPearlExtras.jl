include("token.jl")
import Base.parse

RESERVED_KEYWORDS = Dict([("var", Token(var, "var")), 
                            ("int", Token(int, "int")),
                            ("bool", Token(bool, "bool")),
                            ("float", Token(float, "float"))])

mutable struct Lexer
    text::String
    current_pos::Int64
    currentCharacter
    Lexer(text) = new(text, 1, text[1])
end
            
function error()
    throw(ArgumentError("Invalide Charatere"))
end

function advance(lexer::Lexer)
    lexer.current_pos += 1
    if lexer.current_pos <= length(lexer.text)
        lexer.currentCharacter = lexer.text[lexer.current_pos]
    else
        lexer.currentCharacter = nothing
    end
end

function skipWhiteSpace(lexer::Lexer)
    while (lexer.currentCharacter !== nothing && isspace(lexer.currentCharacter[1]))
        advance(lexer)
    end
end


function id(lexer::Lexer)
    result = ""
    while lexer.currentCharacter !== nothing && 
        (isletter(lexer.currentCharacter) || isnumeric(lexer.currentCharacter) || lexer.currentCharacter == '_')
        result = result * lexer.currentCharacter
        advance(lexer)
    end
    token = get(RESERVED_KEYWORDS, result, Token(ID, result))
    return token
end

function peek(lexer::Lexer)
    peek_pos = lexer.current_pos + 1
    if peek_pos > length(lexer.text) - 1
        return nothing
    else
        return lexer.text[peek_pos]
    end
end


function getNextToken(lexer::Lexer)
    while (lexer.currentCharacter) !== nothing
        if (isspace(lexer.currentCharacter[1]))
            skipWhiteSpace(lexer)
            continue
        end        
        if isletter(lexer.currentCharacter)
            return id(lexer)
        end
        if lexer.currentCharacter == ':' && peek(lexer) == ':'
            advance(lexer)
            advance(lexer)
            return Token(DOUBLE_COLON, "::")
        end
        if lexer.currentCharacter == ':'
            advance(lexer)
            return Token(COLON, ':')
        end
        if lexer.currentCharacter == ';'
            advance(lexer)
            return Token(COMMA, ';')
        end
        error()
    end
    return Token(EOF, nothing)
end
