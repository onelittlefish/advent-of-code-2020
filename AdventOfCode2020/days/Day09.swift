//
//  Day09.swift
//  AdventOfCode2020
//

import Foundation

struct Day9 {
    static func part1(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)
        print("Invalid: \(findInvalidNumber(input) ??? "nil")")
    }

    static func part2(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)
        guard let invalidNumber = findInvalidNumber(input) else { print("All numbers valid"); return }
        guard let sliceThatSumsToInvalidNumber = findSlice(in: input, thatSumsTo: invalidNumber) else { print("Slice not found"); return }
        let result = (sliceThatSumsToInvalidNumber.min() ?? 0) + (sliceThatSumsToInvalidNumber.max() ?? 0)
        print("Sum: \(result)")
    }

    private static func findInvalidNumber(_ list: [Int]) -> Int? {
        let preamble = 25
        for index in (preamble..<list.endIndex) {
            let previousNumbers = list[index - preamble..<index]
            let currentNumber = list[index]
            // Number is valid if two of the last n numbers sum to it, where n = preamble size
            let isValid = previousNumbers.contains(where: { i in
                return previousNumbers.contains(where: { j in
                    guard i != j else { return false } // Numbers must be different
                    return i + j == currentNumber
                })
            })
            if !isValid {
                return currentNumber
            }
        }
        return nil
    }

    private static func findSlice(in list: [Int], thatSumsTo total: Int) -> [Int]? {
        var minIndex = list.startIndex
        var maxIndex = minIndex + 1
        while minIndex < list.endIndex - 1 {
            let slice = list[minIndex...maxIndex]
            let sum = slice.reduce(0, +)

            if sum == total {
                return Array(slice)
            } else if sum > total {
                // Exceeded max so slice can't start at this min index, start over with next min index
                minIndex += 1
                maxIndex = minIndex + 1
            } else {
                // Might still reach the total, increment max index
                maxIndex += 1
            }
        }
        return nil
    }

    private static func getInput(pathToInput: String) -> [Int] {
        guard let contents = try? String(contentsOf: URL(fileURLWithPath: pathToInput)) else { print("Unable to open input"); exit(2) }
        return contents.components(separatedBy: "\n").compactMap({ Int($0) })
    }
}
