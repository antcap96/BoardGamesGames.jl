using BoardGames
using Cairo

struct OthelloBoard
    v::Matrix{Int}
    turn::Int
end

struct Othello <:Game{OthelloBoard, Tuple{Int,Int}} end

function OthelloBoard()
    v = zeros(Int, (8,8))
    v[4,4] = -1
    v[4,5] =  1
    v[5,4] =  1
    v[5,5] = -1

    return OthelloBoard(v, 1)
end

function BoardGames.getmoves(board::OthelloBoard)
    ans = Tuple{Int,Int}[]

    for i in 1:8, j in 1:8
        if board.v[i,j] != 0
            continue
        end
        for direction in ((i,j) for i in -1:1 for j in -1:1
                                    if i != 0 || j != 0)
            pos = (i,j) .+ direction
            if checkmove(board.v, pos, direction, board.turn, false)
                push!(ans, (i,j))
                break
            end
        end
    end
    return ans
end

function BoardGames.play(board::OthelloBoard, move::Tuple{Int,Int})
    if !play in getmoves(board)
        error("illegal play $play")
    end
    v = copy(board.v)

    v[move...] = board.turn

    for direction in ((i,j) for i in -1:1 for j in -1:1
                                if i != 0 || j != 0)
        checkmove(v, move .+ direction, direction, board.turn, true)
    end

    if isempty(getmoves(OthelloBoard(v, -board.turn)))
        return OthelloBoard(v, board.turn)
    else
        return OthelloBoard(v, -board.turn)
    end
end

function checkmove(b, x, direction, player, fill::Bool, count=1)
    if !(1 <= x[1] <= 8) || !(1 <= x[2] <= 8) || b[x...] == 0
        return false
    end
    if b[x...] == player
        if count == 1
            return false
        else
            return true
        end
    end
    ans = checkmove(b, x.+direction, direction, player, fill, count+1)
    if ans && fill
        b[x...] = player
    end
    return ans
end

function BoardGames.playerturn(board::OthelloBoard)
    if board.turn == 1
        return 1
    else
        return 2
    end
end

function BoardGames.winner(board::OthelloBoard)
    if !isempty(getmoves(board))
        error("call winner on ongoing game")
    end
    p1 = sum(board.v .== 1)
    p2 = sum(board.v .== -1)
    if p1 > p2
        return 1
    elseif p2 > p1
        return 2
    else
        return 0
    end
end

function Base.show(io::IO, b::OthelloBoard)
    print(io, "OtheloBoard($(b.v), $(b.turn))")
end

function Base.show(io::IO, ::MIME"text/plain", b::OthelloBoard)
    icon = Dict(-1=>"o", 0=>".", 1=>"x")

    s = "\n"

    for i in 1:8
        s *= join(map(x->icon[x], b.v[i,:])) * "\n"
    end
    print(io,s)
end
