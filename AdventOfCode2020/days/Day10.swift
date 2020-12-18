//
//  Day10.swift
//  AdventOfCode2020
//

import Foundation
import SwiftGraph

struct Day10 {
    static func part1(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput).sorted()

        var differences = input.enumerated().reduce(into: [Int: Int](), { differences, enumerated in
            let difference = enumerated.offset == 0 ? enumerated.element : enumerated.element - input[enumerated.offset - 1]
            differences[difference, default: 0] += 1
        })
        differences[3, default: 0] += 1 // Add a 3-jolt difference for your device's built-in adapter
        
        let oneJoltDifferences = differences[1, default: 0]
        let threeJoltDifferences = differences[3, default: 0]
        print("\(oneJoltDifferences) 1-jolt differences x \(threeJoltDifferences) 3-jolt differences = \(oneJoltDifferences * threeJoltDifferences)")
    }

    static func part2(pathToInput: String) {
        // Using a traditional depth-first search for this is way too slow.
        // H/t to r/adventofcode for pointing toward some features of the input:
        // Two consecutive numbers in the sorted input always have a difference of 1 or 3.
        // There is no run of 1-difference numbers longer than 5.
        let input = (getInput(pathToInput: pathToInput) + [0]).sorted()

        var runsSeparatedBy3JoltDifference: [[Int]] = []
        var minIndex = input.startIndex
        var maxIndex = minIndex + 1
        while maxIndex < input.endIndex {
            if input[maxIndex] - input[maxIndex - 1] == 3 {
                runsSeparatedBy3JoltDifference.append(Array(input[minIndex..<maxIndex]))
                minIndex = maxIndex
                maxIndex += 1
            } else {
                maxIndex += 1
            }
        }
        runsSeparatedBy3JoltDifference.append(Array(input[minIndex..<maxIndex]))

        print("Runs separated by 3-jolt difference: \(runsSeparatedBy3JoltDifference)")

        let pathsPerConsecutiveRunLength = [
            1: 1,
            2: 1,
            3: 2,
            4: 4,
            5: 7
        ]

        let paths = runsSeparatedBy3JoltDifference.map({ pathsPerConsecutiveRunLength[$0.count] ?? 1 })
        let numberOfPaths = paths.reduce(1, { $0 * $1 })
        print("\(numberOfPaths) paths")
    }

    private static func getInput(pathToInput: String) -> [Int] {
        guard let contents = try? String(contentsOf: URL(fileURLWithPath: pathToInput)) else { print("Unable to open input"); exit(2) }
        return contents.components(separatedBy: "\n").compactMap({ Int($0) })
    }
}
