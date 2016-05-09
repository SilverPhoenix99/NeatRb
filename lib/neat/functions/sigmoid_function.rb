module Neat
  class SigmoidFunction
    include BaseFunction

    attr_accessor :slope

    def initialize(slope, min = 0.0, max = 1.0)
      @slope = slope.to_f
      super(min, max)
    end

    def calculate_normalized(signal)
      1.0 / (1.0 + Math.exp(-@slope*signal))
    end
  end
end