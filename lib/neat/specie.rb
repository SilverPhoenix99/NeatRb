module Neat
  class Specie
    attr_reader :population, :networks, :age

    %w'distribution elitism sort_desc'.each { |n| define_method(n, ->() { @population.send("specie_#{n}") }) }

    %w'crossover mutator'.each { |n| define_method(n, ->() { @population.send(n) }) }

    def initialize(population, age = 0)
      @population, @age, @networks, @sorted = population, age, [], false
    end

    def add(nn)
      @networks << nn
    end

    def avg_fitness
      @networks.map(&:fitness).reduce(&:+) / @networks.count.to_f
    end

    def champion
      raise 'must sort' unless @sorted
      @networks.first
    end

    def dup
      self.class.new(@population, @age).tap do |s|
        s.instance_variable_set(:@networks, @networks.map(&:dup))
      end
    end

    def evolve(num_offspring)
      raise 'must sort' unless @sorted

      children = []
      if elitism > 0
        elite = [1, (elitism * num_offspring).to_i].max
        num_offspring -= elite
        children = @networks[0, elite].map(&:dup)
      end

      length = [num_offspring, @networks.count].min

      children.concat(
          if length == 0
            num_offspring.times.map { crossover.(@networks.first, @networks.first) }
          else
            send("#{distribution}_distribution", num_offspring, length)
          end
      )
    end

    def sort!
      return self if @sorted
      @networks.sort_by! { |nn| nn.fitness * (sort_desc ? -1 : 1) }
      @sorted = true
      self
    end

    alias_method :<<, :add

    private
    def gaussian_distribution(num_offspring, _)
      sum = 0.0
      distributions = @networks.map(&:fitness).map { |f| sum += f }
      spawn_brains(num_offspring) { gaussian_position(distributions) }
    end

    def gaussian_position(distributions)
      prob = rand(0.0..distributions.last)
      min, max = 0, distributions.length - 1
      while min < max
        mid = min + (max - min) / 2
        if distributions[mid] < prob then min = mid + 1 else max = mid end
      end
      [min, distributions.length - 1].min
    end

    def rand(max = nil)
      @population.rand(max)
    end

    def spawn_brains(num_offspring, &block)
      num_offspring.times
        .map { crossover.(@networks[block.()], @networks[block.()]) }
        .map { |child| mutator.(child) }
    end

    def uniform_distribution(num_offspring, length)
      spawn_brains(num_offspring) { rand(length) }
    end
  end
end