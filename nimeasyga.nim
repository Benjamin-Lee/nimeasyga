import random

## A simple, easy to use package for genetic algorithms in Nim.

proc createIndividual*(genomeSize: Positive): seq[bool] =
  ## The default individual creation method.
  ## Creates a random seq of
  result = newSeq[bool](genomeSize)
  for index in 0..<genomeSize:
    result[index] = random.sample([true, false])

proc crossover*[T](parent_1: seq[bool], parent_2: seq[bool]): (seq[bool], seq[bool]) =
  ## The default crossover function. Takes two parents and chooses a random index at which to recombine them.
  # TODO: placeholder
  return (parent_1, parent_2)

proc mutate*(individual: seq[bool]): seq[bool] =
  ## Randomly flip a bit in the individual's genome.
  result = deepCopy(individual)
  let idx = rand(0..result.high)
  result[idx] = not result[idx]

proc randomSelection*[T](population: seq[T]): T = population[0] # TODO: placeholder
proc tournamentSelection*[T](population: seq[T],
        tournamentSize: Positive) = population[0] # TODO: placeholder

proc GeneticAlgorithm*[T](data: seq[T], fitness: proc(individual: seq[bool], data: seq[T]): float,
                          generations: Positive = 2,
                          populationSize: Positive = 3,
                          crossoverRate: range[0.0..1.0] = 0.5,
                          mutationRate: range[0.0..1.0] = 0.5,
                          elitism = true,
                          createIndividual = createIndividual,
                          seed: int64 = 0): float =
  ## The main algorithm to run the genetic algorithm.
  ##
  ## ## Arguments
  ## - `fitness`
  ## - `generations`: The number of generations to run the
  ## - `seed`: When set to 0, the default, no fixed seed is used and the program is nondeterministic. Set to a nonzero value for a fixed seed.

  # either use the provided seed or randomize
  if seed != 0:
    randomize(seed)
  else:
    randomize()

  # create the intial population
  var population = newSeq[seq[bool]](populationSize)
  for i in 0..<populationSize:
    population[i] = createIndividual(data.len)
  echo population

  for generation in 0..<generations:
    var fitnesses = newSeq[float](populationSize)
    for individual in 0..<populationSize:
      fitnesses[individual] = fitness(population[individual], data)

    var newPopulation = newSeq[seq[bool]](populationSize)

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
      newPopulation[0] = population[fittestIndividualIdx]

    population = newPopulation

    echo fitnesses
  return -1000.0 # TODO: placeholder

# echo createIndividual[int](@[1, 2, 3])
# echo fitness(@[true, true], @[1, 2])
