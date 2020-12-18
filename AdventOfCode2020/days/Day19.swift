//
//  Day19.swift
//  AdventOfCode2020
//

import Foundation
import SwiftParser

private class Part1Parser: Parser {
    init(rules: [Part1Rule]) {
        super.init()
        grammar = Grammar() { grammar in
            rules.forEach({ rule in
                if let parserRule = rule.parserRule {
                    grammar[rule.name] = parserRule
                }
            })
            return (^"0")*!*
        }
    }
}

private struct Part1Rule {
    let name: String
    let rawValue: String
    let parserRule: ParserRule?

    private static let characterPattern = #"\"[a-z]\""#
    private static let followedByPattern = #"[0-9 ]+"#
    private static let orPattern = #"[0-9 \|]+"#

    init(name: String, rawValue: String) {
        self.name = name
        self.rawValue = rawValue

        if rawValue.range(of: Self.characterPattern, options: .regularExpression) == (rawValue.startIndex..<rawValue.endIndex) {
            let character = rawValue[rawValue.index(rawValue.startIndex, offsetBy: 1)]
            parserRule = %"\(character)"
        } else if rawValue.range(of: Self.followedByPattern, options: .regularExpression) == (rawValue.startIndex..<rawValue.endIndex) {
            parserRule = Self.getFollowedByRule(rawValue)
        } else if rawValue.range(of: Self.orPattern, options: .regularExpression) != nil {
            let rules = rawValue.components(separatedBy: " | ")
            let leftSide = rules[0]
            let rightSide = rules[1]
            parserRule = Self.getFollowedByRule(leftSide) | Self.getFollowedByRule(rightSide)
        } else {
            parserRule = nil
        }
    }

    private static func getFollowedByRule(_ rawValue: String) -> ParserRule {
        let rules = rawValue.components(separatedBy: " ")
        if rules.count > 1 {
            return rules[1...].reduce(^"\(rules[0])", { result, rule in
                return result ~ ^"\(rule)"
            })
        } else {
            return ^"\(rules[0])"
        }
    }
}

private struct Part2Rule {
    typealias FollowedByRules = [String]

    let name: String
    let character: Character?
    /**
     This is a nested array of rule names. The outer array contains lists of or rules;
     only one of these inner lists needs to match. Each inner list contains followed by rules;
     all of these rules need to match.
     */
    let orRules: [FollowedByRules]

    private static let characterPattern = #"\"([a-z])\""#
    private static let followedByPattern = #"[0-9 ]+"#
    private static let orPattern = #"[0-9 \|]+"#

    init(string: String) {
        let components = string.components(separatedBy: ": ")
        name = components[0]

        let rawValue = components[1]

        if rawValue.range(of: Self.characterPattern, options: .regularExpression) == (rawValue.startIndex..<rawValue.endIndex) {
            character = rawValue[rawValue.index(rawValue.startIndex, offsetBy: 1)]
        } else {
            character = nil
        }

        if rawValue.range(of: Self.followedByPattern, options: .regularExpression) == (rawValue.startIndex..<rawValue.endIndex) {
            orRules = [rawValue.components(separatedBy: " ")]
        } else if rawValue.range(of: Self.orPattern, options: .regularExpression) != nil {
            let subRules = rawValue.components(separatedBy: " | ")
            let leftSide = subRules[0]
            let rightSide = subRules[1]
            orRules = [leftSide.components(separatedBy: " "), rightSide.components(separatedBy: " ")]
        } else {
            orRules = []
        }
    }
}

struct Day19 {
    /**
     Leaving this here for reference, but the part 2 method using `Part2Rule` and `matches()` works for part 1
     and can handle recursive rules
     */
    static func part1(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)
        let rules = input.rules.map({ ruleString -> Part1Rule in
            let components = ruleString.components(separatedBy: ": ")
            return Part1Rule(name: components[0], rawValue: components[1])
        })
        let parser = Part1Parser(rules: rules)
        let matchingMessages = input.messages.filter({ (try? parser.parse($0)) == true })
        print(matchingMessages.count)
    }

    static func part2(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)

        var rules = input.rules.map({ Part2Rule(string: $0) })
        rules.removeAll(where: { $0.name == "8" || $0.name == "11" })
        rules.append(contentsOf: [
            Part2Rule(string: "8: 42 | 42 8"),
            Part2Rule(string: "11: 42 31 | 42 11 31")
        ])

        let rulesByName = [String: Part2Rule](uniqueKeysWithValues: rules.map({ ($0.name, $0) }))

        let matchingMessages = input.messages.filter({ message in
            matches(message, rules: [rulesByName["0"]!], allRulesByName: rulesByName)
        })
        print(matchingMessages.count)
    }

    /**
     Basically a Swift port of [this Python implementation](https://www.reddit.com/r/adventofcode/comments/kg1mro/2020_day_19_solutions/ggeybw6)
     that uses recursion.

     The part 1 implementation using [SwiftParser](https://github.com/pixelspark/swift-parser-generator)
     didn't seem to work using the "zero or more" or "optionally" operators.
     It's possible I didn't completely understand how to use it, but it seemed to always behave
     greedily and match as many of the optional letters as possible, even if that would fail the rest of the string.

     - parameters:
        - string: The string to match
        - rules: The list of rules to match against the string. For non-recursive calls, this should be an array with
        a single element, the root rule "0".
        - allRulesByName: A dictionary that can be used to look up rules by their name
     */
    private static func matches(_ string: String, rules: [Part2Rule], allRulesByName: [String: Part2Rule]) -> Bool {
        if string.isEmpty || rules.isEmpty {
            // Base case: if either string or rules ran out before the other, this isn't a match
            return string.isEmpty == rules.isEmpty
        }

        let rule = rules[0]
        if let character = rule.character {
            if string.first == character {
                // Character matches, remove character and rule and match the remaining
                return matches(String(string.dropFirst()), rules: Array(rules.dropFirst()), allRulesByName: allRulesByName)
            } else {
                return false
            }
        } else {
            // This is a non-terminal rule, expand the rule and try to match against the same string
            // Only one of the or rules needs to match
            return rule.orRules.contains(where: { followedByRules in
                // All of the followed by rules need to match, so replace this rule with its followed by rules
                let followedByRules = followedByRules.compactMap({ allRulesByName[$0] })
                return matches(string, rules: followedByRules + Array(rules.dropFirst()), allRulesByName: allRulesByName)
            })
        }
    }

    private static func getInput(pathToInput: String) -> (rules: [String], messages: [String]) {
        guard let contents = try? String(contentsOf: URL(fileURLWithPath: pathToInput)) else { print("Unable to open input"); exit(2) }

        let components = contents.components(separatedBy: "\n\n")

        guard components.count == 2 else { return ([], []) }

        let rules = components[0].components(separatedBy: "\n").filter({ !$0.isEmpty })
        let messages = components[1].components(separatedBy: "\n").filter({ !$0.isEmpty })

        return (rules, messages)
    }
}
