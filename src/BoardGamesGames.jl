module BoardGamesGames

using BoardGames

module TicTacToeGame
    include("TicTacToe.jl")

    export
        #types
        TicTacToe,
        TicTacToeBoard
end

module OthelloGame
    include("Othello.jl")

    export
        #types
        Othello,
        OthelloBoard
end


#=export
    # Types
    TicTacToe,
    TicTacToeBoard,

    getmoves,
    play,
    playerturn
=#
# Write your package code here.

#include("TicTacToe.jl")

end
