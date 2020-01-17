import unittest
import nimeasyga

test "Check mutation function returns different bool seq":
    check(mutate(@[true, true, true]) != @[true, true, true])

test "Check createGenome length is same as input data length":
    check(createGenome(@[1, 2, 3]).len == 3)

test "Check basic knapsack optimization returns expected result":
    let data = @[("apple", 15), ("banana", 10), ("carrot", 12), ("pear", 5), (
            "mango", 8)]
    func fitness (genome: seq[bool], data: seq[(string, int)]): float =
        var itemsInKnapsack = 0
        for i, gene in genome:
            if gene:
                result += float(data[i][1])
                itemsInKnapsack += 1
        if itemsInKnapsack > 3:
            return 0

    var optimizationResult = geneticAlgorithm(data, fitness)
    check(optimizationResult.fitness == 37.0)
    check(optimizationResult.genome == @[true, true, true, false, false])

test "Basic maximization, minimization, and callback checks":
    let data = @[1, 2, 3, 4, 5, -125]
    func fitness(genome: seq[bool], data: seq[int]): float =
        for i, gene in genome:
            if gene:
                result += float(data[i])

    # check maximization works
    var optimizationResult = geneticAlgorithm(data, fitness)
    check(optimizationResult.fitness == 15)
    check(optimizationResult.genome == @[true, true, true, true, true, false])

    # check minimization works
    optimizationResult = geneticAlgorithm(data, fitness,
            maximizeFitness = false)
    check(optimizationResult.fitness == -125.0)
    check(optimizationResult.genome == @[false, false, false, false, false, true])

    # Early stopping if fitness is high enough
    func callback(x: Individual[seq[bool]], y: int): bool = x.fitness < 3
    optimizationResult = geneticAlgorithm(data, fitness, callback = callback)
    check(optimizationResult.fitness > 3)

    # Early stopping with no improvement
    var gensNoImprovement = 0
    var totalGenerations = 0
    var bestFitness = 0.0
    proc callback2(fittest: Individual[seq[bool]], generation: int): bool =
        if fittest.fitness > bestFitness:
            bestFitness = fittest.fitness
            gensNoImprovement = 0
        else:
            gensNoImprovement += 1
        totalGenerations = generation
        if gensNoImprovement > 10:
            return false
        else:
            return true
    discard geneticAlgorithm(data, fitness, generations = 100,
            callback = callback2)
    check(gensNoImprovement == 11)
    check(totalGenerations < 100)
