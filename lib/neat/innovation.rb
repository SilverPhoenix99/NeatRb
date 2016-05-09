module Neat
  class Innovation
    attr_reader :current_id

    def initialize
      @current_id, @neurons = 0, {}
    end

    def has?(source, destination)
      !!@neurons[[parse_source(source), destination.to_i]]
    end

    def get(source, destination)
      @neurons[[parse_source(source), destination.to_i]] ||= next_id
    end

    def next_id
      @current_id += 1
    end

    alias_method :[], :get

    private

    def parse_source(source)
      source.is_a?(Neuron) ? source.to_i : -source
    end
  end
end