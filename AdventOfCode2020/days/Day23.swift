//
//  Day23.swift
//  AdventOfCode2020
//

import Foundation

struct Day23 {
    static func part1(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)

        let result = simulatePart2(rounds: 100, input: input)

        var currentCup = 1
        var cupsVisited = 1
        var resultString = ""

        while cupsVisited < result.count - 1 {
            resultString.append(String(result[currentCup]))
            currentCup = result[currentCup]
            cupsVisited += 1
        }

        print(resultString)
    }

    static func part2(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)

        let result = simulatePart2(rounds: 10000000, input: input + (10...1000000).map({ $0 }))
        let product = result[1] * result[result[1]] // Multiply the two cups after 1
        print(product)
    }

    /**
     Leaving this here for reference, but `simulatePart2()` is more efficient and works for part 1
     - returns: A list of the cups in order
     */
    private static func simulatePart1(rounds: Int, input: [Int]) -> [Int] {
        var input = input
        let sortedInput = input.sorted()

        var currentCupIndex = 0

        (1...rounds).forEach({ round in
            let currentCup = input[currentCupIndex]

            // Move next 3 cups after current cup, wrapping around if necessary
            let indicesOfCupsToMove = (1...3).map({ (currentCupIndex + $0) % input.count })
            let cupsToMove = indicesOfCupsToMove.map({ input[$0] })

            cupsToMove.forEach({ cupToMove in
                input.removeAll(where: { $0 == cupToMove })
            })

            // Select destination cup, wrapping around to highest value if necessary
            let destinationCup = sortedInput.reversed().first(where: { $0 < currentCup && !cupsToMove.contains($0) })
                ?? sortedInput.reversed().first(where: { $0 != currentCup && !cupsToMove.contains($0) })!
            let destinationIndex = input.firstIndex(of: destinationCup)!

            // Move cups to after destination cup
            input.insert(contentsOf: cupsToMove, at: destinationIndex + 1)

            // Update current cup, wrapping around if necessary
            let updatedCurrentCupIndex = input.firstIndex(of: currentCup)!
            currentCupIndex = (updatedCurrentCupIndex + 1) % input.count
        })

        return input
    }

    /**
     h/t [https://www.reddit.com/r/adventofcode/comments/kixh1i/2020_day_23_part_2_is_there_a_faster_way/]()

     - returns: An array that represents a linked list where the index in the array is the next cup.

        For example, if nextCup[3] = 8, then the next cup after 3 is 8.
     */
    private static func simulatePart2(rounds: Int, input: [Int]) -> [Int] {
        var nextCup = [Int](repeating: -1, count: input.count + 1)
        var maxCup = -1

        // Initialize the nextCup array using the input
        input.enumerated().forEach({ index, element in
            let nextIndex = index + 1 < input.endIndex ? index + 1 : 0
            nextCup[element] = input[nextIndex]

            if element > maxCup {
                maxCup = element
            }
        })

        var currentCup = input[0]

        (1...rounds).forEach({ round in
            // Move next 3 cups after current cup
            let cupsToMove = [
                nextCup[currentCup],
                nextCup[nextCup[currentCup]],
                nextCup[nextCup[nextCup[currentCup]]]
            ]

            // Select destination cup
            var foundDestinationCup = false
            var destinationCup = currentCup - 1
            while !foundDestinationCup {
                if destinationCup <= 0 {
                    // Wrap around to highest value
                    destinationCup = maxCup
                } else if destinationCup == currentCup || cupsToMove.contains(destinationCup) {
                    // Skip current cup or cups that are being moved
                    destinationCup -= 1
                } else {
                    // Found destination cup that is within range and not being moved
                    foundDestinationCup = true
                }
            }

            // Update next cups so that the cups to move are after the destination cup
            let afterDestinationCup = nextCup[destinationCup]
            let afterCupsToMove = nextCup[cupsToMove[2]]

            nextCup[currentCup] = afterCupsToMove
            nextCup[destinationCup] = cupsToMove[0]
            nextCup[cupsToMove[2]] = afterDestinationCup

            // Update current cup
            currentCup = afterCupsToMove
        })

        return nextCup
    }

    private static func getInput(pathToInput: String) -> [Int] {
        guard let contents = try? String(contentsOf: URL(fileURLWithPath: pathToInput)) else { print("Unable to open input"); exit(2) }
        return contents.compactMap({ Int(String($0)) })
    }
}
