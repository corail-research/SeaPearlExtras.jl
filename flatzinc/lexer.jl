include("token.jl")
import Base.parse

RESERVED_KEYWORDS = Dict([("var", Token(var, "var")), 
                            ("int", Token(int, "int")),
                            ("bool", Token(bool, "bool")),
                            ("float", Token(float, "float")),
                            ("true", Token(TRUE, "true")),
                            ("false", Token(FALSE, "false")),
                            ("set", Token(set, "set")),
                            ("of", Token(of, "of")),
                            ("array", Token(array, "array")),
                            ("predicate", Token(predicate, "predicate")),
                            ("constraint", Token(constraint, "constraint")),
                            ("solve", Token(solve, "solve")),
                            ("satisfy", Token(satisfy, "satisfy")),
                            ("maximize", Token(maximize, "maximize")),
                            ("minimize", Token(minimize, "minimize"))])

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


function number(lexer::Lexer)
    """Return a (multidigit) integer or float consumed from the input."""
    result = ""
    while lexer.currentCharacter !== nothing && isdigit(lexer.currentCharacter[1])
        result =result*lexer.currentCharacter
        advance(lexer)
    end
    if lexer.currentCharacter == '.'
        result = result*lexer.currentCharacter
        advance(lexer)
        while lexer.currentCharacter !== nothing && isdigit(lexer.currentCharacter[1])
            result =result*lexer.currentCharacter
            advance(lexer)
        end
        token = Token(REAL_CONST, parse(Float64,result))
    else
        token = Token(INT_CONST, parse(Int64,result))
    end

    return token
end


function peek(lexer::Lexer)
    peek_pos = lexer.current_pos + 1
    if peek_pos > length(lexer.text) 
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
        if lexer.currentCharacter == '0' && peek(lexer) == 'x'
            advance(lexer)
            advance(lexer)
            return Token(hexadicimal, "0x")
        end
        if lexer.currentCharacter == '0' && peek(lexer) == 'o'
            advance(lexer)
            advance(lexer)
            return Token(octal, "0o")
        end
        if lexer.currentCharacter == ':' && peek(lexer) == ':'
            advance(lexer)
            advance(lexer)
            return Token(DOUBLE_COLON, "::")
        end
        if lexer.currentCharacter == '.' && peek(lexer) == '.'
            advance(lexer)
            advance(lexer)
            return Token(PP, "..")
        end
        if isletter(lexer.currentCharacter)
            return id(lexer)
        end
        if (isdigit(lexer.currentCharacter[1]))
            return number(lexer)
        end
        if lexer.currentCharacter == ':'
            advance(lexer)
            return Token(COLON, ':')
        end
        if lexer.currentCharacter == ';'
            advance(lexer)
            return Token(COMMA, ';')
        end
        if lexer.currentCharacter == '('
            advance(lexer)
            return Token(LP, '(')
        end
        if lexer.currentCharacter == ')'
            advance(lexer)
            return Token(RP, ')')
        end
        if lexer.currentCharacter == '['
            advance(lexer)
            return Token(LB, '[')
        end
        if lexer.currentCharacter == ']'
            advance(lexer)
            return Token(RB, ']')
        end
        if lexer.currentCharacter == '{'
            advance(lexer)
            return Token(LCB, '{')
        end        
        if lexer.currentCharacter == '}'
            advance(lexer)
            return Token(RCB, '}')
        end
        if lexer.currentCharacter == '='
            advance(lexer)
            return Token(EQUAL, '=')
        end
        error()
    end
    return Token(EOF, nothing)
end

