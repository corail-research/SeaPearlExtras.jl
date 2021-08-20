include("parser.jl")
using SeaPearl

mutable struct Interpreter
    node::AST
    GLOBAL_VARIABLE::Dict
    GLOBAL_CONSTRAINT::Dict
    Interpreter(node) = new(node, Dict())
end

function error(message)
    throw(ArgumentError(message))
end


function create_variable(interpreter::Interpreter, node::AST, trailer, m)
    type = node.type
    if (typeof(type) == Interval)
        if type.type == int
            newVariable = SeaPearl.IntVar(type.start_value, type.end_value, node.id, trailer)
            SeaPearl.addVariable!(m, newVariable)
            interpreter.GLOBAL_VARIABLE[node.id] = newVariable
        elseif type.type == float
            error("Float are not permited")
        end
    elseif (typeof(type) == Domain)
        error("Domain variable are not permited")
    elseif (typeof(type) == BasicType)
        if (type.name == int)
            newVariable = SeaPearl.IntVar(0, 2, node.id, trailer)
            SeaPearl.addVariable!(m, newVariable)
            interpreter.GLOBAL_SCOPE[node.id] = newVariable
        elseif (type.name == bool)
            newVariable =SeaPearl.BoolVar(node.id, trailer)
            SeaPearl.addVariable!(m, newVariable)
            interpreter.GLOBAL_VARIABLE[node.id] = newVariable
        else
            error("Float are not permited")
        end
    elseif (typeof(type) == ArrayVarType)
        variable_type = type.type
        start_value = type.range.start_value
        end_value = type.range.end_value
        for i in start_value:end_value
            if (typeof(variable_type) == Interval)
                if type.type == int
                    newVariable = SeaPearl.IntVar(type.start_value, type.end_value, node.id, trailer)
                    SeaPearl.addVariable!(m, newVariable)
                    interpreter.GLOBAL_VARIABLE[node.id*"_"*string(i)] = newVariable
                elseif variable_type == float
                    error("Float are not permited")
                end
            elseif (typeof(variable_type) == Domain)
                error("Domain variable are not permited")
            elseif (typeof(variable_type) == BasicType)
                if (variable_type.name == int)
                    newVariable = SeaPearl.IntVar(0, 2, node.id*"_"*string(i), trailer)
                    SeaPearl.addVariable!(m, newVariable)
                    interpreter.GLOBAL_VARIABLE[node.id*"_"*string(i)] = newVariable
                elseif (variable_type.name == bool)
                    newVariable =SeaPearl.BoolVar(node.id, trailer)
                    SeaPearl.addVariable!(m, newVariable)
                    interpreter.GLOBAL_VARIABLE[node.id*"_"*string(i)] = newVariable
                else
                    error("Float are not permited")
                end
            end
        end
    end
end


function create_model(model)
    lexer = Lexer(model)
    parser = Parser(lexer)
    node = read_model(parser)
    interpreter = Interpreter(node)
    trailer = SeaPearl.Trailer()
    m = SeaPearl.CPModel(trailer)
    for variable in node.variables
        create_variable(interpreter, variable ,trailer, m)
    end
    return interpreter
end



