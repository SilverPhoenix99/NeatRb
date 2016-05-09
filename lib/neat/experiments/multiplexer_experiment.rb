module Neat
  class MultiplexerExperiment
    attr_accessor :population,
                  :entries,
                  :function,
                  :trials

    def initialize(population = nil)
      @population = population

      yield self if block_given?

      @entries  ||= 1
      @function ||= SigmoidFunction.new(5)
      @trials   ||= 10
    end

    def build
      @output_id ||= population.innovation.next_id
      Brain.new(@entries + num_inputs, rand, rand, rand, rand, rand).tap do |nn|
        n = Neuron.new(@output_id, )
      end
    end

    def call(nn)

    end

    def num_inputs
      1 << @entries
    end

    private
    def rand(max = nil)
      population.rand(max)
    end
  end
end