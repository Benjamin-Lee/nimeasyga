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

test "Basic maximization and minimization checks":
    let data = @[1, 2, 3, 4, 5, -125]
    func fitness(genome: seq[bool], data: seq[int]): float =
        for i, gene in genome:
            if gene:
                result += float(data[i])
    var optimizationResult = geneticAlgorithm(data, fitness)
    check(optimizationResult.fitness == 15)
    check(optimizationResult.genome == @[true, true, true, true, true, false])

    optimizationResult = geneticAlgorithm(data, fitness,
            maximizeFitness = false)
    check(optimizationResult.fitness == -125.0)
    check(optimizationResult.genome == @[false, false, false, false, false, true])
