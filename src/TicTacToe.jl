using BoardGames
using Cairo
using StaticArrays

struct TicTacToeBoard
    v::SVector{9,Int}
    turn::Int
    winner::Int
end

struct TicTacToe <: Game{TicTacToeBoard, Int} end

function TicTacToeBoard()
    v = @SVector zeros(Int, (9))
    turn = 1
    winner = 0

    TicTacToeBoard(v, turn, winner)
end

function BoardGames.getmoves(board::TicTacToeBoard)
    ans = Int[]
    if board.winner != 0
        return ans
    end
    for i in 1:length(board.v) #1:9
        if board.v[i] == 0
            push!(ans, i)
        end
    end
    return ans
end

function Base.copy(board::TicTacToeBoard)
    TicTacToeBoard(copy(board.v), board.turn, board.winner)
end

const lines = [SA[1,2,3], SA[4,5,6], SA[7,8,9], #rows
               SA[1,4,7], SA[2,5,8], SA[3,6,9], #columns
               SA[1,5,9], SA[3,5,7]]            #diagonals

function BoardGames.play(board::TicTacToeBoard, move::Int)
    if board.winner != 0 || move > 9 || move < 1 ||
        board.v[move] != 0
        error("attempt to play impossible move $move on board $board")
    end

    v = @SVector [i == move ? board.turn : board.v[i] for i = 1:9]
    turn = -board.turn

    winner = 0
    for l in lines
        if all(v[l] .== board.turn)
            winner = board.turn
        end
    end

    TicTacToeBoard(v, turn, winner)
end

function BoardGames.playerturn(board::TicTacToeBoard)
    if board.turn == 1
        return 1
    else
        return 2
    end
end

function BoardGames.winner(board::TicTacToeBoard)
    if isempty(getmoves(board))
        if board.winner == 0
            return 0
        else
            return board.winner == -1 ? 2 : 1
        end
    else
        error("call winner on ongoing game")
    end
end

function Base.show(io::IO, b::TicTacToeBoard)
    print(io, "TicTacToeBoard($(b.v), $(b.turn), $(b.winner))")
end

function Base.show(io::IO, ::MIME"text/pain", b::TicTacToeBoard)
    icon = Dict(-1=>"o", 0=>" ", 1=>"x")

    s = "\n"

    for i in 1:11
        if i % 2 == 1
            s *= ("       |")^2*"     \n"
        elseif i % 4 == 2
            s *= "   " * icon[b.v[3*(i÷4)+1]] * "   |   " *
                 icon[b.v[3*(i÷4)+2]] * "   |   " *
                 icon[b.v[3*(i÷4)+3]] * "   \n"
        else
            s *="-------+-------+-------\n"
        end
    end

    print(io,s)
end

function Base.show(io::IO, m::MIME{Symbol("image/png")}, b::TicTacToeBoard)
    c, cr = baseboard(300., 300.)
    for i in 1:9
        if b.v[i] == 1
            draw_cross(c, cr, i)
        elseif b.v[i] == -1
            draw_circle(c, cr, i)
        end
    end
    show(io, m, c)
    nothing
end

function baseboard(w::Real=300., h::Real=300.)
    c = CairoRGBSurface(w,h)
    cr = CairoContext(c)

    save(cr) #TODO: what does this do?
    set_source_rgb(cr,1.0,1.0,1.0)
    rectangle(cr,0.0,0.0,w,h)
    fill(cr)
    restore(cr) #TODO: what does this do?

    save(cr)

    ## original example, following here

    x0=0   ; y0=0  ;
    x1=w/3 ; y1=h/3;
    x2=2w/3; y2=2h/3;
    x3=w   ; y3=h;

    set_line_width(cr, 10.0)
    stroke(cr)

    set_source_rgba(cr, 0, 0, 0, 1)
    set_line_width(cr, 6.0)
    move_to(cr,x0,y1); line_to(cr,x3,y1);
    move_to(cr,x0,y2); line_to(cr,x3,y2);
    move_to(cr,x1,y0); line_to(cr,x1,y3);
    move_to(cr,x2,y0); line_to(cr,x2,y3);
    stroke(cr);

    (c, cr)
end

function draw_cross(c, cr, i::Integer, w::Real=300., h::Real=300.)
    set_line_width(cr, min(w,h)/20)
    set_source_rgb(cr,1.0,0.0,0.0)
    x = (i-1) % 3
    y = (i-1) ÷ 3

    move_to(cr, x*(w/3)+ (w/15), y*(h/3)+ (h/15))
    line_to(cr, x*(w/3)+4(w/15), y*(h/3)+4(h/15))
    move_to(cr, x*(w/3)+ (w/15), y*(h/3)+4(h/15))
    line_to(cr, x*(w/3)+4(w/15), y*(h/3)+ (h/15))
    stroke(cr);
end

function draw_circle(c, cr, i::Integer, w::Real=300., h::Real=300.)
    set_line_width(cr, min(w,h)/20)
    set_source_rgb(cr,0.2,0.2,1.0)
    x = (i-1) % 3
    y = (i-1) ÷ 3
    circle(cr, (w/3)*x+w/6, (h/3)*y+h/6, min(w,h)/10)
    stroke(cr)
end
