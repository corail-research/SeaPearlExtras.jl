@enum TokenType begin
    var = 1
    int = 2
    COLON = 3
    EQUAL = 4
end

struct Token
    type::TokenType
    value
end


function Base.show(io::IO, token::Token) 
    print("Type : " * string(token.type) * "\nValue : " * string(token.value))
end

