using BoardGames
using BoardGamesGames
using Test

b = TicTacToeBoard()
for i in 1:7
    global b = play(b, i)
end


@testset "BoardGamesGames.jl" begin
    # Write your tests here.
    @test TicTacToeBoard().turn == 1
    @test getmoves(TicTacToeBoard()) == 1:9
    @test getmoves(play(TicTacToeBoard(), 5)) == (1:4) ∪ (6:9)
    @test playerturn(play(TicTacToeBoard(), 5)) == 2
    @test b.winner == 1
    @test winner(b) == 1
    @test show(stdout, MIME"image/png"(), b) == nothing
    @test show(b) == nothing

end
