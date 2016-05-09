%w'
  set
'.each { |f| require f }

%w'
  base
  atan
  inverse_abs
  linear
  sigmoid
  step
'.each { |f| require "neat/functions/#{f}_function" }

%w'
  gene
  synapse
  neuron
  operators/crossover
  operators/mutator
  innovation
  specie
  brain
  population
'.each { |f| require "neat/#{f}" }