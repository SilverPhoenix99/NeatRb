require_relative 'test_helper'
require_relative '../lib/neat/experiments/pole_balancing_experiment'

include Neat

population = Population.new(PoleBalancingExperiment) do |p|
  p.specie_elitism = 0.1
  p.mutator = Mutator.new do |m|
    m.max_neurons = 1
    m.recursive_synapse = false
    m.weight_range = 100.0
  end
end

200.times do |i|
  population.epoch
  champion = population.champion
  puts "#{i}\t#{champion.fitness}\t#{champion.hidden.count}"
  break if champion.fitness == 1.0
end

puts "seed = #{population.random.seed}"
puts 'Champion:'
print_brain population.champion