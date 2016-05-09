require_relative 'test_helper'
require_relative '../lib/neat/experiments/xor_experiment'

include Neat

population = Population.new(XorExperiment) do |p|
  #p.seed = 257753939644353454656484540607234813500
  p.specie_elitism = 0.1
  p.size = 100
  p.distance_threshold = 100.0
  p.dynamic_ratio = 0.15
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
