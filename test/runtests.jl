using FiniteHorizonValueIteration
using Test
using POMDPs
using POMDPTools
using DiscreteValueIteration
using FiniteHorizonPOMDPs

include("instances/1DCustomFHGW.jl")

@testset "verbose check" begin
    include("verbosecheck.jl")
end

include("instances/1DInfiniteHorizonGridWorld.jl")

@testset "1DFixHorizonGridWorld" begin
    include("fixhorizon1dtest.jl")
end

@testset "Custom Finite Horizon MDP" begin
    include("custom1dtest.jl")
end

include("instances/Pyramid.jl")

@testset "Pyramid MDP" begin
    include("pyramidtest.jl")
end
