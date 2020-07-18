using BoardGamesGames
using Test

b = TicTacToeBoard()
for i in 1:7
    global b = play(b, i)
end


@testset "BoardGamesGames.jl" begin
    # Write your tests here.
    @test TicTacToeBoard().turn == 1
    @test b.winner == 1

end
