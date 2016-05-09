module Neat
  class Gene
    attr_reader :source, :destination, :weight, :enable_chance

    def initialize(source, destination, weight, enable_chance)
      @source, @destination, @weight, @enable_chance = source.to_i, destination.to_i, weight, enable_chance
    end

    def <=>(other)
      cmp = @source <=> other.source
      return cmp if cmp != 0
      cmp = @destination <=> other.destination
      return cmp if cmp != 0
      weight <=> other.weight
    end
  end
end