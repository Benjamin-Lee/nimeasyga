import random
import sugar

## A simple, easy to use package for genetic algorithms in Nim.

template dbg(args: varargs[untyped]) =
  ## Modified from https://github.com/enthus1ast/nimDbg
  ## Like `debugEcho` but removed when not compiled with -d:debug
  when defined debug: debugEcho args

type Individual*[G] = object
  ## A type to hold a genome and its calculated fitness.
  genome: G
  fitness: float

proc `<`*(x, y: Individual): bool =
  ## The comparison operator for individuals.
  ## Works by compares fitnesses.
  x.fitness < y.fitness

proc createGenome*[T](data: T): seq[bool] =
  ## The default genome creation method.
  ## Creates a seq of randomly chosen bools of the same length of data.
  result = newSeq[bool](data.len)
  for index in 0..<data.len:
    result[index] = random.sample([true, false])

proc crossover*[G](genome_1: seq[G], genome_2: seq[G]): (seq[G], seq[G]) =
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

proc randomSelection*(population: seq[Individual]): Individual =
  return random.sample(population)

proc tournamentSelection*(population: seq[Individual]): Individual =
  ## Tournament selection algorithm.
  ## Chooses two members of the population and returns the fitter of the two.
  var x = sample(population)
  var y = sample(population)
  if x.fitness > y.fitness:
    return x
  return y

proc geneticAlgorithm*[D, G](data: D,
                             fitness: (G, D) -> float,
                             generations: Positive = 2,
                             populationSize: Positive = 3,
                             crossoverRate: range[0.0..1.0] = 0.5,
                             mutationRate: range[0.0..1.0] = 0.5,
                             elitism = true,
                             createGenome: (D) -> G = createGenome,
                             mutate: (G) -> G = mutate,
                             crossover: (G, G) -> (G, G) = crossover,
                             selection: (seq[Individual[G]]) -> Individual[
                                 G] = tournamentSelection,
                             seed: int64 = 0): float =
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

  for generation in 0..<generations:
    dbg "\n############\nGeneration ", generation, "\n############"

    for individual in population.mitems:
      individual.fitness = fitness(individual.genome, data)

    dbg "\nPopulation: ", population

    # preserve the fittest individual, if requested
    if elitism:
      # add it to the new population
      nextPopulation[0] = max(population)
      dbg "Fittest: ", max(population)

    population = nextPopulation

  return -1000.0 # TODO: placeholder
