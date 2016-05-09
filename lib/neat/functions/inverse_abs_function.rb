module Neat
  class InverseAbsFunction
    include BaseFunction

    attr_accessor :slope

    def initialize(slope, min = 0.0, max = 1.0)
      @slope = slope.to_f
      super(min, max)
    end

    def calculate_normalized(signal)
      0.5 * (1.0 + signal / (@slope + signal.abs))
    end
  end
end