using Test
include("../flatzinc/lexer.jl")
@testset "Lexer" begin
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
        @test token.type == COMMA
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
        @test token.type == COMMA
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
        @test token.type == COMMA
        @test token.value == ';'
        token = getNextToken(lexer)
        @test token.type == EOF
        @test token.value === nothing
    end


    @testset "all tokens" begin
        lexer = Lexer("var int : = allo  ; :: bool float ( ) [] true false set of array .. {}
                             predicate constraint solve satisfy minimize maximize 
                             0x 0o")
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
        @test token.type == COMMA
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
        @test token.value == "true"

        token = getNextToken(lexer)
        @test token.type == FALSE
        @test token.value == "false"

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
        @test token.type == EOF
        @test token.value === nothing
    end
end


