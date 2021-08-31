include("parser.jl")
using SeaPearl

mutable struct Interpreter
    node::AST
    GLOBAL_VARIABLE::Dict
    GLOBAL_CONSTRAINT::Array
    Interpreter(node) = new(node, Dict(), [])
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
        arrayVariables = []
        for i in start_value:end_value
            if (typeof(variable_type) == Interval)
                if type.type == int
                    variable_name = node.annotations_values.values[i].value
                    push!(arrayVariables,  variable_name)
                elseif variable_type == float
                    error("Float are not permited")
                end
            elseif (typeof(variable_type) == Domain)
                error("Domain variable are not permited")
            elseif (typeof(variable_type) == BasicType)
                if (variable_type.name == int)
                    variable_name = node.annotations_values.values[i].value
                    push!(arrayVariables,  variable_name)
                elseif (variable_type.name == bool)
                    variable_name = node.annotations_values.values[i].value
                    push!(arrayVariables,  variable_name)
                else
                    error("Float are not permited")
                end
            end
        end
        interpreter.GLOBAL_VARIABLE[node.id] = arrayVariables
    end
end


function create_constraint(interpreter::Interpreter, constraint, trailer, m)
    if (occursin("all_different", constraint.id))
        variables = SeaPearl.AbstractIntVar[]
        #new_constraint = SeaPearl.AllDifferent(temps, trailer)
        println(constraint)
        for var in interpreter.GLOBAL_VARIABLE[constraint.expressions[1].value]
            push!(variables, interpreter.GLOBAL_VARIABLE[var])
        end
        new_constraint = SeaPearl.AllDifferent(variables, trailer)
        push!(m.constraints, new_constraint)
        push!(interpreter.GLOBAL_CONSTRAINT, new_constraint)
    end
end

function create_solve(interpreter::Interpreter, constraint, trailer, m)
    
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
    for constraint in node.constraints
        create_constraint(interpreter, constraint, trailer, m)
    end
    return interpreter
end



