using Test
using BoxSymmetries
using BoxSymmetries: BoxSymmetry
@testset "1d" begin
    @inferred sym(1)([1,2,3])
    @test sym(-1)([1,2,3]) == [3,2,1]
    @test sym( 1)([1,2,3]) == [1,2,3]
end

@testset "2d" begin
    m = [1 2 3;
         4 5 6
    ]
    @test sym( 1, 2)(m) == [1 2 3; 4 5 6]
    @test sym( 1,-2)(m) == [3 2 1; 6 5 4]
    @test sym(-1, 2)(m) == [4 5 6; 1 2 3]
    @test sym(-1,-2)(m) == [6 5 4; 3 2 1]
    
    @test sym( 2, 1)(m) == [1 4; 2 5; 3 6]
    @test sym( 2,-1)(m) == [4 1; 5 2; 6 3]
    @test sym(-2, 1)(m) == [3 6; 2 5; 1 4]
    @test sym(-2,-1)(m) == [6 3; 5 2; 4 1]
end

@testset "sugar" begin
    @test_throws ArgumentError sym(2,)
    @test_throws ArgumentError sym(0,)
    @test_throws ArgumentError sym(-1,1)
end

@testset "symmetries" begin
    symmetries = BoxSymmetries.symmetries
    @test allunique(symmetries(1))
    @test length(symmetries(1)) == 2
    @test rand(symmetries(1)) isa BoxSymmetry{1}

    @test allunique(symmetries(2))
    @test length(symmetries(2)) == 8
    @test rand(symmetries(2)) isa BoxSymmetry{2}

    @test allunique(symmetries(3))
    @test length(symmetries(3)) == 48
    @test rand(symmetries(3)) isa BoxSymmetry{3}
end

@testset "show it like you build it" begin
    for dim in 1:3
        for g in BoxSymmetries.symmetries(dim)
            s = sprint(show, g)
            g2 = eval(Meta.parse(s))
            @test g === g2
        end
    end
end
