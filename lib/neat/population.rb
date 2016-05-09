module Neat
  class Population
    attr_accessor :experiment,
                  :crossover,
                  :mutator,
                  :coef_disjoint,
                  :coef_excess,
                  :dynamic_distance,
                  :dynamic_ratio,
                  :distance_threshold,
                  :specie_sort_desc,
                  :specie_elitism,
                  :specie_distribution,
                  :size

    attr_reader :random

    attr_reader :innovation, :species

    def initialize(experiment)
      @experiment, @innovation, @species = experiment, Innovation.new, []
      @sorted = false

      yield self if block_given?

      @random ||= Random.new

      @crossover           ||= Crossover
      @mutator             ||= Mutator
      @size                ||= 100
      @coef_disjoint       ||= 1.0
      @coef_excess         ||= 1.0
      @dynamic_distance    ||= false
      @dynamic_ratio       ||= 1.0
      @distance_threshold  ||= 3.0
      @specie_sort_desc    ||= true
      @specie_elitism      ||= 0.0
      @specie_distribution ||= :uniform

      @experiment, @crossover, @mutator = [@experiment, @crossover, @mutator].map do |v|
        v.is_a?(Class) ? v.new(self) : v.tap { |x| x.population = self }
      end

      send("init_#{dynamic_distance ? 'dynamic' : 'static'}")
    end

    def champion
      raise 'must sort' unless @sorted
      @species.first.champion
    end

    def distance(nn1, nn2)
      genes1, genes2 = nn1.genome, nn2.genome
      genes1, genes2 = genes2, genes1 if genes2.count > genes1.count

      d, w, m, i, j = 0.0, 0.0, 0.0, 0, 0
      while i < genes1.count && j < genes2.count
        g1, g2 = genes1[i], genes2[j]
        compare = g1 <=> g2
        if compare == 0
          m, i, j, w = m+1, i+1, j+1, w + (g1.weight - g2.weight).abs
        else
          d += 1
          compare < 0 ? i += 1 : j += 1
        end
      end

      e = genes1.count + genes2.count - (i + j)
      e = (@coef_disjoint * d + @coef_excess * e) / genes1.count
      e + (m == 0.0 ? 0.0 : w/m.to_f)
    end

    def epoch
      #TODO kill unfit species

      reps = @species.map(&:champion)

      #offsprings
      taf = total_avg_fitness
      offsprings = @species.map { |s| Integer(@size * s.avg_fitness / taf) }
      (@size - offsprings.reduce(&:+)).times { |i| offsprings[i] += 1 }

      new_brains, old_species, @species = [], @species, []

      #create species and brains
      old_species.each_with_index do |s, i|
        if offsprings[i] == 0
          @species << Specie.new(self)
          next
        end

        children = s.evolve(offsprings[i])
        new_brains.concat(children)
        @species << Specie.new(self, s.age + 1)
      end

      #separate brains into species
      new_brains.each { |nn| place_brain(nn, reps) }

      #remove empty species
      @species.reject! { |s| s.networks.empty? }

      @distance_threshold *= @dynamic_ratio * @species.count / old_species.count if @dynamic_distance

      @sorted = false
      sort!

      nil
    end

    def rand(max = nil)
      max = [max] if max.is_a?(Range)
      @random.rand(*max)
    end

    def random=(v)
      @random = v.is_a?(Random) ? v : Random.new(v)
    end

    def seed
      @random.seed
    end

    def seed=(v)
      @random = Random.new(v)
    end

    def sort!
      return self if @sorted
      @species.each { |s| s.sort! }.sort_by! { |s| s.champion.fitness * (@specie_sort_desc ? -1 : 1) }
      @sorted = true
      self
    end

    def total_avg_fitness
      @species.map(&:avg_fitness).reduce(&:+)
    end

    private

    def build_brain
      @experiment.build.tap { |n| n.fitness = @experiment.(n) }
    end

    def gen_next_epoch
      taf = total_avg_fitness
      offsprings = @species.map { |s| Integer(@size * s.avg_fitness / taf) }
      (@size - offsprings.reduce(&:+)).times { |i| offsprings[i] += 1 }
      [offsprings, @species.map(&:champion)]
    end

    def init_dynamic
      @species << specie = Specie.new(self)
      specie.networks.concat(@size.times.map { build_brain })
      specie.sort!
    end

    def init_static
      @species << specie = Specie.new(self)

      specie << nn = build_brain
      reps = [nn]

      (@size-1).times { place_brain(build_brain, reps) }

      sort!
    end

    def place_brain(nn, reps)
      @experiment.(nn)

      reps.each_with_index { |rep, i| return @species[i] << nn if distance(rep, nn) < @distance_threshold }

      reps << nn
      @species << Specie.new(self).tap { |s| s << nn }
    end
  end
end