# Finite Horizon algorithm evaluating problem with use of other POMDP algorithms
# User has to define (PO)MDP instance with use of POMDPs interface methods isterminal, reward, actions, states, stateindex, actions, actionindex, discount, transition

# For example see problems defined in POMDPModels package or FiniteHorizonPOMDP/test/instances/1DFiniteHorizonGridWorld.jl
#
# Currently supporting: ValueIterationSolver
#
# Possible future improvements: Change arrays from row oriented to column oriented
#                               Create fixhorizon(m::Union{MDP,POMDP}, T::Int) utility


# Policy struct created according to one used in DiscreteValueIteration

#TODO: Dosctring
struct FiniteHorizonSolver <: Solver
    verbose::Bool
end

function FiniteHorizonSolver(;verbose::Bool=false)
    return FiniteHorizonSolver(verbose)
end

#TODO: Dosctring
mutable struct FiniteHorizonValuePolicy{Q<:Array, U<:Array, P<:Array, A<:Array, M<:MDP} <: Policy
    qmat::Q
    util::U
    policy::P
    action_map::A
    include_Q::Bool
    m::M
end

# Policy constructor
function FiniteHorizonValuePolicy(m::MDP)
    no_stages = horizon(m)
    no_actions = length(actions(m))

    qmat =  Array{Matrix{Float64}}(undef, no_stages)
    util =  Array{Vector{Float64}}(undef, no_stages)
    policy = Array{Vector{Int64}}(undef, no_stages)
    return FiniteHorizonValuePolicy(qmat, util, policy, ordered_actions(m), true, m)
end

function value(policy::FiniteHorizonValuePolicy, s::S) where S
    stg = stage(policy.m, s)
    stg == horizon(policy.m) + 1 && return 0.
    sidx = stage_stateindex(policy.m, s)
    return policy.util[stg][sidx]
end

function action(policy::FiniteHorizonValuePolicy, s::S) where S
    stg = stage(policy.m, s)
    stg == horizon(policy.m) + 1 && return policy.action_map[1]
    sidx = stage_stateindex(policy.m, s)
    aidx = policy.policy[stg][sidx]
    return policy.action_map[aidx]
end

@POMDP_require solve(solver::FiniteHorizonSolver, mdp::MDP) begin
    M = typeof(mdp)
    S = statetype(M)
    A = actiontype(M)
    @req discount(::M)
    @subreq ordered_states(mdp)
    @subreq ordered_actions(mdp)
    @req isterminal(::M, ::S)
    @req transition(::M,::S,::A)
    @req reward(::M,::S,::A,::S)
    @req stateindex(::M,::S)
    @req actionindex(::M, ::A)
    @req actions(::M, ::S)
    as = actions(mdp)
    ss = states(mdp)
    @req length(::typeof(ss))
    @req length(::typeof(as))
    a = first(as)
    s = first(ss)
    dist = transition(mdp, s, a)
    D = typeof(dist)
    @req support(::D)
    @req pdf(::D,::S)

    @req stage(::M, ::S)
    E = typeof(stage(mdp, s))
    # @req HorizonLength(::M)
    @req stage_states(::M, ::Int64)
    @req stage_stateindex(::M, ::S)
    @req horizon(::M)
end

"""
    addstagerecord(fhpolicy::FiniteHorizonValuePolicy, qmat, util, policy, stage)

Store record for given stage results to `FiniteHorizonPolicy` and return updated version.
"""
function addstagerecord(fhpolicy::FiniteHorizonValuePolicy, qmat, util, policy, stage, solver::FiniteHorizonSolver)
    fhpolicy.qmat[stage] = qmat
    fhpolicy.util[stage] = util
    fhpolicy.policy[stage] = policy
    return fhpolicy
end

# MDP given horizon 5 assumes that agent can move 5 times
function solve(solver::FiniteHorizonSolver, m::MDP)
    if typeof(HorizonLength(m)) == InfiniteHorizon
        throw(ArgumentError("Argument m should be valid Finite Horizon MDP with methods from FiniteHorizonPOMDPs.jl interface implemented. If you are completely sure that you implemented all of them, you should also check if you have defined HorizonLength(::Type{<:MyFHMDP})"))
    end

    fhpolicy = FiniteHorizonValuePolicy(m)
    util = zeros(length(stage_states(m, horizon(m) + 1)))

    @showprogress dt=1 desc="Computing..." for stage=horizon(m):-1:1
        if solver.verbose
            println("Stage: $stage")
        end

        stage_q, util, pol = valueiterationsolver(m, stage, util)

        fhpolicy = addstagerecord(fhpolicy, stage_q, util, pol, stage, solver)

        if solver.verbose
            println("POLICY\n")
            println("QMAT")
            println(fhpolicy.qmat[stage])
            println("util")
            println(fhpolicy.util[stage])
            println("policy")
            println(fhpolicy.policy[stage])
            println("\n\n\n")
        end
    end

    return fhpolicy
end
