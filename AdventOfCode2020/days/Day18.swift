//
//  Day18.swift
//  AdventOfCode2020
//

import Foundation

struct Day18 {
    static func part1(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)
        let results = input.map({ evaluateWithPart1Rules($0)! })
        let sum = results.reduce(0, +)
        print(sum)
    }

    static func part2(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)
        let results = input.map({ evaluateWithPart2Rules($0)! })
        let sum = results.reduce(0, +)
        print(sum)
    }

    /// Addition and multiplication have same precedence, evaluated left to right respecting parentheses
    private static func evaluateWithPart1Rules(_ expression: String) -> Int? {
        var result: Int?
        var operation: ((Int, Int) -> Int)?
        var expression = expression

        while !expression.isEmpty {
            let numberString = expression.prefix(while: { $0.isNumber })
            if let number = Int(numberString) {
                // Apply previous operation with previous result if they exist, else set result to number
                if let previousResult = result, let previousOperation = operation {
                    result = previousOperation(previousResult, number)
                } else {
                    result = number
                }

                expression.removeFirst(numberString.count)
            } else if let first = expression.first, first == "+" {
                operation = (+)
                expression.removeFirst()
            } else if let first = expression.first, first == "*" {
                operation = (*)
                expression.removeFirst()
            } else if let parentheticalString = prefixParentheticalExpression(in: expression) {
                // Trim leading "(" and trailing ")"
                let trimmedParentheticalString = parentheticalString.dropFirst().dropLast()

                // Recursively evaluate the parenthetical expression
                if let parentheticalResult = evaluateWithPart1Rules(String(trimmedParentheticalString)) {
                    // Apply previous operation with previous result if they exist, else set result to parenthetical result
                    if let previousResult = result, let previousOperation = operation {
                        result = previousOperation(previousResult, parentheticalResult)
                    } else {
                        result = parentheticalResult
                    }
                }

                expression.removeFirst(parentheticalString.count)
            }
        }

        return result
    }

    /// Addition takes precedence over multiplication, evaluated left to right respecting parentheses
    private static func evaluateWithPart2Rules(_ expression: String) -> Int? {
        // Find entire parenthetical expression starting at index of first "("
        if let parenthesis = expression.firstIndex(of: "("), let parentheticalString = prefixParentheticalExpression(in: String(expression[parenthesis...])) {
            // Trim leading "(" and trailing ")"
            let trimmedParentheticalString = parentheticalString.dropFirst().dropLast()

            // Recursively evaluate the parenthetical expression, then re-evaluate the expression after replacing the parenthetical expression with its result
            if let parentheticalResult = evaluateWithPart2Rules(String(trimmedParentheticalString)) {
                let parentheticalRange = (parenthesis..<expression.index(parenthesis, offsetBy: parentheticalString.count))
                let replacedParentheticalResult = expression.replacingCharacters(in: parentheticalRange, with: String(parentheticalResult))
                return evaluateWithPart2Rules(replacedParentheticalResult)
            }
        }

        if let multiplication = expression.firstIndex(of: "*") {
            let leftSide = evaluateWithPart2Rules(String(expression[..<multiplication]))
            let rightSide = evaluateWithPart2Rules(String(expression[expression.index(after: multiplication)...]))
            return leftSide! * rightSide!
        } else {
            // Expression only contains addition (no multiplication or parentheses);
            // it can be evaluated like a normal expression
            return NSExpression(format: expression).expressionValue(with:nil, context: nil) as? Int
        }
    }

    /**
     - returns: The complete parenthetical expression at the start of this string or nil if there is none.

        Examples:
         - (1 + 2) for (1 + 2) + (3 + 4)
         - ((1 + 2) * (3 + 4)) for ((1 + 2) * (3 + 4)) + 2 + 4 * 2
         - (1 + (2 * 3)) for - (1 + (2 * 3)) + 4
         - nil for 1 + (2 * 3)
     */
    private static func prefixParentheticalExpression(in string: String) -> String.SubSequence? {
        guard string.hasPrefix("(") else { return nil }

        var expectedClosingParentheses = 0
        var encounteredClosingParentheses = 0
        let parentheticalString = string.prefix(while: { character in
            let continueScanning = encounteredClosingParentheses == 0 || encounteredClosingParentheses < expectedClosingParentheses
            if character == "(" {
                expectedClosingParentheses += 1
            } else if character == ")" {
                encounteredClosingParentheses += 1
            }
            return continueScanning
        })

        return parentheticalString
    }

    private static func getInput(pathToInput: String) -> [String] {
        guard let contents = try? String(contentsOf: URL(fileURLWithPath: pathToInput)) else { print("Unable to open input"); exit(2) }

        return contents.components(separatedBy: "\n").compactMap({ line in
            if line.isEmpty {
                return nil
            } else {
                return line.filter({ !$0.isWhitespace })
            }
        })
    }
}
