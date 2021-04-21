# FiniteHorizonValueIteration
[![Build Status](https://travis-ci.org/Omastto1/FiniteHorizonValueIteration.jl.svg?branch=master)](https://travis-ci.org/JuliaPOMDP/FIB.jl)
[![Coverage Status](https://coveralls.io/repos/github/Omastto1/FiniteHorizonValueIteration.jl/badge.svg?branch=master)](https://coveralls.io/github/Omastto1/FiniteHorizonValueIteration.jl?branch=master)

The package contains a finite horizon MDP solver for discrete problems. This algorithm is a modified version of infinite horizon value iteration.

## Installation

You must have [POMDPs.jl](https://github.com/JuliaPOMDP/POMDPs.jl) installed. To install `FiniteHorizonValueIteration`, run the following command:

```julia
using POMDPs
using Pkg
POMDPs.add_registry() # TODO: Is this still needed?
Pkg.add("FiniteHorizonValueIteration")
```

## Usage

```
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
