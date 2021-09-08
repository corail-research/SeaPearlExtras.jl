using SeaPearl: variablesArray
using Base: parameter_upper_bound, Bool, Float16
using Test
include("../flatzinc/lexer.jl")
include("../flatzinc/parser.jl")
include("../flatzinc/interpreter.jl")

@testset "Lexer" begin

    @testset "number fonction" begin
        lexer = Lexer("1.3")
        token = number(lexer)
        @test token.type == REAL_CONST
        @test token.value == 1.3

        lexer = Lexer("1..3")
        token = number(lexer)
        @test token.type == INT_CONST
        @test token.value == 1
    end

    @testset "normal var statement" begin
        lexer = Lexer("var int: X_INTRODUCED_2_:: output_var;")
        token = getNextToken(lexer)
        @test token.type == var
        @test token.value == "var"
        token = getNextToken(lexer)
        @test token.type == int
        @test token.value == "int"    
        token = getNextToken(lexer)
        @test token.type == COLON
        @test token.value == ':'
        token = getNextToken(lexer)
        @test token.type == ID
        @test token.value == "X_INTRODUCED_2_"
        token = getNextToken(lexer)
        @test token.type == DOUBLE_COLON
        @test token.value == "::"
        token = getNextToken(lexer)
        @test token.type == ID
        @test token.value == "output_var"
        token = getNextToken(lexer)
        @test token.type == SEMICOLON
        @test token.value == ';'
        token = getNextToken(lexer)
        @test token.type == EOF
        @test token.value === nothing
    end


    @testset "var float statement" begin
        lexer = Lexer("var int: X_INTRODUCED_2_:: output_var;
                        var float: X_INTRODUCED_1_;")
        token = getNextToken(lexer)
        @test token.type == var
        @test token.value == "var"
        token = getNextToken(lexer)
        @test token.type == int
        @test token.value == "int"    
        token = getNextToken(lexer)
        @test token.type == COLON
        @test token.value == ':'
        token = getNextToken(lexer)
        @test token.type == ID
        @test token.value == "X_INTRODUCED_2_"
        token = getNextToken(lexer)
        @test token.type == DOUBLE_COLON
        @test token.value == "::"
        token = getNextToken(lexer)
        @test token.type == ID
        @test token.value == "output_var"
        token = getNextToken(lexer)
        @test token.type == SEMICOLON
        @test token.value == ';'
        token = getNextToken(lexer)
        @test token.type == var
        @test token.value == "var"
        token = getNextToken(lexer)
        @test token.type == float
        @test token.value == "float"    
        token = getNextToken(lexer)
        @test token.type == COLON
        @test token.value == ':'
        token = getNextToken(lexer)
        @test token.type == ID
        @test token.value == "X_INTRODUCED_1_"
        token = getNextToken(lexer)
        @test token.type == SEMICOLON
        @test token.value == ';'
        token = getNextToken(lexer)
        @test token.type == EOF
        @test token.value === nothing
    end


    @testset "all tokens" begin
        lexer = Lexer("var int : = allo  ; :: bool float ( ) [] true false set of array .. {}
                             predicate constraint solve satisfy minimize maximize 
                             0x4422ff 0o4352 1.33 321 , 1.33e2 2E3 ")
        token = getNextToken(lexer)
        @test token.type == var
        @test token.value == "var"

        token = getNextToken(lexer)
        @test token.type == int
        @test token.value == "int"    

        token = getNextToken(lexer)
        @test token.type == COLON
        @test token.value == ':'

        token = getNextToken(lexer)
        @test token.type == EQUAL
        @test token.value == '='

        token = getNextToken(lexer)
        @test token.type == ID
        @test token.value == "allo"

        token = getNextToken(lexer)
        @test token.type == SEMICOLON
        @test token.value == ';'

        token = getNextToken(lexer)
        @test token.type == DOUBLE_COLON
        @test token.value == "::"

        token = getNextToken(lexer)
        @test token.type == bool
        @test token.value == "bool"

        token = getNextToken(lexer)
        @test token.type == float
        @test token.value == "float"    

        token = getNextToken(lexer)
        @test token.type == LP
        @test token.value == '('

        token = getNextToken(lexer)
        @test token.type == RP
        @test token.value == ')'

        token = getNextToken(lexer)
        @test token.type == LB
        @test token.value == '['

        token = getNextToken(lexer)
        @test token.type == RB
        @test token.value == ']'

        token = getNextToken(lexer)
        @test token.type == TRUE
        @test token.value == true

        token = getNextToken(lexer)
        @test token.type == FALSE
        @test token.value == false

        token = getNextToken(lexer)
        @test token.type == set
        @test token.value == "set"

        token = getNextToken(lexer)
        @test token.type == of
        @test token.value == "of"

        token = getNextToken(lexer)
        @test token.type == array
        @test token.value == "array"

        token = getNextToken(lexer)
        @test token.type == PP
        @test token.value == ".."

        token = getNextToken(lexer)
        @test token.type == LCB
        @test token.value == '{'

        token = getNextToken(lexer)
        @test token.type == RCB
        @test token.value == '}'

        token = getNextToken(lexer)
        @test token.type == predicate
        @test token.value == "predicate"

        token = getNextToken(lexer)
        @test token.type == constraint
        @test token.value == "constraint"

        token = getNextToken(lexer)
        @test token.type == solve
        @test token.value == "solve"

        token = getNextToken(lexer)
        @test token.type == satisfy
        @test token.value == "satisfy"

        token = getNextToken(lexer)
        @test token.type == minimize
        @test token.value == "minimize"

        token = getNextToken(lexer)
        @test token.type == maximize
        @test token.value == "maximize"

        token = getNextToken(lexer)
        @test token.type == hexadicimal
        @test token.value == "4422ff"

        token = getNextToken(lexer)
        @test token.type == octal
        @test token.value == "4352"

        token = getNextToken(lexer)
        @test token.type == REAL_CONST
        @test token.value == 1.33

        token = getNextToken(lexer)
        @test token.type == INT_CONST
        @test token.value == 321

        token = getNextToken(lexer)
        @test token.type == COMMA
        @test token.value == ','

        token = getNextToken(lexer)
        @test token.type == REAL_CONST
        @test token.value == 133

        token = getNextToken(lexer)
        @test token.type == REAL_CONST
        @test token.value == 2000

        token = getNextToken(lexer)
        @test token.type == EOF
        @test token.value === nothing
    end
end

@testset "Parser" begin


    @testset "basic_var_type" begin
        lexer = Lexer("var bool")
        parser = Parser(lexer)
        node = basic_var_type(parser)
        @test node.name == bool

        lexer = Lexer("var int")
        parser = Parser(lexer)
        node = basic_var_type(parser)
        @test node.name == int

        lexer = Lexer("var float")
        parser = Parser(lexer)
        node = basic_var_type(parser)
        @test node.name == float

        lexer = Lexer("var 1..4")
        parser = Parser(lexer)
        node = basic_var_type(parser)
        @test node.type == int
        @test node.start_value == 1
        @test node.end_value == 4

        lexer = Lexer("var 1.2..4.0")
        parser = Parser(lexer)
        node = basic_var_type(parser)
        @test node.type == float
        @test node.start_value == 1.2
        @test node.end_value == 4

        lexer = Lexer("var {2,3,4,6}")
        parser = Parser(lexer)
        node = basic_var_type(parser)
        @test node.type == int
        @test node.value == [2,3,4,6]

        lexer = Lexer("var set of 1..3")
        parser = Parser(lexer)
        node = basic_var_type(parser)
        @test node.type == int
        @test node.value == [1,2,3]

        lexer = Lexer("var set of {2,3,4,6}")
        parser = Parser(lexer)
        node = basic_var_type(parser)
        @test node.type == int
        @test node.value == [2,3,4,6]
    end


    @testset "set_literal" begin
        lexer = Lexer("{1,2,4,5}")
        parser = Parser(lexer)
        node = set_literal(parser)
        @test node.type == INT_CONST
        @test node.value == [1,2,4,5]

        lexer = Lexer("{1.2, 4.4, 5.0}")
        parser = Parser(lexer)
        node = set_literal(parser)
        @test node.type == REAL_CONST
        @test node.value == [1.2, 4.4, 5.0]

        lexer = Lexer("1..4")
        parser = Parser(lexer)
        node = set_literal(parser)
        @test node.type == INT_CONST
        @test node.value == [1,2,3,4]

        lexer = Lexer("1.5..4.0")
        parser = Parser(lexer)
        node = set_literal(parser)
        @test node.type == REAL_CONST
        @test node.start_value == 1.5
        @test node.end_value == 4.0
    end

    @testset "basic_literal_expr" begin

        lexer = Lexer("true")
        parser = Parser(lexer)
        node = basic_literal_expr(parser)
        @test node.type == bool
        @test node.value == true

        lexer = Lexer("false")
        parser = Parser(lexer)
        node = basic_literal_expr(parser)
        @test node.type == bool
        @test node.value == false

        lexer = Lexer("1")
        parser = Parser(lexer)
        node = basic_literal_expr(parser)
        @test node.type == INT_CONST
        @test node.value == 1

        lexer = Lexer("1.2")
        parser = Parser(lexer)
        node = basic_literal_expr(parser)
        @test node.type == REAL_CONST
        @test node.value == 1.2

        lexer = Lexer("1..3")
        parser = Parser(lexer)
        node = basic_literal_expr(parser)
        @test node.type == set
        @test node.value.type == INT_CONST
        @test node.value.value == [1,2,3]

        lexer = Lexer("1.2..3.0")
        parser = Parser(lexer)
        node = basic_literal_expr(parser)
        @test node.type == set
        @test node.value.type == REAL_CONST
        @test node.value.start_value == 1.2
        @test node.value.end_value == 3.0

        lexer = Lexer("{1,2,32,3}")
        parser = Parser(lexer)
        node = basic_literal_expr(parser)
        @test node.type == set
        @test node.value.type == INT_CONST
        @test node.value.value == [1,2,32,3]

        lexer = Lexer("{1.3, 3.4}")
        parser = Parser(lexer)
        node = basic_literal_expr(parser)
        @test node.type == set
        @test node.value.type == REAL_CONST
        @test node.value.value == [1.3, 3.4]
    end


    @testset "basic_expr" begin
        lexer = Lexer("supp")
        parser = Parser(lexer)
        node = basic_expr(parser)
        @test node.type == ID
        @test node.value == "supp"

        lexer = Lexer("true")
        parser = Parser(lexer)
        node = basic_expr(parser)
        @test node.type == bool
        @test node.value == true

        lexer = Lexer("false")
        parser = Parser(lexer)
        node = basic_expr(parser)
        @test node.type == bool
        @test node.value == false

        lexer = Lexer("1")
        parser = Parser(lexer)
        node = basic_expr(parser)
        @test node.type == INT_CONST
        @test node.value == 1

        lexer = Lexer("1.2")
        parser = Parser(lexer)
        node = basic_expr(parser)
        @test node.type == REAL_CONST
        @test node.value == 1.2

        lexer = Lexer("1..3")
        parser = Parser(lexer)
        node = basic_expr(parser)
        @test node.type == set
        @test node.value.type == INT_CONST
        @test node.value.value == [1,2,3]

        lexer = Lexer("1.2..3.0")
        parser = Parser(lexer)
        node = basic_expr(parser)
        @test node.type == set
        @test node.value.type == REAL_CONST
        @test node.value.start_value == 1.2
        @test node.value.end_value == 3.0

        lexer = Lexer("{1,2,32,3}")
        parser = Parser(lexer)
        node = basic_expr(parser)
        @test node.type == set
        @test node.value.type == INT_CONST
        @test node.value.value == [1,2,32,3]

        lexer = Lexer("{1.3, 3.4}")
        parser = Parser(lexer)
        node = basic_expr(parser)
        @test node.type == set
        @test node.value.type == REAL_CONST
        @test node.value.value == [1.3, 3.4]
    end


    @testset "array_literal" begin
        lexer = Lexer("[1,2,4,1]")
        parser = Parser(lexer)
        node = array_literal(parser)
        @test node.values[1] == BasicLiteralExpr(INT_CONST, 1)
        @test node.values[2] == BasicLiteralExpr(INT_CONST, 2)
        @test node.values[3] == BasicLiteralExpr(INT_CONST, 4)
        @test node.values[4] == BasicLiteralExpr(INT_CONST, 1)

        lexer = Lexer("[true, false , false , true]")
        parser = Parser(lexer)
        node = array_literal(parser)
        @test node.values[1] == BasicLiteralExpr(bool, true)
        @test node.values[2] == BasicLiteralExpr(bool, false)
        @test node.values[3] == BasicLiteralExpr(bool, false)
        @test node.values[4] == BasicLiteralExpr(bool, true)    
    end

    @testset "annotations" begin
        lexer = Lexer(":: output_array([1..3])")
        parser = Parser(lexer)
        node = annotations(parser)
        @test length(node.annotationsList) == 1   
        @test node.annotationsList[1].id == "output_array" 
        @test typeof(node) == Annotations
        @test typeof(node.annotationsList[1]) == Annotation
        @test typeof(node.annotationsList[1].value[1]) == ArrayLiteral
        @test typeof(node.annotationsList[1].value[1].values[1]) == BasicLiteralExpr
        @test typeof(node.annotationsList[1].value[1].values[1].value) == Domain


        @test node.annotationsList[1].value[1].values[1].type == set
        @test node.annotationsList[1].value[1].values[1].value.type == INT_CONST
        @test node.annotationsList[1].value[1].values[1].value.value == [1,2,3]
    end

    @testset "array_var_type" begin
        lexer = Lexer("array[1..3] of var int")
        parser = Parser(lexer)
        node = array_var_type(parser)

        @test node.range.start_value == 1
        @test node.range.end_value == 3
        @test node.type.name == int


        lexer = Lexer("array[1..3] of var 1..6")
        parser = Parser(lexer)
        node = array_var_type(parser)

        @test node.range.start_value == 1
        @test node.range.end_value == 3
        @test node.type.type == int
        @test node.type.start_value == 1
        @test node.type.end_value == 6

        lexer = Lexer("array[1..3] of var {1,5,6}")
        parser = Parser(lexer)
        node = array_var_type(parser)

        @test node.range.start_value == 1
        @test node.range.end_value == 3
        @test node.type.type == int
        @test node.type.value == [1,5,6]
    end



    @testset "var_decl_item" begin
        lexer = Lexer("var int: X_INTRODUCED_2_;")
        parser = Parser(lexer)
        node = var_decl_item(parser)
        @test node.type.name == int
        @test node.id == "X_INTRODUCED_2_"
        @test node.annotations === nothing
        @test node.annotations_values === nothing



        lexer = Lexer("var int: X_INTRODUCED_2_::output_var;")
        parser = Parser(lexer)
        node = var_decl_item(parser)
        @test node.type.name == int
        @test node.id == "X_INTRODUCED_2_"
        @test node.annotations.annotationsList[1].id == "output_var"
        @test node.annotations.annotationsList[1].value == []
        @test node.annotations_values === nothing


        lexer = Lexer("var float: X_INTRODUCED_2_::output_var;")
        parser = Parser(lexer)
        node = var_decl_item(parser)
        @test node.type.name == float
        @test node.id == "X_INTRODUCED_2_"
        @test node.annotations.annotationsList[1].id == "output_var"
        @test node.annotations.annotationsList[1].value == []
        @test node.annotations_values === nothing


        lexer = Lexer("var bool: X_INTRODUCED_2_::output_var;")
        parser = Parser(lexer)
        node = var_decl_item(parser)
        @test node.type.name == bool
        @test node.id == "X_INTRODUCED_2_"
        @test node.annotations.annotationsList[1].id == "output_var"
        @test node.annotations.annotationsList[1].value == []
        @test node.annotations_values === nothing

        lexer = Lexer("var 0..5: X_INTRODUCED_2_::output_var;")
        parser = Parser(lexer)
        node = var_decl_item(parser)
        @test node.type.type == int
        @test node.id == "X_INTRODUCED_2_"
        @test node.annotations.annotationsList[1].id == "output_var"
        @test node.annotations.annotationsList[1].value == []
        @test node.annotations_values === nothing
        @test node.type.start_value == 0
        @test node.type.end_value == 5

        lexer = Lexer("var {0,4,2,5}: X_INTRODUCED_2_::output_var;")
        parser = Parser(lexer)
        node = var_decl_item(parser)
        @test node.type.type == int
        @test node.id == "X_INTRODUCED_2_"
        @test node.annotations.annotationsList[1].id == "output_var"
        @test node.annotations.annotationsList[1].value == []
        @test node.annotations_values === nothing
        @test node.type.value == [0,4,2,5]
    end



    @testset "basic_pred_param_type" begin
        lexer = Lexer("bool")
        parser = Parser(lexer)
        node = basic_pred_param_type(parser)
        @test node.name == bool

        lexer = Lexer("int")
        parser = Parser(lexer)
        node = basic_pred_param_type(parser)
        @test node.name == int

        lexer = Lexer("float")
        parser = Parser(lexer)
        node = basic_pred_param_type(parser)
        @test node.name == float

        lexer = Lexer("1..5")
        parser = Parser(lexer)
        node = basic_pred_param_type(parser)
        @test node.type == int
        @test node.start_value == 1
        @test node.end_value == 5


        lexer = Lexer("1.2..5.0")
        parser = Parser(lexer)
        node = basic_pred_param_type(parser)
        @test node.type == float
        @test node.start_value == 1.2
        @test node.end_value == 5.0

        lexer = Lexer("{1,4,5}")
        parser = Parser(lexer)
        node = basic_pred_param_type(parser)
        @test node.type == int
        @test node.value == [1,4,5]


        lexer = Lexer("set of int")
        parser = Parser(lexer)
        node = basic_pred_param_type(parser)
        @test node.name == "set of int"

        lexer = Lexer("set of {1,4,5}")
        parser = Parser(lexer)
        node = basic_pred_param_type(parser)
        @test node.type == int
        @test node.value == [1,4,5]



        lexer = Lexer("set of 1..5")
        parser = Parser(lexer)
        node = basic_pred_param_type(parser)
        @test node.type == int
        @test node.value == [1,2,3,4,5]

        lexer = Lexer("var set of int")
        parser = Parser(lexer)
        node = basic_pred_param_type(parser)
        @test node.type == set
        @test node.id === ""
        @test node.annotations == []
        @test node.annotations_values == []



        lexer = Lexer("var bool")
        parser = Parser(lexer)
        node = basic_pred_param_type(parser)
        @test node.name == bool

    end



    @testset "par_type" begin
        lexer = Lexer("bool")
        parser = Parser(lexer)
        node = par_type(parser)
        @test node.name == bool

        lexer = Lexer("int")
        parser = Parser(lexer)
        node = par_type(parser)
        @test node.name == int

        lexer = Lexer("float")
        parser = Parser(lexer)
        node = par_type(parser)
        @test node.name == float

        lexer = Lexer("set of int")
        parser = Parser(lexer)
        node = par_type(parser)
        @test node.name == "set of int"

        lexer = Lexer("array[1..4] of bool")
        parser = Parser(lexer)
        node = par_type(parser)
        @test node.index.start_value == 1
        @test node.index.end_value == 4
        @test node.type.name== bool

        lexer = Lexer("array[1..4] of set of int")
        parser = Parser(lexer)
        node = par_type(parser)
        @test node.index.start_value == 1
        @test node.index.end_value == 4
        @test node.type.name == "set of int"
    end

    @testset "par_array_literal" begin
        lexer = Lexer("[true, true, false]")
        parser = Parser(lexer)
        node = par_array_literal(parser)
        @test node.values[1].value == true
        @test node.values[2].value == true
        @test node.values[3].value == false
        @test node.values[1].type == bool
        @test node.values[2].type == bool
        @test node.values[3].type == bool


        lexer = Lexer("[1, 4, 5]")
        parser = Parser(lexer)
        node = par_array_literal(parser)
        @test node.values[1].value == 1
        @test node.values[2].value == 4
        @test node.values[3].value == 5
        @test node.values[1].type == INT_CONST
        @test node.values[2].type == INT_CONST
        @test node.values[3].type == INT_CONST
    end

    @testset "par_decl_item" begin
        lexer = Lexer("bool: allo = true;")
        parser = Parser(lexer)
        node = par_decl_item(parser)
        @test node.type.name == bool
        @test node.id == "allo"
        @test node.expression.type == bool
        @test node.expression.value == true


        lexer = Lexer("array[1..4] of int: allo = [2,5,2,5];")
        parser = Parser(lexer)
        node = par_decl_item(parser)

        @test node.type.type.name ==  int
        @test node.type.index.start_value == 1        
        @test node.type.index.end_value == 4
        @test node.id == "allo"
        @test node.expression.values[1].type == INT_CONST
        @test node.expression.values[1].value == 2
        @test node.expression.values[2].type == INT_CONST
        @test node.expression.values[2].value == 5
        @test node.expression.values[3].type == INT_CONST
        @test node.expression.values[3].value == 2
        @test node.expression.values[4].type == INT_CONST
        @test node.expression.values[4].value == 5


    end

    @testset "constraint_expr" begin
        lexer = Lexer("constraint fzn_all_different_int(mesvariables)::oups;")
        parser = Parser(lexer)
        node = constraint_expr(parser)
        @test node.id == "fzn_all_different_int"
        @test node.expressions[1].type == ID
        @test node.expressions[1].value == "mesvariables"
        @test node.annotations.annotationsList[1].id == "oups"
        @test node.annotations.annotationsList[1].value == []

        lexer = Lexer("constraint int_lin_le(X_INTRODUCED_20_,[v_9,v_19],0);")
        parser = Parser(lexer)
        node = constraint_expr(parser)
        @test node.id == "int_lin_le"
        @test node.expressions[1].type == ID
        @test node.expressions[1].value == "X_INTRODUCED_20_"
        @test node.expressions[2].values[1].type == ID
        @test node.expressions[2].values[1].value == "v_9"
        @test node.expressions[2].values[2].type == ID
        @test node.expressions[2].values[2].value == "v_19"
        @test node.expressions[3].type == INT_CONST
        @test node.expressions[3].value == 0
        @test node.annotations.annotationsList == []

    end

    @testset "solve_item" begin
        lexer = Lexer("solve  minimize X_INTRODUCED_2_;")
        parser = Parser(lexer)
        node = solve_item(parser)

        @test node.annotations.annotationsList == []
        @test node.expressions.type == ID
        @test node.expressions.value == "X_INTRODUCED_2_"

        lexer = Lexer("solve :: int_search(var_array,first_fail,indomain,complete) satisfy;")
        parser = Parser(lexer)
        node = solve_item(parser)

        @test node.annotations.annotationsList[1].id == "int_search"
        @test node.annotations.annotationsList[1].value[1].id == "var_array"
        @test node.annotations.annotationsList[1].value[1].value == []
        @test node.annotations.annotationsList[1].value[2].id == "first_fail"
        @test node.annotations.annotationsList[1].value[2].value == []
        @test node.annotations.annotationsList[1].value[3].id == "indomain"
        @test node.annotations.annotationsList[1].value[3].value == []
        @test node.annotations.annotationsList[1].value[4].id == "complete"
        @test node.annotations.annotationsList[1].value[4].value == []
    end


    @testset "predicate_item" begin
        lexer = Lexer("predicate fzn_all_different_int(array [int] of var int: x); ")
        parser = Parser(lexer)
        node = predicate_item(parser)
        @test node.id == "fzn_all_different_int"
        @test node.items[1].type.type.name == int
        @test node.items[1].type.index.id == int
        @test node.items[1].id == "x"

    end

    @testset "model" begin
        lexer = Lexer("predicate fzn_all_different_int(array [int] of var int: x);
        var 1..3: X_INTRODUCED_0_;
        var 1..3: X_INTRODUCED_1_;
        var 1..3: X_INTRODUCED_2_;
        var 2.5..2.5: varr;
        array [1..3] of var int: mesvariables:: output_array([1..3]) = [X_INTRODUCED_0_,X_INTRODUCED_1_,X_INTRODUCED_2_];
        constraint fzn_all_different_int(mesvariables);
        solve  minimize X_INTRODUCED_2_;")
        parser = Parser(lexer)
        node = read_model(parser)
        @test length(node.predicates) == 1
        @test length(node.parameters) == 0
        @test length(node.variables) == 5
        @test length(node.constraints) == 1
        @test length(node.solves) == 1
    end
end

@testset "Interpreter" begin
    @testset "create_variable and all_different" begin

        model = "predicate fzn_all_different_int(array [int] of var int: x);
        var 1..3: X_INTRODUCED_0_;
        var 1..3: X_INTRODUCED_1_;
        var 1..3: X_INTRODUCED_2_;
        array [1..3] of var int: mesvariables:: output_array([1..3]) = [X_INTRODUCED_0_,X_INTRODUCED_1_,X_INTRODUCED_2_];
        constraint fzn_all_different_int(mesvariables);
        solve  minimize X_INTRODUCED_2_;"

        interpreter = create_model(model)
        @test length(interpreter.GLOBAL_VARIABLE) == 5
        @test interpreter.GLOBAL_VARIABLE["X_INTRODUCED_0_"].domain.min.value == 1
        @test interpreter.GLOBAL_VARIABLE["X_INTRODUCED_0_"].domain.max.value == 3
        @test interpreter.GLOBAL_VARIABLE["X_INTRODUCED_2_"].domain.min.value == 1
        @test interpreter.GLOBAL_VARIABLE["X_INTRODUCED_1_"].domain.max.value == 3
        @test interpreter.GLOBAL_VARIABLE["X_INTRODUCED_2_"].domain.min.value == 1
        @test interpreter.GLOBAL_VARIABLE["X_INTRODUCED_2_"].domain.max.value == 3

        @test length(interpreter.GLOBAL_CONSTRAINT) == 1
        @test typeof(interpreter.GLOBAL_CONSTRAINT[1]) == SeaPearl.AllDifferent

    end

    @testset "modele" begin

        model = "predicate fzn_all_different_int(array [int] of var int: x);        
        var 1..4: X_INTRODUCED_0_;
        var 3..4: X_INTRODUCED_1_;
        var 1..4: X_INTRODUCED_2_;
        var 2..8: X_INTRODUCED_3_:: is_defined_var;
        array [1..3] of var int: mesvariables:: output_array([1..3]) = [X_INTRODUCED_0_,X_INTRODUCED_1_,X_INTRODUCED_2_];
        constraint fzn_all_different_int(mesvariables);
        constraint int_lin_eq([1,1,-1],[X_INTRODUCED_2_,X_INTRODUCED_1_,X_INTRODUCED_3_],0):: defines_var(X_INTRODUCED_3_);
        solve  minimize X_INTRODUCED_3_;"

        interpreter = create_model(model)
        @test length(interpreter.GLOBAL_VARIABLE) == 9
        @test interpreter.GLOBAL_VARIABLE["X_INTRODUCED_0_"].domain.min.value == 1
        @test interpreter.GLOBAL_VARIABLE["X_INTRODUCED_0_"].domain.max.value == 4
        @test interpreter.GLOBAL_VARIABLE["X_INTRODUCED_1_"].domain.min.value == 3
        @test interpreter.GLOBAL_VARIABLE["X_INTRODUCED_1_"].domain.max.value == 4
        @test interpreter.GLOBAL_VARIABLE["X_INTRODUCED_2_"].domain.min.value == 1
        @test interpreter.GLOBAL_VARIABLE["X_INTRODUCED_2_"].domain.max.value == 4

        @test length(interpreter.GLOBAL_CONSTRAINT) == 1
        @test typeof(interpreter.GLOBAL_CONSTRAINT[1]) == SeaPearl.AllDifferent

    end
end




