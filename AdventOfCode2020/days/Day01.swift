//
//  Day1.swift
//  AdventOfCode2020
//

import Foundation

struct Day1 {
    static func part1(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)
        guard let sumsTo2020 = findElements(in: input, thatSumTo: 2020) else { print("No result found"); return }
        let result = sumsTo2020.0 * sumsTo2020.1
        print("\(sumsTo2020.0) x \(sumsTo2020.1) = \(result)")
    }

    static func part2(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)
        for (index, candidate) in input.enumerated() {
            var inputMinusCandidate = input
            inputMinusCandidate.remove(at: index)
            if let sumsTo2020 = findElements(in: inputMinusCandidate, thatSumTo: 2020 - candidate) {
                let result = candidate * sumsTo2020.0 * sumsTo2020.1
                print("\(candidate) * \(sumsTo2020.0) * \(sumsTo2020.1) = \(result)")
                return
            }
        }
        print("No result found")
    }

    private static func getInput(pathToInput: String) -> [Int] {
        guard let contents = try? String(contentsOf: URL(fileURLWithPath: pathToInput)) else { print("Unable to open input"); exit(2) }
        return contents.split(separator: "\n").compactMap({ Int($0) })
    }

    private static func findElements(in set: [Int], thatSumTo sum: Int) -> (Int, Int)? {
        guard let result = set.first(where: { set.contains(sum - $0) }) else { return nil }
        return (result, sum - result)
    }
}
