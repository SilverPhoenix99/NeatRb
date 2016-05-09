module Neat
  class Synapse

    attr_accessor :source, :weight, :enable_chance

    def initialize(source, weight, enable_chance)
      @source, @weight, @enable_chance, @enabled = source, weight, enable_chance, true
    end

    def calculate(inputs)
      @weight * (@source.is_a?(Neuron) ? @source.output : inputs[@source])
    end

    def dup
      self.class.new(@source, @weight, @enable_chance).tap do |s|
        s.enabled = enabled?
      end
    end

    def disable!
      @enabled = false
    end

    def disabled?
      !@enabled
    end

    def enable!
      @enabled = true
    end

    def enabled?
      @enabled
    end

    def enabled=(v)
      @enabled = !!v
    end

    def toogle!
      @enabled = !@enabled
    end
  end
end