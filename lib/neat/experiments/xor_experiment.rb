module Neat
  class XorExperiment
    attr_accessor :population,
                  :function,
                  :trials

    def initialize(population = nil)
      @population = population

      yield self if block_given?

      @function ||= SigmoidFunction.new(5)
      @trials   ||= 10
    end

    def build
      @output_id ||= population.innovation.next_id
      Brain.new(2, rand, rand, rand, rand, rand).tap do |nn|
        nn.outputs << Neuron.new(@output_id, @function, 1).tap do |n|
          n.synapses.concat(2.times.map { |i| Synapse.new(i, rand(-1.0..1.0), rand) })
        end
      end
    end

    def call(nn)
      nn.clean
      nn.fitness = 4.times.map do |i|
        inputs = [i % 2, (i % 4)/2]
        @trials.times { nn.(inputs) }
        output = nn.output[0]
        inputs[0] == inputs[1] ? 1.0 - output : output
      end.reduce(&:+) / 4.0
    end

    private
    def rand(max = nil)
      population.rand(max)
    end
  end
end