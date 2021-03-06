import random
import sugar

## A simple, easy to use package for genetic algorithms in Nim.

template dbg(args: varargs[untyped]) =
  ## Modified from https://github.com/enthus1ast/nimDbg
  ## Like `debugEcho` but removed when not compiled with -d:debug
  when defined debug: debugEcho args

type Individual*[G] = object
  ## A type to hold a genome and its calculated fitness.
  genome*: G
  fitness*: float

proc `<`*(x, y: Individual): bool = x.fitness < y.fitness
proc `<=`*(x, y: Individual): bool = x.fitness <= y.fitness

proc createGenome*[T](data: T): seq[bool] =
  ## The default genome creation method.
  ## Creates a seq of randomly chosen bools of the same length of data.
  result = newSeq[bool](data.len)
  for index in 0..<data.len:
    result[index] = random.sample([true, false])

proc crossover*[T](genome_1: seq[T], genome_2: seq[T]): (seq[T], seq[T]) =
  ## The default crossover function.
  ## Takes two parent genomes and chooses a random index at which to recombine them.
  let idx = rand(0..<genome_1.high)
  return (genome_1[0..idx] & genome_2[idx+1..genome_2.high], genome_2[0..idx] &
      genome_1[idx+1..genome_1.high])

proc mutate*(genome: seq[bool]): seq[bool] =
  ## The default mutation function when genomes are represented as `seq[bool]`.
  ## Randomly flips a bit in the genome.
  result = deepCopy(genome)
  let idx = rand(0..result.high)
  result[idx] = not result[idx]

proc randomSelection*(population: seq[Individual],
    maximizeFitness: bool): Individual =
  return random.sample(population)

proc tournamentSelection*(population: seq[Individual],
    maximizeFitness: bool): Individual =
  ## Tournament selection algorithm.
  ## Chooses two members of the population and returns the fitter of the two.
  var x = sample(population)
  var y = sample(population)
  if maximizeFitness:
    return max(x, y)
  else:
    return min(x, y)

proc defaultCallback*(fittest: Individual, generation: int): bool =
  ## The default callback function.
  ## In this case, it just returns `true`.
  return true

proc geneticAlgorithm*[D, G](data: D,
                             fitness: (G, D) -> float,
                             generations: Positive = 100,
                             populationSize: Positive = 50,
                             crossoverRate: range[0.0..1.0] = 0.8,
                             mutationRate: range[0.0..1.0] = 0.2,
                             elitism = true,
                             createGenome: (D) -> G = createGenome,
                             mutate: (G) -> G = mutate,
                             crossover: (G, G) -> (G, G) = crossover,
                             selection: (seq[Individual[G]], bool) ->
                                 Individual[G] = tournamentSelection,
                             seed: int64 = 0,
                             maximizeFitness = true,
                             callback: (Individual[G], int) ->
                                 bool = defaultCallback): Individual[G] =
  ## The main algorithm to run the genetic algorithm.
  ##
  ## By default, the type of `G` is assumed to be `seq[bool]`.
  ## However, while theoretically doable, not every candidate solution is amenable to being represented as a bitstring.
  ## In these cases, you will need to define your own mutation and crossover function.
  ##
  ## ## Arguments
  ## - `data`: The input data use to evaluate the fitness of the indviduals in the population
  ## - `fitness`: The function the calculuates the fitness of a genome
  ## - `generations`: The number of generations to run the
  ## - `elitism`: Whether to conserve the fittest individual in a generation
  ## - `createGenome`: A function to generate genomes given data
  ## - `seed`: When set to 0, the default, no fixed seed is used and the program is nondeterministic. Set to a nonzero value for a fixed seed.
  ## - `maximizeFitness`: Whether to make the fitness value as large or as small as possible.
  ## - `callback`: A function to be called with the fittest individual and the generation number. If the return value is `false`, the optimization returns early.

  # either use the provided seed or randomize
  if seed == 0:
    randomize()
  else:
    randomize(seed)

  # create the initial population and the next population's variables
  var population, nextPopulation = newSeq[Individual[G]](populationSize)

  # instantiate the first generation
  for i in 0..<populationSize:
    population[i] = Individual[G](genome: createGenome(data))

  for generation in 1..generations:
    dbg "\n############\nGeneration ", generation, "\n############"

    # evaluate the fitness of the population
    for individual in population.mitems:
      individual.fitness = fitness(individual.genome, data)
    dbg "\nPopulation: ", population

    # create the next generation
    for i in countup(0, populationSize - 1, 2):
      var parent_1 = selection(population, maximizeFitness)
      var parent_2 = selection(population, maximizeFitness)

      if rand(0.0..1.0) < crossoverRate:
        let newGenes = crossover(parent_1.genome, parent_2.genome)
        parent_1.genome = newGenes[0]
        parent_2.genome = newGenes[1]

      if rand(0.0..1.0) < mutationRate:
        parent_1.genome = mutate(parent_1.genome)
        parent_2.genome = mutate(parent_2.genome)

      nextPopulation[i] = parent_1
      # prevent an out of bounds assignment
      if i+1 < populationSize:
        nextPopulation[i+1] = parent_2

    var fittest = if maximizeFitness: max(population) else: min(population)
    if not callback(fittest, generation):
      break

    # preserve the fittest individual, if requested
    if elitism:
      # add it to the new population
      nextPopulation[0] = fittest
      dbg "Fittest: ", fittest

    population = nextPopulation

  if maximizeFitness:
    return max(population)
  return min(population)
