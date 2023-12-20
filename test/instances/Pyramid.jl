using POMDPs
using POMDPTools
using FiniteHorizonPOMDPs


#####################
# MDP and State types
#####################
struct PyramidState
    position::Int64
    epoch::Int64
end

# initial state constructor
PyramidState(position::Int64)::PyramidState = PyramidState(position, 0)

struct PyramidMDP <: MDP{PyramidState, Symbol} # Note that our MDP is parametarized by the state and the action
    _horizon::Int64
    actions::Vector{Symbol}
    action_cost::Float64
    actions_impact::Base.ImmutableDict{Symbol, Int64}
    reward_states::Vector{Vector{Int64}}
    reward::Float64
    discount_factor::Float64 # discount factor
    noise::Float64
end

function PyramidMDP(;_horizon=10, action_cost=1., reward_states=[], reward=-10., discount_factor=1., noise=.3)
    actions = [:l, :r]
    actions_impact = Base.ImmutableDict(:l => 0, :r => 1)
    return PyramidMDP(_horizon, actions, action_cost, actions_impact, reward_states, reward, discount_factor, noise)
end

FiniteHorizonPOMDPs.HorizonLength(::Type{<:PyramidMDP}) = FiniteHorizon()
FiniteHorizonPOMDPs.horizon(mdp::PyramidMDP) = mdp._horizon

###################################
# changed elements of POMDPs interface
###################################

# Creates (horizon(mdp) + 1) * mdp.no_states states to be evaluated and mdp.no_states sink states
function POMDPs.states(mdp::PyramidMDP)
    return [PyramidState(i, e) for e in 1:horizon(mdp) + 1 for i in 1:e]
end

POMDPs.stateindex(mdp::PyramidMDP, ss::PyramidState)::Int64 = sum(1:ss.epoch - 1) + ss.position
POMDPs.isterminal(mdp::PyramidMDP, ss::PyramidState) = FiniteHorizonPOMDPs.stage(mdp, ss) > horizon(mdp) || (ss.epoch, ss.position) in mdp.reward_states

# returns transition distributions - works only for 1D Gridworld with possible moves to left and to right
function POMDPs.transition(mdp::PyramidMDP, ss::PyramidState, a::Symbol)::SparseCat
    sp = (  PyramidState(ss.position + mdp.actions_impact[a], ss.epoch + 1),
            PyramidState(ss.position + mdp.actions_impact[a == :l ? :r : :l], ss.epoch + 1))
    prob = (1. - mdp.noise, mdp.noise)

    return SparseCat(sp, prob)
end


POMDPs.actions(mdp::PyramidMDP)::Vector{Symbol} = mdp.actions
POMDPs.actions(mdp::PyramidMDP, ss::PyramidState) = mdp.actions
POMDPs.actionindex(mdp::PyramidMDP, a::Symbol)::Int64 = findfirst(x->x==a, POMDPs.actions(mdp))

###############################
# FiniteHorizonPOMDPs interface
###############################
FiniteHorizonPOMDPs.stage(mdp::PyramidMDP, ss::PyramidState) = ss.epoch

function FiniteHorizonPOMDPs.stage_states(mdp::PyramidMDP, stage::Int)
    return (PyramidState(i, stage) for i in 1:stage)
end

FiniteHorizonPOMDPs.stage_stateindex(mdp::PyramidMDP, ss::PyramidState) = ss.position

###############################
# Forwarded parts of POMDPs interface
###############################
function isreward(mdp::PyramidMDP, ss::PyramidState)::Bool
    return (ss.epoch, ss.position) in mdp.reward_states
end

function POMDPs.reward(mdp::PyramidMDP, ss::PyramidState, a::Symbol, sp::PyramidState)::Float64
    isreward(mdp, sp) ? mdp.reward : mdp.action_cost
end

POMDPs.discount(mdp::PyramidMDP)::Number = mdp.discount_factor
