module Neat
  class Neuron
    include Comparable

    attr_reader :id, :output, :synapses
    attr_accessor :function, :bias

    def initialize(id, function, bias = 0.0)
      @id, @function, @bias = id, function, bias
      @synapses = []
      clean
    end

    def <=>(other)
      to_i <=> other.to_i
    end

    def call(inputs)
      signal = @synapses.select(&:enabled?).map { |s| s.calculate(inputs) }.reduce(0.0, &:+)
      @next_output = @function.(signal + @bias)
    end

    def clean
      @output = @next_output = 0.0
    end

    def dup
      self.class.new(@id, @function, @bias).tap do |neuron|
        neuron.instance_variable_set(:@output, @output)
        neuron.instance_variable_set(:@next_output, @next_output)
        neuron.instance_variable_set(:@synapses, @synapses.map(&:dup))
      end
    end

    def to_i
      @id
    end

    def update
      @output = @next_output
    end
  end
end