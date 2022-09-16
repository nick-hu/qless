#!/usr/bin/env julia

struct Polyomino
    squares::Set{CartesianIndex{2}}

    function Polyomino(squares::Set{CartesianIndex{2}})
        minrow = minimum(s[1] for s in squares)
        mincol = minimum(s[2] for s in squares)

        return new(Set(s - CartesianIndex(minrow, mincol) +
                       CartesianIndex(1, 1)
                       for s in squares))
    end
end

Base.isequal(p::Polyomino, q::Polyomino) = isequal(p.squares, q.squares)
Base.hash(p::Polyomino) = hash(p.squares)
