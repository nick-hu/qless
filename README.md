# qsolve

A [Q-Less](https://q-lessgame.com/) game solver.

## Requirements

[Julia](https://julialang.org/) (v1.8.0+ recommended) and the [JLD2](https://github.com/JuliaIO/JLD2.jl) package.

## Usage

Run `julia qsolve.jl LETTERS [WORDLIST]`, where `LETTERS` are the letters rolled and `WORDLIST` is a file containing a (newline-separated) list of acceptable words; for instance, `julia qsolve.jl adhjmorrtuvx Routledge-5K.txt`.

If `WORDLIST` is omitted, the default file used is `NWL2020.txt` (the 2020 NASPA Word List). For easier rolls, the file `Routledge-5K.txt` (the 2010 Routledge list of the 5000 most frequent words in contemporary American English) typically yields several solutions and is much quicker to search with.

## FAQs

- Are there any unsolvable rolls?
	- Yes; for instance, `fgjlmmnnnoot` is unsolvable (using the NASPA list).
- What percentage of rolls are unsolvable?
	- In a trial consisting of 5000 random rolls, only 31 (0.62%) were unsolvable using the NASPA list; in a trial consisting of 1000 random rolls, 472 (47.2%) were unsolvable using the Routledge list. This suggests that the vast majority of rolls are solvable and that around half are easily solvable.
