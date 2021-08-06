using Base: parameter_upper_bound, Bool
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
                             0x 0o  1.33 321 ,")
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
        @test token.value === "0x"

        token = getNextToken(lexer)
        @test token.type == octal
        @test token.value === "0o"

        token = getNextToken(lexer)
        @test token.type == REAL_CONST
        @test token.value === 1.33

        token = getNextToken(lexer)
        @test token.type == INT_CONST
        @test token.value === 321

        token = getNextToken(lexer)
        @test token.type == COMMA
        @test token.value === ','


        token = getNextToken(lexer)
        @test token.type == EOF
        @test token.value === nothing
    end
end

@testset "Parser" begin
    
    @testset "variable statement" begin
        lexer = Lexer("var int: X_INTRODUCED_2_;")
        parser = Parser(lexer)
        node = variable(parser)
        @test node.type == int
        @test node.id == "X_INTRODUCED_2_"
        @test node.annotation === nothing
    end
    
    @testset "variable statement" begin
        lexer = Lexer("var int: X_INTRODUCED_2_::output_var;")
        parser = Parser(lexer)
        node = variable(parser)
        @test node.type == int
        @test node.id == "X_INTRODUCED_2_"
        @test node.annotation == "output_var"
    end
    
    @testset "variable statement" begin
        lexer = Lexer("var float: X_INTRODUCED_2_::output_var;")
        parser = Parser(lexer)
        node = variable(parser)
        @test node.type == float
        @test node.id == "X_INTRODUCED_2_"
        @test node.annotation == "output_var"
    end
    
    @testset "variable statement" begin
        lexer = Lexer("var bool: X_INTRODUCED_2_::output_var;")
        parser = Parser(lexer)
        node = variable(parser)
        @test node.type == bool
        @test node.id == "X_INTRODUCED_2_"
        @test node.annotation == "output_var"
    end

    @testset "variable statement" begin
        lexer = Lexer("var 0..5: X_INTRODUCED_2_::output_var;")
        parser = Parser(lexer)
        node = variable(parser)
        @test node.type == INT_CONST
        @test node.id == "X_INTRODUCED_2_"
        @test node.annotation == "output_var"
        @test node.min == 0
        @test node.max == 5
    end
    
    @testset "variable statement" begin
        lexer = Lexer("var {0,4,2,5}: X_INTRODUCED_2_::output_var;")
        parser = Parser(lexer)
        node = variable(parser)
        @test node.id == "X_INTRODUCED_2_"
        @test node.annotation == "output_var"
        @test node.domain == [0,4,2,5]
    end
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
    @testset "array statement" begin
        lexer = Lexer("array[1..3] of var int: allo;")
        parser = Parser(lexer)
        node = array_litteral(parser)
        @test node.start_index == 1
        @test node.end_index == 3
        @test node.variable_node.id == "allo"
        @test node.variable_node.type == int 
        @test node.variable_node.annotation === nothing
    end

    @testset "array statement" begin
        lexer = Lexer("array[1..3] of var float: allo;")
        parser = Parser(lexer)
        node = array_litteral(parser)
        @test node.start_index == 1
        @test node.end_index == 3
        @test node.variable_node.id == "allo"
        @test node.variable_node.type == float 
        @test node.variable_node.annotation === nothing
    end

    @testset "array statement" begin
        lexer = Lexer("array[1..3] of var 1..6: allo;")
        parser = Parser(lexer)
        node = array_litteral(parser)
        @test node.start_index == 1
        @test node.end_index == 3
        @test node.variable_node.id == "allo"
        @test node.variable_node.min == 1
        @test node.variable_node.max == 6
        @test node.variable_node.annotation === nothing
    end

    @testset "array statement" begin
        lexer = Lexer("array[1..3] of var {3,5,6}: allo::oups;")
        parser = Parser(lexer)
        node = array_litteral(parser)
        @test node.start_index == 1
        @test node.end_index == 3
        @test node.variable_node.id == "allo"
        @test node.variable_node.domain == [3,5,6]
        @test node.variable_node.annotation == "oups"
    end
end
