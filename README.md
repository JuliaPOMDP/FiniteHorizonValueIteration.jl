# FiniteHorizonValueIteration

[![CI](https://github.com/JuliaPOMDP/FiniteHorizonValueIteration.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaPOMDP/FiniteHorizonValueIteration.jl/actions/workflows/CI.yml)
[![codecov.io](http://codecov.io/github/JuliaPOMDP/FiniteHorizonValueIteration.jl/coverage.svg?branch=master)](http://codecov.io/github/JuliaPOMDP/FiniteHorizonValueIteration.jl?branch=master)

The package contains a finite horizon MDP solver for discrete problems. This algorithm is a modified version of infinite horizon value iteration.

## Installation

To install `FiniteHorizonValueIteration`, run the following command:

```julia
using Pkg
Pkg.add("FiniteHorizonValueIteration")
```

## Usage

```julia
using POMDPs
using FiniteHorizonValueIteration

mdp = MyMDP() # initialize MDP

# initialize the solver
solver = FiniteHorizonSolver(verbose=false)

# run the solver
policy = solve(solver, mdp)
```

# Output and validation
The policy is stored to `FiniteHorizonPolicy`. 
Example problems are defined in `test/instances/...`, examples are used in corresponding test files. Results are validated against the value iteration executed on all epochs simultaneously.
