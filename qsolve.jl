#!/usr/bin/env julia

using JLD2: load

include("polyomino.jl")

struct Layout{A<:Matrix, B<:Vector}
    grid::A
    words::B
end

function Base.copy(layout::Layout)
    grid = similar(layout.grid)
    unsafe_copyto!(grid, 1, layout.grid, 1, length(layout.grid))

    words = similar(layout.words)
    for i in 1:length(layout.words)
        words[i] = @view grid[layout.words[i].indices...]
    end

    return Layout(grid, words)
end

function Base.println(layout::Layout)
    rows, cols = size(layout.grid)

    for row in 1:rows
        for col in 1:cols
            c = layout.grid[row, col]
            print(ismissing(c) ? '?' : c)
        end
        print('\n')
    end
    print('\n')
end

struct LetterSet <: AbstractVector{Int}
    vec::Vector{Int}
end

Base.size(ls::LetterSet) = (26, )
Base.getindex(ls::LetterSet, i::Int) = ls.vec[i]
Base.getindex(ls::LetterSet, c::Char) = ls.vec[c-'A'+1]
Base.setindex!(ls::LetterSet, n::Int, i::Int) = (ls.vec[i] = n)
Base.setindex!(ls::LetterSet, n::Int, c::Char) = (ls.vec[c-'A'+1] = n)
Base.IndexStyle(::Type{<:LetterSet}) = IndexLinear()

function Base.copy(ls::LetterSet)
    new_ls = LetterSet(Vector{Int}(undef, 26))
    return copy!(new_ls, ls)
end

function Base.copy!(dst::LetterSet, src::LetterSet)
    unsafe_copyto!(dst.vec, 1, src.vec, 1, 26)
    return dst
end

function generate_layouts(filename::String)
    T = Vector{CartesianIndex{2}}
    qpolyblocks = load(filename, "qpolyblocks")::Vector{Vector{T}}

    layouts = Layout[]

    for blocks in qpolyblocks
        maxrow = maximum(s[1] for block in blocks for s in block)
        maxcol = maximum(s[2] for block in blocks for s in block)

        grid = Matrix{Union{Char, Missing}}(undef, maxrow, maxcol)
        fill!(grid, ' ')

        words = [grid[block] .= missing for block in blocks]

        push!(layouts, Layout(grid, words))
    end

    return layouts
end

function generate_wordlist(filename::String, letters::LetterSet,
                           N::Int=12)

    wordlist = [String[] for _ in 1:N]

    for line in eachline(filename)
        line = uppercase(filter(isletter, line))

        (length(line) < 3 || length(line) > 12) && continue

        is_constructible = true

        for letter in Set(line)
            if (iszero(letters[letter]) ||
                count(letter, line) > letters[letter])
                is_constructible = false
                break
            end
        end

        if is_constructible
            push!(wordlist[length(line)], line)
        end
    end

    return wordlist
end

function solve_layout(layout::Layout, letters::LetterSet,
                      wordlist::Vector{Vector{String}})

    if isempty(layout.words)
        println(layout)
        return 1
    end

    solcount = 0
    solutions = solve_word(layout.words[end], letters, wordlist)

    for (string, new_letters) in solutions
        new_layout = copy(layout)

        new_layout.words[end] .= Vector{Char}(string)
        pop!(new_layout.words)

        all_valid_words = true
        for word in filter(w -> !any(ismissing, w), new_layout.words)
            if !(String(convert(Vector{Char}, word))
                 in wordlist[length(word)])
                all_valid_words = false
                break
            end
        end

        if all_valid_words
            solcount += solve_layout(new_layout, new_letters, wordlist)
        end
    end

    return solcount
end

function solve_word(word::T,
                    letters::LetterSet,
                    wordlist::Vector{Vector{String}}) where {T}

    solutions = Pair{String, LetterSet}[]

    for string in wordlist[length(word)]
        is_solution = true
        new_letters = copy(letters)

        for (i, c) in enumerate(word)
            if ismissing(c)
                if iszero(new_letters[string[i]])
                    is_solution = false
                    break
                end
                new_letters[string[i]] -= 1
            elseif c ≠ string[i]
                is_solution = false
                break
            end
        end

        if is_solution
            push!(solutions, string=>new_letters)
        end
    end

    return solutions
end


input = uppercase(ARGS[1])
letters = LetterSet([count(c, input) for c in 'A':'Z'])

@info "Generating wordlist"
wordlist = generate_wordlist(length(ARGS) == 1 ? "NWL2020.txt" : ARGS[2],
                             letters)

@info "Generating layouts"
layouts = generate_layouts("qpoly.jld2")

@info "Generating solutions"
let solcount = 0
    for (i, layout) in enumerate(layouts)
        solcount += solve_layout(layout, letters, wordlist)
        if iszero(rem(i, 1000))
            @info "$i/$(length(layouts)) layouts solved"
        end
    end
    @info "$solcount solutions found"
end
