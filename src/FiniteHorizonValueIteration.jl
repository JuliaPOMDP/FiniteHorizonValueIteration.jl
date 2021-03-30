module FiniteHorizonValueIteration

using POMDPs
using FiniteHorizonPOMDPs
import POMDPLinter: @POMDP_require, @req, @subreq
import ProgressMeter: @showprogress

export
    FiniteHorizonSolver,
    FiniteHorizonPolicy,
    solve,
    action

include("valueiteration.jl")
include("solver.jl")

end
