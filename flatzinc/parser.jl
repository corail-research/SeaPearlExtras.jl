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

function int_literal(parser::Parser)
   integer = parser.currentToken.value
   if parser.currentToken == hexadicimal
        eat(parser, hexadecimal)
   elseif parser.currentToken == octal     
        eat(parser, octal)
   else
        eat(parser, INT_CONST)
   end
   return integer
end


function float_literal(parser::Parser)
    float = parser.currentToken.value
    eat(parser, REAL_CONST)
    return float
end


function bool_literal(parser::Parser)
    value = true
    if parser.currentToken.value == false
        value = false 
        eat(parser, FALSE)
    else 
        eat(parser, TRUE)
    end

    return value 
end

function set_literal(parser::Parser)
    if (parser.currentToken.type == LCB)
        eat(parser, LCB)
        if parser.currentToken.type == INT_CONST
            value = []
            push!(value, int_literal(parser))
            while (parser.currentToken.type == COMMA)
                eat(parser, COMMA)
                push!(value, int_literal(parser))
            end
            return Domain(INT_CONST, value)
        else
            value = []
            push!(value, float_literal(parser))
            while (parser.currentToken.type == COMMA)
                eat(parser, COMMA)
                push!(value, float_literal(parser))
            end
            return Domain(REAL_CONST, value)
        end
    elseif parser.currentToken.type == INT_CONST
        start_value = int_literal(parser)
        eat(parser, PP)
        end_value = int_literal(parser)
        return Domain(INT_CONST, start_value:end_value)
    else
        start_value = float_literal(parser)
        eat(parser, PP)
        end_value = float_literal(parser)
        return Interval(REAL_CONST, start_value, end_value)
    end
end


function basic_var_type(parser::Parser)
    eat(parser, var)
    if (parser.currentToken.type == int)
        eat(parser, int)
        return BasicType(int)

    elseif (parser.currentToken.type == bool)
        eat(parser, bool)
        return BasicType(bool)

    elseif (parser.currentToken.type == INT_CONST || parser.currentToken.type == octal || parser.currentToken == hexadicimal)
        start_value = int_literal(parser)
        eat(parser, PP)
        end_value = int_literal(parser)
        return Interval(int, start_value, end_value)

    elseif (parser.currentToken.type == LCB)
        eat(parser, LCB)
        value = []
        push!(value, int_literal(parser))
        while (parser.currentToken.type == COMMA)
            eat(parser, COMMA)
            push!(value, int_literal(parser))
        end
        eat(parser, RCB)
        return Domain(int, value)

    elseif (parser.currentToken.type == float)
        eat(parser, float)
        return BasicType(float)

    elseif (parser.currentToken.type == REAL_CONST)
        start_value = float_literal(parser)
        eat(parser, PP)
        end_value = float_literal(parser)
        return Interval(float, start_value, end_value)

    else 
        eat(parser, set)
        eat(parser, of)
        if (parser.currentToken.type == LCB)
            eat(parser, LCB)
            value = []
            push!(value, int_literal(parser))
            while (parser.currentToken.type == COMMA)
                eat(parser, COMMA)
                push!(value, int_literal(parser))
            end
            eat(parser, RCB)
            return Domain(int, value)
        else
            start_value = int_literal(parser)
            eat(parser, PP)
            end_value = int_literal(parser)
            return Domain(int, start_value:end_value)
        end     
    end
end


function basic_literal_expr(parser::Parser)
    if (parser.currentToken.value === true || parser.currentToken.value === false)
        value = bool_literal(parser)
        return BasicLiteralExpr(bool, value)

    elseif (parser.currentToken.type == LCB)
        return BasicLiteralExpr(set, set_literal(parser))

    elseif (parser.currentToken.type == REAL_CONST)
        type = REAL_CONST
        value = float_literal(parser)
        if (parser.currentToken.type != PP)
            return BasicLiteralExpr(type, value)
        else
            eat(parser, PP)
            value_end = float_literal(parser)
            return BasicLiteralExpr(set, Interval(type, value, value_end))
        end
    elseif (parser.currentToken.type == INT_CONST)
        type = INT_CONST
        value = int_literal(parser)
        if (parser.currentToken.type != PP)
            return BasicLiteralExpr(type, value)
        else
            eat(parser, PP)
            value_end = int_literal(parser)
            return BasicLiteralExpr(set, Domain(type, value:value_end))
        end
    end
end



function basic_expr(parser::Parser)
    if (parser.currentToken.type == ID)
        name = parser.currentToken.value
        eat(parser, ID)
        return BasicExpr(ID, name)

    else
        return basic_literal_expr(parser)
    end
end



function array_literal(parser::Parser)
    eat(parser, LB)
    values = []
    push!(values, basic_expr(parser))
    while (parser.currentToken.type == COMMA)
        eat(parser, COMMA)
        push!(values, basic_expr(parser))
    end
    eat(parser, RB)
    return ArrayLiteral(values)
end






function array_litteral(parser::Parser)
    eat(parser, array)
    eat(parser, LB)
    start_index = parser.currentToken.value
    eat(parser, INT_CONST)
    eat(parser, PP)
    end_index = parser.currentToken.value
    eat(parser, INT_CONST)
    eat(parser, RB)
    eat(parser, of)
    variableNode = variable(parser)
    return arrayNode(start_index, end_index, variableNode)
 
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
end


function parameter(parser::Parser)
    type = nothing
    if (parser.currentToken.type != array && parser.currentToken.type != set)
        if parser.currentToken.type == bool
            eat(parser, bool)
            type = bool
        elseif parser.currentToken.type == int 
            eat(parser, int)
            type = int 
        elseif parser.currentToken.type == float
            eat(parser, float)
            type = float
        end
        eat(parser, COLON)
        id = parser.currentToken.value
        eat(parser, ID)
        eat(parser, EQUAL)
        value = parser.currentToken.value
        if type == bool
            if value
                eat(parser, TRUE)
            else
                eat(parser, FALSE)
            end
        elseif type == int 
            eat(parser, INT_CONST)
        elseif type == float
            eat(parser, REAL_CONST)
        end        
        eat(parser, SEMICOLON)
        return paramType(id, type, value)
    elseif parser.currentToken.type == set
        value = []
        type = set
        eat(parser, set)
        eat(parser, of)
        eat(parser, int)
        eat(parser, COLON)
        id = parser.currentToken.value
        eat(parser, ID)
        eat(parser, EQUAL)

        eat(parser, LCB)
        push!(value, parser.currentToken.value)
        eat(parser, INT_CONST)
        while (parser.currentToken.type == COMMA)
            eat(parser, COMMA)
            push!(value, parser.currentToken.value)
            eat(parser, INT_CONST)
        end
        eat(parser, RCB)
        eat(parser, SEMICOLON)
        return paramType(id, type, value)
    end

end
