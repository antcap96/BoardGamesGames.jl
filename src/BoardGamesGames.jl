module BoardGamesGames

using BoardGames

export
    # Types
    TicTacToe,
    TicTacToeBoard,

    getmoves,
    play,
    playerturn

# Write your package code here.

include("TicTacToe.jl")

end
