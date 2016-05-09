module Neat
  module BaseFunction
    #subclasses/submodules must implement 'calculate_normalized' to include

    attr_accessor :min, :max

    def initialize(min, max)
      @min, @max = min.to_f, max.to_f
    end

    def call(x)
      (max - min) * calculate_normalized(x) + min
    end
  end
end