# BoxSymmetries

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://jw3126.github.io/BoxSymmetries.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://jw3126.github.io/BoxSymmetries.jl/dev)
[![Build Status](https://github.com/jw3126/BoxSymmetries.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/jw3126/BoxSymmetries.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/jw3126/BoxSymmetries.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/jw3126/BoxSymmetries.jl)

[BoxSymmetries.jl](https://github.com/jw3126/BoxSymmetries.jl) allows applying box symmetries to arrays in arbitrary dimensions.

# Usage
```julia
julia> using BoxSymmetries

julia> g = sym(-1,2) # flip the first axis
sym(-1, 2)

julia> g([1 2 3; 4 5 6])
2×3 Matrix{Int64}:
 4  5  6
 1  2  3

julia> g = sym(2,1) # permute axes
sym(2, 1)

julia> g([1 2 4; 4 5 6])
3×2 Matrix{Int64}:
 1  4
 2  5
 4  6

julia> g = sym(-1,-2) # flip both axes
sym(-1, -2)

julia> g([1 2; 3 4])
2×2 Matrix{Int64}:
 4  3
 2  1

julia> arr = randn(1,2,3,4);

julia> g = sym(4,-2,1,-3) # permute axes and flip some of them
sym(4, -2, 1, -3)

julia> size(g(arr))
(4, 2, 1, 3)
```
# Theory
We define the group of box symmetries of dimension N to be all linear maps ℝᴺ → ℝᴺ that map the 
cube [-1,1]ᴺ onto itself.
One can check that such maps must map coordinate axes onto coordinate axes and preserve length.
It follows that box symmetries are in bijection with the following data:
```julia
struct BoxSymmetry
    # We only allow valid permutations. E.g. (1,3,2) is ok, but (1,1,2) and (1,2,4) are not
    permutation::NTuple{N,Int}
    flipsign::NTuple{N,Bool}
end
```
where
* The field permutation encoded a permutation of 1:N that describes, which axis maps to which.
* The field flipsign records for which axes the sign is flipped

To compactly denote this data, we use the `sym` notation, that is best explained by example:
* `sym( 2, 1)`: (x,y) ↦ ( y, x)
* `sym(-1, 2)`: (x,y) ↦ (-x, y)
* `sym( 1,-2)`: (x,y) ↦ ( x,-y)
* `sym( 2, 1, -3)`: (x,y,z) ↦ ( y, x, -z)


# Alternatives 
For the use case of 2d images, there are alternatives:
* [SquareSymmetries.jl](https://github.com/icetube23/SquareSymmetries.jl)
* [Augmentor.jl](https://github.com/Evizero/Augmentor.jl)
