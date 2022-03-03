using Test
using BoxSymmetries
@testset "1d" begin
    @inferred BoxSym(1)([1,2,3])
    @test BoxSym(-1)([1,2,3]) == [3,2,1]
    @test BoxSym( 1)([1,2,3]) == [1,2,3]
end

@testset "2d" begin
    m = [1 2 3;
         4 5 6
    ]
    @test BoxSym( 1, 2)(m) == [1 2 3; 4 5 6]
    @test BoxSym( 1,-2)(m) == [3 2 1; 6 5 4]
    @test BoxSym(-1, 2)(m) == [4 5 6; 1 2 3]
    @test BoxSym(-1,-2)(m) == [6 5 4; 3 2 1]
    
    @test BoxSym( 2, 1)(m) == [1 4; 2 5; 3 6]
    @test BoxSym( 2,-1)(m) == [4 1; 5 2; 6 3]
    @test BoxSym(-2, 1)(m) == [3 6; 2 5; 1 4]
    @test BoxSym(-2,-1)(m) == [6 3; 5 2; 4 1]
end

@testset "sugar" begin
    @test_throws ArgumentError BoxSym(2,)
    @test_throws ArgumentError BoxSym(0,)
    @test_throws ArgumentError BoxSym(-1,1)
end

@testset "instances" begin
    G = instances(BoxSym{1})
    @test allunique(G)
    @test length(G) == 2
    @test rand(G) isa BoxSym{1}
    @test rand(BoxSym{1}) isa BoxSym{1}

    G = instances(BoxSym{2})
    @test allunique(G)
    @test length(G) == 8
    @test rand(G) isa BoxSym{2}
    @test rand(BoxSym{2}) isa BoxSym{2}

    G = instances(BoxSym{3})
    @test allunique(G)
    @test length(G) == 48
    @test rand(G) isa BoxSym{3}
    @test rand(BoxSym{3}) isa BoxSym{3}
end

@testset "show it like you build it" begin
    for dim in 1:3
        for g in instances(BoxSym{dim})
            s = sprint(show, g)
            g2 = eval(Meta.parse(s))
            @test g === g2
        end
    end
end


