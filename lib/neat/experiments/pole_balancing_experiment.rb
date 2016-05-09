module Neat
  class PoleBalancingExperiment
    attr_accessor :population

    def initialize(population = nil)
      @population = population

      yield self if block_given?
    end

    def build

    end

    def call(nn)

    end

    private
    def rand(max = nil)
      population.rand(max)
    end
  end
end