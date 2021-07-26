@enum TokenType begin
    var = 1
    int = 2
    COLON = 3
    EQUAL = 4
    EOF = 5
    ID = 6
    COMMA = 7
    DOUBLE_COLON = 8
    bool = 9
    float = 10
end

struct Token
    type::TokenType
    value
end


function Base.show(io::IO, token::Token) 
    print("Type : " * string(token.type) * "\nValue : " * string(token.value))
end

