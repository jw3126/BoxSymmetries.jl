module BoxSymmetries
export BoxSym

using Random: AbstractRNG, Random
using ArgCheck
struct Permutation{N}
    perm::NTuple{N,Int}
    function Permutation(perm::NTuple{N,Int}) where {N}
        @argcheck ispermutation(perm)
        return new{N}(perm)
    end
end
function ispermutation(perm::NTuple{N,Int}) where {N}
    ret = true
    for key in ntuple(identity, Val(N))
        ret = ret & (key in perm)
    end
    ret
end
ispermutation(perm::Permutation) = true
function act_tuple(p::Permutation{N}, t::NTuple{N}) where {N}
    map(p.perm) do i
        @inbounds t[i]
    end
end
function inverse(p::Permutation{N})::Permutation{N} where {N}
    Permutation(map(ntuple(identity, Val(N))) do i
        indexof(p.perm, i)
    end)
end
function indexof(t::NTuple, item)
    for i in eachindex(t)
        if t[i] === item
            return i
        end
    end
    error()
end
function unit(::Type{Permutation{N}}) where {N}
    Permutation(ntuple(identity, Val(N)))
end
function compose(p1::Permutation{N}, p2::Permutation{N})::Permutation{N} where {N}

end

struct BoxSym{N}
    axesperm::Permutation
    flipsign::NTuple{N,Bool}
end
Base.ndims(o::BoxSym{N}) where {N} = N
Base.ndims(::Type{BoxSym{N}}) where {N} = N

function outaxes(o::BoxSym, axes::Tuple)
    @argcheck length(axes) == ndims(o)
    act_tuple(o.axesperm, axes)
end

function act_array!(out::AbstractArray{<:Any, N}, o::BoxSym{N}, x) where {N}
    @argcheck axes(out) == outaxes(o, axes(x))
    flipped_axes = map(flipaxis, axes(out), o.flipsign)
    @inbounds for I in CartesianIndices(x)
        inds = Tuple(I)
        inds = act_tuple(o.axesperm, inds)
        inds = map(getindex,flipped_axes, inds)
        Iout = CartesianIndex(inds)
        out[Iout] = x[I]
    end
    out
end
function act_array(o::BoxSym, x)
    out = similar(x, outaxes(o,axes(x)))
    act_array!(out, o, x)
end

function (o::BoxSym)(x)
    act_array(o,x)
end

function flipaxis(ax::AbstractRange, flip::Bool)
    if flip
        last(ax):-step(ax):first(ax)
    else
        first(ax):step(ax):last(ax)
    end
end

"""

    BoxSym(args::Integer...)

Create a box symmetry, according to args.
"""
function BoxSym(args::Integer...)
    perm = Permutation(map(Int∘abs, args))
    flip = map(<(0), args)
    ret = BoxSym(perm, flip)
    ret
end
function astuple(o::BoxSym)
    (-1) .^ (o.flipsign) .* o.axesperm.perm

end
function Base.show(io::IO, o::BoxSym)
    print(io, "BoxSym", astuple(o))
end

################################################################################
#### instances
################################################################################

const SYMMETRIES1D = [BoxSym(1), BoxSym(-1)]
const SYMMETRIES2D = [
    BoxSym(1,2), BoxSym(1,-2), BoxSym(-1,2), BoxSym(-1,-2),
    BoxSym(2,1), BoxSym(2,-1), BoxSym(-2,1), BoxSym(-2,-1),
]
const SYMMETRIES3D = [
    BoxSym(1,2,3), BoxSym(1,2,-3), BoxSym(1,-2,3), BoxSym(1,-2,-3), BoxSym(-1,2,3), BoxSym(-1,2,-3), BoxSym(-1,-2,3), BoxSym(-1,-2,-3), 
    BoxSym(1,3,2), BoxSym(1,3,-2), BoxSym(1,-3,2), BoxSym(1,-3,-2), BoxSym(-1,3,2), BoxSym(-1,3,-2), BoxSym(-1,-3,2), BoxSym(-1,-3,-2), 
    BoxSym(3,2,1), BoxSym(3,2,-1), BoxSym(3,-2,1), BoxSym(3,-2,-1), BoxSym(-3,2,1), BoxSym(-3,2,-1), BoxSym(-3,-2,1), BoxSym(-3,-2,-1), 
    BoxSym(2,1,3), BoxSym(2,1,-3), BoxSym(2,-1,3), BoxSym(2,-1,-3), BoxSym(-2,1,3), BoxSym(-2,1,-3), BoxSym(-2,-1,3), BoxSym(-2,-1,-3), 
    BoxSym(2,3,1), BoxSym(2,3,-1), BoxSym(2,-3,1), BoxSym(2,-3,-1), BoxSym(-2,3,1), BoxSym(-2,3,-1), BoxSym(-2,-3,1), BoxSym(-2,-3,-1), 
    BoxSym(3,1,2), BoxSym(3,1,-2), BoxSym(3,-1,2), BoxSym(3,-1,-2), BoxSym(-3,1,2), BoxSym(-3,1,-2), BoxSym(-3,-1,2), BoxSym(-3,-1,-2), 
]


Base.instances(::Type{BoxSym{1}}) = SYMMETRIES1D
Base.instances(::Type{BoxSym{2}}) = SYMMETRIES2D
Base.instances(::Type{BoxSym{3}}) = SYMMETRIES3D

Random.rand(rng::AbstractRNG, G::Type{<:BoxSym}) = rand(rng, instances(G))

################################################################################
#### Precompile
################################################################################
let
    BoxSym(1)(Float64[1])
    BoxSym(1,-2)(Float64[1;;])
    BoxSym(1,-2,3)(Float64[1;;;])
end

# TODO lazy iterator of all symmetries of given dimension
# TODO composition + inversion of symmetries
# TODO isrotation for checking if orientation is preserved
# TODO aliases like rot90
end #module
