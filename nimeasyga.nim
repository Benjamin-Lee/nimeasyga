import random

## A simple, easy to use package for genetic algorithms in Nim.

proc createIndividual*[T](data: T): seq[bool] =
  ## The default individual creation method.
  ## Creates a seq of randomly chosen bools of the same length of data.
  result = newSeq[bool](data.len)
  for index in 0..<data.len:
    result[index] = random.sample([true, false])

proc crossover*[T](parent_1: seq[T], parent_2: seq[T]): (seq[T], seq[T]) =
  ## The default crossover function.
  ## Takes two parents and chooses a random index at which to recombine them.
  let idx = rand(0..<parent_1.high)
  return (parent_1[0..idx] & parent_2[idx+1..parent_2.high], parent_2[0..idx] &
      parent_1[idx+1..parent_1.high])

proc mutate*(individual: seq[bool]): seq[bool] =
  ## The default mutation function when individuals are represented as `seq[bool]`.
  ## Randomly flips a bit in the individual's genome.
  result = deepCopy(individual)
  let idx = rand(0..result.high)
  result[idx] = not result[idx]

proc randomSelection*[T](population: seq[T]): T =
  return random.sample(population)

proc tournamentSelection*[T](population: seq[T]): T =
  return population[0] # TODO: placeholder

proc geneticAlgorithm*[T, I](data: T, fitness: proc(individual: I, data: T): float,
                          generations: Positive = 2,
                          populationSize: Positive = 3,
                          crossoverRate: range[0.0..1.0] = 0.5,
                          mutationRate: range[0.0..1.0] = 0.5,
                          elitism = true,
                          createIndividual: proc(data: T): I = createIndividual,
                          mutate: proc(individual: I): I = mutate,
                          crossover: proc(parent_1: I, parent_2: I): (I,
                              I) = crossover,
                          selection: proc(population: seq[
                              I]): I = tournamentSelection,
                          seed: int64 = 0): float =
  ## The main algorithm to run the genetic algorithm.
  ##
  ## ## Arguments
  ## - `fitness`
  ## - `generations`: The number of generations to run the
  ## - `seed`: When set to 0, the default, no fixed seed is used and the program is nondeterministic. Set to a nonzero value for a fixed seed.

  # either use the provided seed or randomize
  if seed == 0:
    randomize()
  else:
    randomize(seed)

  # create the intial population
  var population = newSeq[I](populationSize)
  for i in 0..<populationSize:
    population[i] = createIndividual(data)
  var nextPopulation = newSeq[I](populationSize) # to hold the next generation
  echo population

  var fitnesses = newSeq[float](populationSize)

  for generation in 0..<generations:

    for idx, individual in population:
      fitnesses[idx] = fitness(individual, data)

    # preserve the fittest individual, if requested
    if elitism:
      # placeholder variables
      var fittestIndividualIdx = 0
      var fittestSoFar = fitnesses[0]

      # find the fittest individual's index
      for i in 0..<fitnesses.len:
        if fitnesses[i] > fittestSoFar:
          fittestSoFar = fitnesses[i]
          fittestIndividualIdx = i

      # add it to the new population
      nextPopulation[0] = population[fittestIndividualIdx]

    population = nextPopulation

    echo fitnesses
  return -1000.0 # TODO: placeholder

# echo createIndividual[int](@[1, 2, 3])
# echo fitness(@[true, true], @[1, 2])
