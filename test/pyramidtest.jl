reward_states = [[4, 1], [5, 5], [7, 6]]

# MDPs initialization
mdp = PyramidMDP(reward_states=reward_states)

# check implementation of required methods
# @POMDPLinter.show_requirements FiniteHorizonPOMDPs.solve(fhsolver, mdp)

# initialize the solver
# max_iterations: maximum number of iterations value iteration runs for (default is 100)
# belres: the value of Bellman residual used in the solver
solver = ValueIterationSolver(max_iterations=10, belres=1e-3, include_Q=true);
fhsolver = FiniteHorizonSolver()

# Solve Value Iteration
VIPolicy = DiscreteValueIteration.solve(solver, mdp);

# Solve Finite Horizon by Value Iteration
FHPolicy = FiniteHorizonPOMDPs.solve(fhsolver, mdp);

@test typeof(HorizonLength(mdp)) != InfiniteHorizon

# Compare resulting policies
@test all(FiniteHorizonValueIteration.action(FHPolicy, s) == DiscreteValueIteration.action(VIPolicy, s) for s in states(mdp))

# Compare FHMDP and IHMDP states
fh_states = Iterators.flatten([FiniteHorizonPOMDPs.stage_states(mdp, i) for i=1:FiniteHorizonPOMDPs.horizon(mdp) + 1])
ih_states = states(mdp)

z = zip(fh_states, ih_states)

@test all((fh == ih for (fh, ih) in z))
