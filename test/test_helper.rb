lib = File.expand_path('../../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
require lib.match(/([^\/]+)\/lib$/)[1]

def print_synapse(s)
  puts "  Synapse (#{s.enabled? ? 'enabled' : 'disabled'})"
  puts "    source = #{s.source.is_a?(Neuron) ? "Neuron[#{s.source.id}]" : "Input[#{s.source}]"}"
  puts "    weight = #{s.weight}"
  puts "    enable_chance = #{s.enable_chance}"
end

def print_neuron(type, n)
  puts " #{type} neuron #{n.id}"
  puts "  bias = #{n.bias}"
  n.synapses.each { |s| print_synapse s }
end

def print_brain(nn)
  puts "Outputs = #{nn.outputs.count} Hidden = #{nn.hidden.count}"
  %w'add_neuron add_synapse change_weight replace_weight perturb_weight'.each do |n|
    puts " #{n.gsub('_', ' ')} = #{nn.public_send(n)}"
  end

  nn.hidden.each { |n|  print_neuron 'Hidden', n }
  nn.outputs.each { |n| print_neuron 'Output', n }
end