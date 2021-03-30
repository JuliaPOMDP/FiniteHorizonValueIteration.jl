
# MDP parameters, ValueIteration minimizes the cost => cost is positive, reward is negative
no_states = 10
_horizon = 5
actions = [:l, :r]
actionCost = 1.
actionsImpact = Base.ImmutableDict(:l => -1, :r => 1)
reward_states = [1, no_states]
reward = -10.
discount_factor = 1.
noise = .6

fhsolver = FiniteHorizonSolver()

# MDPs initialization
mdp = FHExample(no_states, actions, actionCost, actionsImpact, reward_states, reward, discount_factor, noise)

# Wrap mdp into finite horizon wrapper
fhex = fixhorizon(mdp, _horizon)

# check implementation of required methods
# @POMDPLinter.show_requirements FiniteHorizonPOMDPs.solve(fhsolver, fhex)

# initialize the solver
# max_iterations: maximum number of iterations value iteration runs for (default is 100)
# belres: the value of Bellman residual used in the solver
solver = ValueIterationSolver(max_iterations=10, belres=1e-3, include_Q=true);

# Solve Value Iteration
VIPolicy = DiscreteValueIteration.solve(solver, fhex);

# Solve Finite Horizon by Value Iteration
FHPolicy = FiniteHorizonPOMDPs.solve(fhsolver, fhex);

@test typeof(HorizonLength(fhex)) != InfiniteHorizon
@test_throws ArgumentError FiniteHorizonPOMDPs.solve(fhsolver, mdp)

# Compare resulting policies
@test all((FiniteHorizonPOMDPs.action(FHPolicy, s) == action(VIPolicy, s) for s in states(fhex)))

# Compare FHMDP and IHMDP states
fh_states = Iterators.flatten([FiniteHorizonPOMDPs.stage_states(fhex, i) for i=1:fhex.horizon + 1])
ih_states = states(fhex)

z = zip(fh_states, ih_states)

@test all((fh == ih for (fh, ih) in z))


using FiniteHorizonPOMDPs
using Test
using POMDPLinter
using POMDPModelTools
using DiscreteValueIteration
using POMDPs
using POMDPModels
using POMDPTesting
using POMDPPolicies
using POMDPSimulators

using FiVI

include("instances/1DInfiniteHorizonGridWorld.jl")

no_states = 10
_horizon = 5
_actions = [:l, :r]
actionCost = 1.
actionsImpact = Base.ImmutableDict(:l => -1, :r => 1)
reward_states = [1, no_states]
reward = -10.
discount_factor = 1.
noise = .6

fhsolver = FiniteHorizonSolver()

# MDPs initialization
mdp = FHExample(no_states, _actions, actionCost, actionsImpact, reward_states, reward, discount_factor, noise)

solver = ValueIterationSolver(max_iterations=10, belres=1e-3, include_Q=true);
VIPolicy = DiscreteValueIteration.solve(solver, mdp);


using Random
rnd = solve(RandomSolver(MersenneTwister(7)), pomdp)

solver = FiVISolver(3., 100.)

simulate()


q = [] # vector of the simulations to be run
q = [Sim(pomdp, rnd, max_steps=_horizon, rng=MersenneTwister(4), metadata=Dict(:policy=>"random_$(i)")) for i in 1:100]

q

data = run_parallel(q)

max(data.reward...)

q2 = [] # vector of the simulations to be run
q2 = [RolloutSimulator(max_steps=_horizon) for i in 1:100]

data2 = run_parallel(q2)


# using FiniteHorizonPOMDPs
# using Test
# using POMDPLinter
using Distributed
addprocs(4)
@everywhere using Pkg
@everywhere Pkg.activate("@v1.5")
using POMDPModelTools
# using DiscreteValueIteration
using POMDPs
@everywhere using POMDPModels
# using POMDPTesting
using POMDPPolicies
@everywhere using POMDPSimulators
@everywhere using ProgressMeter
using Random
import POMDPs.updater

using POMDPs
using MCTS
using BeliefUpdaters
using PointBasedValueIteration
using DataFrames

# using FiVI

#test simulaci
for _ in 1:10
    simulation = RolloutSimulator(max_steps = 10)
    mdp = TigerPOMDP()
    rnd = solve(RandomSolver(MersenneTwister(4)), mdp)
    @show simulate(simulation, mdp, rnd)
end


# vizualizace stromu
# This defines how nodes in the tree view are labeled.
function MCTS.node_tag(s::GridWorldState)
    if s.done
        return "done"
    else
        return "[$(s.x),$(s.y)]"
    end
end

MCTS.node_tag(a::GridWorldAction) = "[$a]"

 # click on the node to expand it


# snaha o pomdp simulace
for _ in 1:10
    n_iter = 50000
    depth = 10
    ec = 10.0
    solver = BeliefMCTSSolver(MCTSSolver(n_iterations=n_iter,
        depth=depth,
        exploration_constant=ec,
        enable_tree_vis=true
    ), DiscreteUpdater(pomdp))
    pomdp = MiniHallway()
    pol = solve(solver, pomdp)
    simulation = RolloutSimulator(max_steps = depth)

    initialstate(pomdp)

    @show simulate(simulation, pomdp, planner)
end

POMDPs.updater(p::MCTSPlanner) = p.mdp.updater

n_iter = 10000
depth = 10
ec = 0.5
pomdp = MiniHallway()
solver = BeliefMCTSSolver(MCTSSolver(n_iterations=n_iter,
    depth=depth,
    exploration_constant=ec,
    enable_tree_vis=true
), DiscreteUpdater(pomdp))
planner = solve(solver, pomdp)

# ne OK POMDP -> MDP simulace
simulate(RolloutSimulator(max_steps = depth), pomdp, planner)

q = [Sim(pomdp, planner, max_steps=depth, rng=MersenneTwister(4), metadata=Dict(:policy=>"MCTS_$(i)")) for i in 1:100]

data = run_parallel(q)
data

solver2 = PBVI()
pomdp = MiniHallway()
PBVIplanner = solve(solver2, pomdp)
simulate(RolloutSimulator(max_steps = depth), pomdp, PBVIplanner)

q2 = [Sim(pomdp, PBVIplanner, max_steps=depth, rng=MersenneTwister(4), metadata=Dict(:policy=>"PBVI_$(i)")) for i in 1:100]

data2 = run_parallel(q2)

using StatsPlots
@df data histogram(:reward)

describe(data.reward)

@df data2 histogram(:reward)

describe(data2.reward)




state = initialstate(pomdp, Random.MersenneTwister(4))
state = rand(Random.MersenneTwister(4), initialstate(pomdp))

a = action(planner, initialstate(pomdp))

a, info = action_info(planner, state)
inchrome(D3Tree(info[:tree], init_expand=5))
