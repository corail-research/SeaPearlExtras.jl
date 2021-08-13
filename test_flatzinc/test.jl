using Base: parameter_upper_bound, Bool, Float16
using Test
include("../flatzinc/lexer.jl")
include("../flatzinc/parser.jl")

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

    @testset "parameter statement" begin
        lexer = Lexer("bool: allo = true;")
        parser = Parser(lexer)
        node = parameter(parser)
        @test node.id == "allo"
        @test node.type == bool 
        @test node.value == true
    end

    @testset "parameter statement" begin
        lexer = Lexer("int: allo = 45;")
        parser = Parser(lexer)
        node = parameter(parser)
        @test node.id == "allo"
        @test node.type == int
        @test node.value == 45
    end

    @testset "parameter statement" begin
        lexer = Lexer("float: allo = 4.33;")
        parser = Parser(lexer)
        node = parameter(parser)
        @test node.id == "allo"
        @test node.type == float
        @test node.value == 4.33
    end

    @testset "parameter statement" begin
        lexer = Lexer("set of int: allo = { 4,5,9};")
        parser = Parser(lexer)
        node = parameter(parser)
        @test node.id == "allo"
        @test node.type == set
        @test node.value == [4,5,9]
    end


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
        @test node.id ==  ""
        @test node.annotations == []
        @test node.annotations_values == []

        lexer = Lexer("var bool")
        parser = Parser(lexer)
        node = basic_pred_param_type(parser)
        @test node.name == bool

    end


end
