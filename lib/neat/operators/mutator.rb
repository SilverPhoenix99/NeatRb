module Neat
  module MutatorModule
    #add_neuron

    def mutate
    end

    alias_method :call, :mutate

    private

    def add_neuron

    end

    def mutator
      @mutator ||= self.class.ancestors.find { |m| m.is_a?(Mutator) }
    end
  end

  class Mutator < Module
    attr_accessor :population,
                  :max_neurons,
                  :add_neuron,
                  :add_synapse,
                  :recursive_synapse,
                  :change_bias

    attr_reader :weight_range

    def initialize(population = nil)
      @population = population

      yield self if block_given?

      @max_neurons       ||= 0
      @recursive_synapse ||= false
      @change_bias       ||= true
      @weight_range      ||= -1.0..1.0
    end

    def included(c)
      c.include MutatorModule
      c.define_method('mutator', me_proc)
    end

    def me_proc
      m = self
      ->() { m }
    end
  end



  class OldMutator
    attr_accessor :population,
                  :max_neurons,
                  :recursive_synapse,
                  :change_bias

    attr_reader :weight_range

    def initialize(population = nil)
      @population = population

      yield self if block_given?

      @max_neurons       ||= 0
      @recursive_synapse ||= false
      @change_bias       ||= true
      @weight_range      ||= -1.0..1.0
    end

    def mutate(nn)
      change_weights nn
      add_neuron nn
      add_synapse nn
      nn
    end

    def weight_range=(v)
      @weight_range = v.is_a?(Range) ? v : -v..v
    end

    alias_method :call, :mutate

    private

    def add_neuron(nn)
      return unless nn.add_neuron > 0 && nn.hidden.count < @max_neurons && rand < nn.add_neuron
      destination = nn.neurons[rand(nn.count)]           #dest = neuron
      synapses = destination.synapses.select(&:enabled?) #srcs = synapses
      return if synapses.empty?
      synapse = synapses[rand(synapses.count)]
      source = synapse.source
      new_id = @population.innovation[source, destination]
      return if nn.neurons.find { |n| n.id == new_id }
      synapse.disable!
      function = (source.is_a?(Neuron) ? source : destination).function
      n = Neuron.new(new_id, function)
      destination.synapses << Synapse.new(n, rand(@weight_range), rand)
      n.synapses << Synapse.new(source, rand(@weight_range), rand)
      nn.hidden << n
    end

    def add_synapse(nn)
      return unless nn.add_synapse > 0 && rand < nn.add_synapse
      neurons = nn.neurons
      dst = neurons[rand(neurons.count)]

      neurons.delete(dst) unless @recursive_synapse
      neurons = nn.num_inputs.times.to_a.concat(neurons)
      src = neurons[rand(neurons.count)]

      return if dst.synapses.any? { |s| s.source == src }
      dst.synapses << Synapse.new(src, rand(@weight_range), rand)
    end

    def change_weights(nn)
      return unless nn.change_weight > 0.0 && rand < nn.change_weight

      if nn.replace_weight > 0.0 && rand < nn.replace_weight
        nn.neurons.each do |n|
          n.bias = rand(@weight_range) if change_bias
          n.synapses.each { |s| s.weight = rand(weight_range) }
        end
        return
      end

      return unless nn.perturb_weight > 0.0

      p = nn.perturb_weight
      p = -p..p
      nn.neurons.each do |n|
        perturb_weight(n, p, :bias)
        n.synapses.each { |s| perturb_weight(s, p, :weight) }
      end
    end

    def perturb_weight(v, perturb_weight, attr)
      weight = v.send(attr) * (1.0 + rand(perturb_weight))
      v.send "#{attr}=", [[weight_range.max, weight].min, weight_range.min].max
    end

    def rand(max = nil)
      @population.rand(max)
    end
  end
end