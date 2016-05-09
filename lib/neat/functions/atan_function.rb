module Neat
  class AtanFunction
    include BaseFunction

    attr_accessor :slope

    def initialize(slope, min = 0.0, max = 1.0)
      @slope = slope.to_f
      super(min, max)
    end

    def calculate_normalized(signal)
      0.5 + Math.atan(@slope * signal) / Math.PI
    end
  end
end