//
//  Day16.swift
//  AdventOfCode2020
//

import Foundation

private struct Rule: Hashable {
    let name: String
    let ranges: [ClosedRange<Int>]

    func isValidValue(_ value: Int) -> Bool {
        return ranges.contains(where: { $0.contains(value) })
    }
}

private struct Ticket {
    let values: [Int]
}

struct Day16 {
    static func part1(pathToInput: String) {
        guard let input = getInput(pathToInput: pathToInput) else { return }

        let invalidValues = input.nearbyTickets.map({ ticket -> [Int] in
            return ticket.values.filter({ value in
                // Value is invalid if it is not valid for any rule
                return input.rules.allSatisfy({ rule in
                    return !rule.isValidValue(value)
                })
            })
        }).flatMap({ $0 })

        let sum = invalidValues.reduce(0, +)
        print(sum)
    }

    static func part2(pathToInput: String) {
        guard let input = getInput(pathToInput: pathToInput) else { return }

        // Ignore invalid tickets
        let validTickets = input.nearbyTickets.filter({ ticket in
            // All of the ticket's values are valid for at least one rule
            return ticket.values.allSatisfy({ value in
                return input.rules.contains(where: { rule in
                    return rule.isValidValue(value)
                })
            })
        })

        // Determine which rules go with each index in the ticket
        var possibleRulesPerIndex: [Int: Set<Rule>] = [:]
        var lockedInRuleIndices: [Rule: Int] = [:]

        validTickets.forEach({ ticket in
            ticket.values.enumerated().forEach({ (index, value) in
                let possibleRulesForValue = Set(input.rules.filter({ rule in
                    // One of the rule's ranges contains the value and the rule isn't already locked into a different index
                    return rule.isValidValue(value) && (lockedInRuleIndices[rule] == nil || lockedInRuleIndices[rule] == index)
                }))

                let updatedRulesForIndex = possibleRulesPerIndex[index, default: possibleRulesForValue].intersection(possibleRulesForValue)
                possibleRulesPerIndex[index] = updatedRulesForIndex

                if let ruleForIndex = updatedRulesForIndex.first, updatedRulesForIndex.count == 1 {
                    // This index has only one possible rule, so it's locked in and none of the other indices can have this rule
                    var lockedInRules = [ruleForIndex]
                    lockedInRuleIndices[ruleForIndex] = index

                    while !lockedInRules.isEmpty {
                        let lockedInRule = lockedInRules.removeLast()

                        // Remove the locked-in rule from the possible rules for all other indices
                        possibleRulesPerIndex.forEach({ index, rules in
                            if index == lockedInRuleIndices[lockedInRule] { return }

                            let updatedRulesForIndex = rules.subtracting([lockedInRule])
                            possibleRulesPerIndex[index] = updatedRulesForIndex

                            // If removing the locked-in rule results in this index dropping to one possible rule,
                            // repeat the locking in process with this index and its remaining rule
                            if let ruleForIndex = updatedRulesForIndex.first, rules.count > 1 && updatedRulesForIndex.count == 1 {
                                lockedInRules.append(ruleForIndex)
                                lockedInRuleIndices[ruleForIndex] = index
                            }
                        })
                    }
                }
            })
        })

        possibleRulesPerIndex.forEach({ print("\t\($0): \($1.map({ $0.name }))") })

        // Calculate result based on departure rules for your ticket
        let departureRules = input.rules.filter({ $0.name.hasPrefix("departure") })
        let departureValuesForYourTicket = departureRules.map({ rule -> Int in
            let index = possibleRulesPerIndex.first(where: { $1.contains(rule) })!
            return input.yourTicket.values[index.key]
        })
        print("Departure values: \(departureValuesForYourTicket)")
        let product = departureValuesForYourTicket.reduce(1, *)
        print(product)
    }
    
    private static func getInput(pathToInput: String) -> (rules: [Rule], yourTicket: Ticket, nearbyTickets: [Ticket])? {
        guard let contents = try? String(contentsOf: URL(fileURLWithPath: pathToInput)) else { print("Unable to open input"); exit(2) }

        let pattern = #"(.*)\s+your ticket:\s+([0-9,]+)\s+nearby tickets:\s+(.*)\s+"# // Split into rules, your ticket, and nearby tickets
        let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])

        guard let match = regex?.firstMatch(in: contents, options: [], range: NSRange(contents.startIndex..<contents.endIndex, in: contents)),
              let range1 = Range(match.range(at: 1), in: contents),
              let range2 = Range(match.range(at: 2), in: contents),
              let range3 = Range(match.range(at: 3), in: contents)
        else { return nil }

        let rulesString = contents[range1]
        let yourTicketString = contents[range2]
        let nearbyTicketsString = contents[range3]

        let rulePattern = #"([A-Za-z ]+): ([0-9]+)-([0-9]+) or ([0-9]+)-([0-9]+)"# // e.g. departure location: 44-709 or 728-964
        let ruleRegex = try? NSRegularExpression(pattern: rulePattern, options: [])
        let rules = rulesString.components(separatedBy: "\n").compactMap({ line -> Rule? in
            guard let match = ruleRegex?.firstMatch(in: line, options: [], range: NSRange(line.startIndex..<line.endIndex, in: line)),
                  let range1 = Range(match.range(at: 1), in: line),
                  let range2 = Range(match.range(at: 2), in: line),
                  let range3 = Range(match.range(at: 3), in: line),
                  let range4 = Range(match.range(at: 4), in: line),
                  let range5 = Range(match.range(at: 5), in: line),
                  let ruleRange1Lower = Int(line[range2]),
                  let ruleRange1Upper = Int(line[range3]),
                  let ruleRange2Lower = Int(line[range4]),
                  let ruleRange2Upper = Int(line[range5])
            else { return nil }

            return Rule(name: String(line[range1]), ranges: [(ruleRange1Lower...ruleRange1Upper), (ruleRange2Lower...ruleRange2Upper)])
        })

        let yourTicket = Ticket(values: yourTicketString.components(separatedBy: ",").compactMap({ Int($0.trimmingCharacters(in: .whitespaces)) }))

        let nearbyTickets = nearbyTicketsString.components(separatedBy: "\n").compactMap({ line -> Ticket? in
            let values = line.components(separatedBy: ",").compactMap({ Int($0.trimmingCharacters(in: .whitespaces)) })
            if !values.isEmpty {
                return Ticket(values: values)
            } else {
                return nil
            }
        })

        return (rules, yourTicket, nearbyTickets)
    }
}
