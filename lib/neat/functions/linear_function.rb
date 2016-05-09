module Neat
  class LinearFunction
    include BaseFunction

    attr_accessor :left, :right

    def initialize(left, right, min = 0.0, max = 1.0)
      @left, @right = left.to_f, right.to_f
      super(min, max)
    end

    def calculate_normalized(signal)
      return 0.0 if signal < @left
      return 1.0 if signal > @right
      (signal - @left) / (@right - @left)
    end
  end
end