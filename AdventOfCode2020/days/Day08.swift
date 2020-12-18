//
//  Day08.swift
//  AdventOfCode2020
//

import Foundation

private enum Operation: String {
    case nop
    case acc
    case jmp
}

private struct Instruction {
    let operation: Operation
    let amount: Int
}

struct Day8 {
    static func part1(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)
        let accumulator = run(input).accumulator
        print("Accumulator value before repetition: \(accumulator)")
    }

    static func part2(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)

        let indicesExecuted = run(input).indicesExecuted

        // One of the nop or jmp instructions before the repetition must be wrong.
        // Generate a version of the instructions for each nop/jmp where it is replaced by a jmp/nop.
        let potentialFixes = indicesExecuted.map({ (index: $0, instruction: input[$0]) }).compactMap({ line -> [Instruction]? in
            var lines = input
            switch line.instruction.operation {
            case .nop:
                lines[line.index] = Instruction(operation: .jmp, amount: line.instruction.amount)
                return lines
            case .jmp:
                lines[line.index] = Instruction(operation: .nop, amount: line.instruction.amount)
                return lines
            default:
                return nil
            }
        })

        for potentialFix in potentialFixes {
            let runResult = run(potentialFix)
            if !runResult.hasLoop {
                print("Accumulator value with fix: \(runResult.accumulator)")
                break
            }
        }
    }

    private static func run(_ lines: [Instruction]) -> (hasLoop: Bool, accumulator: Int, indicesExecuted: [Int]) {
        var previousIndices = Set<Int>()
        var currentIndex = 0
        var hasLoop = false
        var accumulator = 0

        while currentIndex < lines.endIndex {
            if previousIndices.contains(currentIndex) {
                hasLoop = true
                break
            }

            previousIndices.insert(currentIndex)

            switch lines[currentIndex].operation {
            case .nop:
                currentIndex += 1
            case .acc:
                accumulator += lines[currentIndex].amount
                currentIndex += 1
            case .jmp:
                currentIndex += lines[currentIndex].amount
            }
        }

        return (hasLoop, accumulator, Array(previousIndices))
    }

    private static func getInput(pathToInput: String) -> [Instruction] {
        guard let contents = try? String(contentsOf: URL(fileURLWithPath: pathToInput)) else { print("Unable to open input"); exit(2) }

        return contents.components(separatedBy: "\n").compactMap({ line in
            let components = line.components(separatedBy: .whitespaces)
            guard let operationString = components.first, let operaion = Operation(rawValue: operationString),
                  let amountString = components[safe: 1], let amount = Int(amountString) else { return nil }
            return Instruction(operation: operaion, amount: amount)
        })
    }
}
