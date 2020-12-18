//
//  Day3.swift
//  AdventOfCode2020
//

import Foundation

private enum Terrain: String {
    case open = "."
    case tree = "#"
}

private struct TraversalStrategy {
    let right: Int
    let down: Int
}

struct Day3 {
    static func part1(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)
        let numberOfTrees = getNumberOfTrees(in: input, using: TraversalStrategy(right: 3, down: 1))
        print("\(numberOfTrees) trees")
    }

    static func part2(pathToInput: String) {
        let traversalStrategies = [
            TraversalStrategy(right: 1, down: 1),
            TraversalStrategy(right: 3, down: 1),
            TraversalStrategy(right: 5, down: 1),
            TraversalStrategy(right: 7, down: 1),
            TraversalStrategy(right: 1, down: 2)
        ]
        let input = getInput(pathToInput: pathToInput)
        let numberOfTrees = traversalStrategies.map({ getNumberOfTrees(in: input, using: $0) })
        let result = numberOfTrees.reduce(1, { $0 * $1 })
        print("\(numberOfTrees) -> \(result)")
    }

    private static func getInput(pathToInput: String) -> [[Terrain]] {
        guard let contents = try? String(contentsOf: URL(fileURLWithPath: pathToInput)) else { print("Unable to open input"); exit(2) }
        return contents.split(separator: "\n").compactMap({ line in
            return line.map({ Terrain(rawValue: String($0))! })
        })
    }

    private static func getNumberOfTrees(in terrain: [[Terrain]], using traversalStrategy: TraversalStrategy) -> Int {
        var numberOfTrees = 0
        var currentHorizontalIndex = 0
        var currentVerticalIndex = 0
        for (verticalIndex, row) in terrain.enumerated() {
            if verticalIndex < currentVerticalIndex {
                continue
            }
            if row[currentHorizontalIndex % row.count] == .tree {
                numberOfTrees += 1
            }
            currentHorizontalIndex += traversalStrategy.right
            currentVerticalIndex += traversalStrategy.down
        }
        return numberOfTrees
    }
}

