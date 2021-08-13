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

function expr(parser::Parser)
    if (parser.currentToken.type == LB)
        return array_literal(parser)
    else
        return basic_expr(parser::Parser)
    end
end


function annotations(parser::Parser)
     annotationsList = []
     while parser.currentToken.type == DOUBLE_COLON
        eat(parser, DOUBLE_COLON)
        push!(annotationsList, annotation(parser))
     end
     return Annotations(annotationsList)
end

function annotation(parser::Parser)
    id = parser.currentToken.value
    value = []
    eat(parser, ID)
    if (parser.currentToken.type == LP)
        eat(parser, LP)
        push!(value, ann_exp(parser))
        while (parser.currentToken.type == COMMA)
            eat(parser, COMME)
            push!(value, ann_exp(parser))
        end
        eat(parser, RP)
    end
    return Annotation(id, value)
end

function ann_exp(parser::Parser)
    if (parser.currentToken.type == ID)
        return annotation(parser)
    else 
        return expr(parser)
    end
end

function index_set(parser::Parser)
    start_value = int_literal(parser)
    eat(parser, PP)
    end_value = int_literal(parser)
    return IndexSet(start_value, end_value)
end

function array_var_type(parser::Parser)
    eat(parser, array)
    eat(parser, LB)
    range = index_set(parser)
    eat(parser, RB)
    eat(parser, of)
    type = basic_var_type(parser)
    return ArrayVarType(range, type)
end


function var_decl_item(parser::Parser)
    if (parser.currentToken.type == array)
        type = array_var_type(parser)
        eat(parser, COLON)
        id = parser.currentToken.value
        eat(parser, ID)
        anns = annotations(parser)
        eat(parser, EQUAL)
        annotations_values = array_literal(parser)
        eat(parser, SEMICOLON)
    else
        type = basic_var_type(parser)
        eat(parser, COLON)
        id = parser.currentToken.value
        eat(parser, ID)
        anns = nothing
        if (parser.currentToken.type == DOUBLE_COLON)
            anns = annotations(parser)
        end
        annotations_values = nothing
        if (parser.currentToken.type == EQUAL)
            eat(parser, EQUAL)
            annotations_values = basic_expr(parser)
        end
        eat(parser, SEMICOLON)
    end
    return VarDeclItem(type, id, anns, annotations_values)
end
                

function basic_pred_param_type(parser::Parser)
    if parser.currentToken.type == INT_CONST
        start_value = int_literal(parser)
        eat(parser, PP)
        end_value = int_literal(parser)
        return Interval(int, start_value, end_value)
    elseif parser.currentToken.type == REAL_CONST
        start_value = float_literal(parser)
        eat(parser, PP)
        end_value = float_literal(parser)
        return Interval(float, start_value, end_value)
    elseif parser.currentToken.type == LCB
        values = []
        eat(parser, LCB)
        push!(values, int_literal(parser))
        while (parser.currentToken.type == COMMA)
            eat(parser, COMMA)
            push!(values, int_literal(parser))
        end
        eat(parser, RCB)
        return Domain(int, values)
    elseif (parser.currentToken.type == bool)
        eat(parser, bool)
        return BasicParType(bool)
    elseif (parser.currentToken.type == int)
        eat(parser, int)
        return BasicParType(int)
    elseif (parser.currentToken.type == float)
        eat(parser, float)
        return BasicParType(float)
    elseif (parser.currentToken.type == set)
        eat(parser, set)
        eat(parser, of)
        if (parser.currentToken.type == int)
            eat(parser, int)
            return BasicParType("set of int")
        elseif (parser.currentToken.type == INT_CONST)
             start_value = int_literal(parser)
             eat(parser, PP)
             end_value = int_literal(parser)
             return Domain(int, start_value:end_value)
        else
            eat(parser, LCB)
            values = []
            push!(values, int_literal(parser))
            while (parser.currentToken.type == COMMA)
                eat(parser, COMMA)
                push!(values, int_literal(parser))
            end
            eat(parser, RCB)
            return Domain(int, values)
        end
    else 
        copyLexer = Lexer(parser.lexer.text[parser.lexer.current_pos:length(parser.lexer.text)])
        token = getNextToken(copyLexer)
        token = getNextToken(copyLexer)
        token = getNextToken(copyLexer)
        if token.type == int
            eat(parser, var)
            eat(parser, set)
            eat(parser, of)
            eat(parser, int)
            return VarDeclItem(set, "", [], [])
        else
            return basic_var_type(parser)
        end
    end     
end

function basic_par_type(parser::Parser)
    if (parser.currentToken.type == int)
        eat(parser, int)
        return BasicParType(int)
    elseif (parser.currentToken.type == float)
            eat(parser, float)
            return BasicParType(float)
    elseif (parser.currentToken.type == bool)
            eat(parser, bool)
            return BasicParType(bool)
    else 
        eat(parser, set)
        eat(parser, of)
        eat(parser, int)
        return BasicParType("set of int")
    end
end


function par_type(parser::Parser)
    if (parser.currentToken.type != array)
        return basic_par_type(parser)
    else
        eat(parser, array)
        eat(parser, LB)
        index = index_set(parser)
        eat(parser, RB)
        eat(parser, of)
        type = basic_par_type(parser)
        return ArrayParType(type, index)
    end
end


function par_array_literal(parser::Parser)
    eat(parser, LB)
    values = []
    push!(values, basic_literal_expr(parser))
    while (parser.currentToken.type == COMMA)
        eat(parser, COMMA)
        push!(values, basic_literal_expr(parser))
    end
    eat(parser, RB)
    return ParArrayLiteral(values)
end

function par_expr(parser::Parser)
    if (parser.currentToken.type == LB)
        return par_array_literal(parser)
    else
        return basic_literal_expr(parser)
    end
end

function par_decl_item(parser::Parser)
    type = par_type(parser)
    eat(parser, COLON)
    id = parser.currentToken.value
    eat(parser, ID)
    eat(parser, EQUAL)
    expression = par_expr(parser)
    eat(parser, SEMICOLON)

    return ParDeclItem(type, id, expression)
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
