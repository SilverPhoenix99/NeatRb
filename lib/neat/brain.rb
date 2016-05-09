module Neat
  class Brain
    attr_reader :num_inputs, :hidden, :outputs
    attr_accessor :fitness, :add_neuron, :add_synapse, :change_weight, :replace_weight, :perturb_weight

    def initialize(num_inputs, add_neuron, add_synapse, change_weight, replace_weight, perturb_weight)
      @num_inputs, @add_neuron, @add_synapse, @change_weight, @replace_weight, @perturb_weight =
          num_inputs, add_neuron, add_synapse, change_weight, replace_weight, perturb_weight
      @fitness, @hidden, @outputs = 0.0, [], []
    end

    def amend_synapses
      neurons = self.neurons
      ngroup = neurons.group_by { |n| n.id }.tap { |h| h.each { |k, v| h[k] = v[0] } }
      neurons.each { |n| n.synapses.select { |s| s.source.is_a?(Neuron) }.each { |s| s.source = ngroup[s.source.id] } }
    end

    def call(inputs)
      raise ArgumentError, "wrong number of inputs (#{inputs.count} for #{@num_inputs})" unless inputs.count == @num_inputs
      neurons.each { |n| n.(inputs) }
      neurons.each(&:update)
      nil
    end

    def clean
      neurons.each(&:clean)
    end

    def count
      @hidden.count + @outputs.count
    end

    def dup(dup_neurons = true)
      self.class.new(@num_inputs, @add_neuron, @add_synapse, @change_weight, @replace_weight, @perturb_weight).tap do |nn|
        if dup_neurons
          nn.instance_variable_set(:@hidden, @hidden.map(&:dup))
          nn.instance_variable_set(:@outputs, @outputs.map(&:dup))
          nn.amend_synapses
        end
      end
    end

    def genome
      neurons.flat_map { |n| n.synapses.map { |s| Gene.new(s.source, n, s.weight, s.enable_chance) } }
    end

    def neurons
      @hidden + @outputs
    end

    def output
      @outputs.map(&:output)
    end
  end
end