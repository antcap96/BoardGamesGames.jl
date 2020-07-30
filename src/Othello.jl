using BoardGames
using Cairo

mutable struct  OthelloBoard
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

function hasmoves(board::OthelloBoard)
    for i in 1:8, j in 1:8
        if board.v[i,j] != 0
            continue
        end
        for direction in ((i,j) for i in -1:1 for j in -1:1
                                    if i != 0 || j != 0)
            pos = (i,j) .+ direction
            if checkmove(board.v, pos, direction, board.turn, false)
                return true
            end
        end
    end
    return false
end

function BoardGames.play(board::OthelloBoard, move::Tuple{Int,Int})
    validmove = false
    v = copy(board.v)
    if board.v[move...] != 0
        error("illegal play $play")
    end

    v[move...] = board.turn

    for direction in ((i,j) for i in -1:1 for j in -1:1
                                if i != 0 || j != 0)
        if checkmove(v, move .+ direction, direction, board.turn, true)
            validmove = true
        end
    end

    if !validmove
        error("illegal play $play")
    end

    if !hasmoves(OthelloBoard(v, -board.turn))
        return OthelloBoard(v, board.turn)
    else
        return OthelloBoard(v, -board.turn)
    end
end

function BoardGames.play!(board::OthelloBoard, move::Tuple{Int,Int})
    validmove = false

    if board.v[move...] != 0
        error("illegal play $play")
    end


    board.v[move...] = board.turn

    for direction in ((i,j) for i in -1:1 for j in -1:1
                                if i != 0 || j != 0)
        if checkmove(board.v, move .+ direction, direction, board.turn, true)
            validmove = true
        end
    end

    if !validmove
        error("illegal play $play")
    end
    
    board.turn = -board.turn
    if hasmoves(board)
        return board
    else
        board.turn = -board.turn
        return board
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
    if hasmoves(board)
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

function Base.show(io::IO, m::MIME{Symbol("image/png")}, b::OthelloBoard)
    c, cr = baseboard(800., 800.)
    for i in 1:8, j in 1:8
        if b.v[i,j] != 0
            draw_circle(c, cr, (i,j), b.v[i,j])
        end
    end
    show(io, m, c)
    nothing
end

function baseboard(w::Real=800., h::Real=800.)
    c = CairoRGBSurface(w,h)
    cr = CairoContext(c)

    save(cr) #TODO: what does this do?
    set_source_rgb(cr, 0., 153/255, 51/255)
    rectangle(cr,0.0,0.0,w,h)
    fill(cr)
    restore(cr) #TODO: what does this do?

    ## original example, following here

    for x in 1:7
        set_source_rgba(cr, 0, 0, 0, 1)
        set_line_width(cr, 3.0)
        move_to(cr, 0., x/8*w); line_to(cr, w, x/8*w);
        move_to(cr, x/8*w, 0.); line_to(cr, x/8*w, h);
        stroke(cr);
    end
    (c, cr)
end

function draw_circle(c, cr, i::Tuple{Int,Int}, player::Int, w::Real=800., h::Real=800.)
    if player == 1
        set_source_rgb(cr,0.0,0.0,0.0)
    else
        set_source_rgb(cr,1.0,1.0,1.0)
    end

    x = w/16 + (i[1]-1)*w/8
    y = h/16 + (i[2]-1)*h/8
    circle(cr, x, y, min(w,h)/24)
    fill_preserve(cr)
    stroke(cr)
end
