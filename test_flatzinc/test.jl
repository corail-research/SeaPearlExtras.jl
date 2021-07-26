using Test
include("../flatzinc/lexer.jl")
@testset "Lexer" begin
    lexer = Lexer("var int: X_INTRODUCED_2_;")
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
    @test token.type == COMMA
    @test token.value == ';'
    token = getNextToken(lexer)
    @test token.type == EOF
    @test token.value === nothing
end

revise_user = "You use Revise, you're efficient in your work, well done ;)" 
