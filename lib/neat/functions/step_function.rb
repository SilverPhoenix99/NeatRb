module Neat
  class StepFunction
    include BaseFunction

    def initialize(min = 0.0, max = 1.0)
      super(min, max)
    end

    def calculate_normalized(signal)
      signal < 0.0 ? @min : @max
    end
  end
end