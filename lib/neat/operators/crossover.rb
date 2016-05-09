module Neat
  class Crossover
    attr_accessor :population,
                  :mean_fitness

    def initialize(population = nil)
      @population = population

      yield self if block_given?

      @mean_fitness ||= false
    end

    def cross(mom, dad)
      mom, dad = sort_best(mom, dad)
      child = mom.dup(false)
      prob = mom.fitness / (mom.fitness + dad.fitness)
      add_neurons :outputs, mom, dad, child, prob
      add_neurons :hidden, mom, dad, child, prob
      child.amend_synapses
      child
    end

    alias_method :call, :cross

    private

    def add_neurons(type, mom, dad, child, prob)
      mom = mom.send(type)
      dad = dad.send(type).group_by { |n| n.id }.tap { |h| h.each { |k, v| h[k] = v[0] } }
      child = child.send(type)

      mom.each do |nm|
        if (nd = dad[nm.id])
          select_synapses nm, nd, child, prob
        else
          child << nm.dup
        end
      end
    end

    def select_synapses(mom, dad, child, prob)
      n = rand_bool ? mom : dad
      child << n = Neuron.new(n.id, n.function, n.bias)
      dad = dad.synapses
              .group_by { |ds| ds.source.is_a?(Neuron) ? ds.source.id : -ds.source }
              .tap { |h| h.each { |k, v| h[k] = v[0] } }
      mom.synapses.each do |ms|
        source = ms.source.is_a?(Neuron) ? ms.source.id : -ms.source
        n.synapses << if (ds = dad[source])
          if @mean_fitness
            ms.dup.tap { |s| s.weight = prob * ms.weight + (1.0 - prob) * ds.weight }
          else
            (rand_bool ? ms : ds).dup
          end.tap { |s| s.enabled = rand < s.enable_chance if ms.disabled? && ds.disabled? }
        else
          ms.dup
        end
      end
    end

    def sort_best(mom, dad)
      raise ArgumentError, 'mom and dad have different number of outputs' if mom.outputs.count != dad.outputs.count
      mf, mc, df, dc = mom.fitness, mom.count, dad.fitness, dad.count
      mom, dad = dad, mom if df > mf || (df == mf && (dc < mc || (dc == mc && rand_bool)))
      [mom, dad]
    end

    def rand(max = nil)
      @population.rand(max)
    end

    def rand_bool
      rand(2) == 0
    end
  end
end