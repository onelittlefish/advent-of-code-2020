//
//  Day15.swift
//  AdventOfCode2020
//

import Foundation

struct Day15 {
    static func part1(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)
        let result = run(input: input, turns: 2020)
        print("\(result ??? "nil")")
    }

    static func part2(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)
        let start = Date()
        let result = run(input: input, turns: 30000000)
        print("\(result ??? "nil") (took \(Date().timeIntervalSince(start)) seconds)")
    }

    private static func run(input: [Int], turns: Int) -> Int? {
        // Using a pre-allocated array where the index is used for the number is slightly faster than a dictionary
        var lastTurnSpoken = [Int](repeating: 0, count: turns)
        var currentTurn = 0
        var lastNumber: Int?

        input.forEach({ number in
            currentTurn += 1
            if let lastNumber = lastNumber {
                lastTurnSpoken[lastNumber] = currentTurn - 1
            }
            lastNumber = number
        })

        guard var nnLastNumber = lastNumber else { return nil }

        ((currentTurn + 1)...turns).forEach({ _ in
            currentTurn += 1
            let newNumber: Int
            let lastSpoken = lastTurnSpoken[nnLastNumber]
            if lastSpoken != 0 {
                newNumber = (currentTurn - 1) - lastSpoken
            } else {
                newNumber = 0
            }
            lastTurnSpoken[nnLastNumber] = currentTurn - 1
            nnLastNumber = newNumber
        })

        return nnLastNumber
    }

    private static func getInput(pathToInput: String) -> [Int] {
        guard let contents = try? String(contentsOf: URL(fileURLWithPath: pathToInput)) else { print("Unable to open input"); exit(2) }
        return contents.components(separatedBy: ",").compactMap({ Int($0.trimmingCharacters(in: .whitespacesAndNewlines)) })
    }
}
