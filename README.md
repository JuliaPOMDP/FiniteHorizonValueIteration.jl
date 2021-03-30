# FiniteHorizonValueIteration

The package contains a `solve(solver::FiniteHorizonSolver, m::MDP)` finite horizon MDP solver for discrete problems. Its results are stored to `FiniteHorizonPolicy` struct. Example problems are defined in `test/instances/...` and use example in specific test files. Results were benchmarked against the value iteration executed on all epochs simultaneously.
