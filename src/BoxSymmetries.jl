module BoxSymmetries
export sym

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

struct BoxSymmetry{N}
    axesperm::Permutation
    flipsign::NTuple{N,Bool}
end
Base.ndims(o::BoxSymmetry{N}) where {N} = N
Base.ndims(::Type{BoxSymmetry{N}}) where {N} = N

function outaxes(o::BoxSymmetry, axes::Tuple)
    @argcheck length(axes) == ndims(o)
    act_tuple(o.axesperm, axes)
end

function act_array!(out::AbstractArray{<:Any, N}, o::BoxSymmetry{N}, x) where {N}
    @argcheck axes(out) == outaxes(o, axes(x))
    flipped_axes = map(flipaxis, axes(x), o.flipsign)
    @inbounds for I in CartesianIndices(x)
        indsx = Tuple(I)
        indsf = map(getindex,flipped_axes, indsx)
        indsfp = act_tuple(o.axesperm, indsf)
        Iout = CartesianIndex(indsfp)
        out[Iout] = x[I]
    end
    out
end
function act_array(o::BoxSymmetry, x)
    out = similar(x, outaxes(o,axes(x)))
    act_array!(out, o, x)
end

function (o::BoxSymmetry)(x)
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

    sym(args::Integer...)

Create a box symmetry, according to args.
"""
function sym(args::Integer...)
    perm = Permutation(map(Int∘abs, args))
    flip = map(<(0), args)
    ret = BoxSymmetry(perm, flip)
    ret
end
function astuple(o::BoxSymmetry)
    (-1) .^ (o.flipsign) .* o.axesperm.perm

end
function Base.show(io::IO, o::BoxSymmetry)
    print(io, "sym", astuple(o))
end

################################################################################
#### symmetries
################################################################################

const SYMMETRIES1D = [sym(1), sym(-1)]
const SYMMETRIES2D = [
    sym(1,2), sym(1,-2), sym(-1,2), sym(-1,-2),
    sym(2,1), sym(2,-1), sym(-2,1), sym(-2,-1),
]
const SYMMETRIES3D = [
    sym(1,2,3), sym(1,2,-3), sym(1,-2,3), sym(1,-2,-3), sym(-1,2,3), sym(-1,2,-3), sym(-1,-2,3), sym(-1,-2,-3), 
    sym(1,3,2), sym(1,3,-2), sym(1,-3,2), sym(1,-3,-2), sym(-1,3,2), sym(-1,3,-2), sym(-1,-3,2), sym(-1,-3,-2), 
    sym(3,2,1), sym(3,2,-1), sym(3,-2,1), sym(3,-2,-1), sym(-3,2,1), sym(-3,2,-1), sym(-3,-2,1), sym(-3,-2,-1), 
    sym(2,1,3), sym(2,1,-3), sym(2,-1,3), sym(2,-1,-3), sym(-2,1,3), sym(-2,1,-3), sym(-2,-1,3), sym(-2,-1,-3), 
    sym(2,3,1), sym(2,3,-1), sym(2,-3,1), sym(2,-3,-1), sym(-2,3,1), sym(-2,3,-1), sym(-2,-3,1), sym(-2,-3,-1), 
    sym(3,1,2), sym(3,1,-2), sym(3,-1,2), sym(3,-1,-2), sym(-3,1,2), sym(-3,1,-2), sym(-3,-1,2), sym(-3,-1,-2), 
]

symmetries(::Val{1}) = SYMMETRIES1D
symmetries(::Val{2}) = SYMMETRIES2D
symmetries(::Val{3}) = SYMMETRIES3D

"""
    symmetries(dim::Integer)
    symmetries(dim::Val(::Integer))

Return an iterator over all box symmeties of a given dimension.
"""
function symmetries(n::Integer)
    symmetries(Val(Int(n)))
end

end

# TODO lazy iterator of all symmetries of given dimension
# TODO rand
# TODO composition + inversion of symmetries
# TODO isrotation for checking if orientation is preserved
# TODO aliases like rot90
