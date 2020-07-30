using BoardGames
using BoardGamesGames
using BoardGamesGames.TicTacToeGame
using BoardGamesGames.OthelloGame
using Test

b = TicTacToeBoard()
for i in 1:7
    global b = play(b, i)
end

function randomgame(board)
    while !isempty(getmoves(board))
        m = rand(getmoves(board))
        board = play(board, m)
    end
    board
end

othello_test_board = zeros(Int, (8,8))
othello_test_board[8,6] =  1
othello_test_board[7,7] = -1
othello_test_board[6,8] = 1
othello_test_board[8,7] = -1

othello_test_board = OthelloBoard(othello_test_board, -1)

new_othello = OthelloBoard()

function Base.:(==)(b1::OthelloBoard, b2::OthelloBoard)
    return b1.v == b2.v && b1.turn == b2.turn
end

@testset "BoardGamesGames.jl" begin
    # Write your tests here.
    @test TicTacToeBoard().turn == 1
    @test getmoves(TicTacToeBoard()) == 1:9
    @test getmoves(play(TicTacToeBoard(), 5)) == (1:4) ∪ (6:9)
    @test playerturn(play(TicTacToeBoard(), 5)) == 2
    @test b.winner == 1
    @test winner(b) == 1
    @test show(stdout, MIME"image/png"(), b) === nothing
    @test show(b) === nothing
    @test 0 <= winner(randomgame(TicTacToeBoard())) <= 2

    @test playerturn(OthelloBoard()) == 1
    @test playerturn(play(OthelloBoard(), (3,4))) == 2
    @test show(OthelloBoard()) === nothing
    @test 0 <= winner(randomgame(OthelloBoard())) <= 2
    @test getmoves(othello_test_board) == [(8,5)]
    @test winner(play(othello_test_board, (8,5))) == 2
    @test show(stdout, MIME"image/png"(), othello_test_board) === nothing
    @test show(othello_test_board) === nothing
    @test play!(new_othello, (3,4)) == play(OthelloBoard(), (3,4))

end
