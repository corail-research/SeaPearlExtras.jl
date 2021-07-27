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
    LP = 11
    RP = 12
    LB = 13
    RB = 14
    TRUE = 15
    FALSE = 16
    set = 17
    of = 18
    array = 19
    PP = 20
    LCB = 21
    RCB = 22
    predicate = 23
    constraint = 24
    solve = 25
    satisfy = 26
    minimize = 27
    maximize  = 28
    hexadicimal = 29
    octal = 30
    INT_CONST = 31
    REAL_CONST = 32
    SEMICOLON = 33
end

struct Token
    type::TokenType
    value
end


function Base.show(io::IO, token::Token) 
    print("Type : " * string(token.type) * "\nValue : " * string(token.value))
end

