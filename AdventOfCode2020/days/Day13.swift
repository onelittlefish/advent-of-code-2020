//
//  Day13.swift
//  AdventOfCode2020
//

import Foundation

struct Day13 {
    static func part1(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)

        let nextDepartureOnOrAfterEarliest = input.buses.map({ interval -> (bus: Int, nextDeparture: Int) in
            let multiplierForNextDeparture = (Float(input.earliestDeparture) / Float(interval.bus)).rounded(.up)
            return (bus: interval.bus, nextDeparture: Int(multiplierForNextDeparture) * interval.bus)
        })

        guard let earliestBus = nextDepartureOnOrAfterEarliest.min(by: { left, right in
            return left.nextDeparture - input.earliestDeparture < right.nextDeparture - input.earliestDeparture
        }) else { return }

        let result = earliestBus.bus * (earliestBus.nextDeparture - input.earliestDeparture)
        print(result)
    }

    static func part2(pathToInput: String) {
        /*
         Explanation: https://www.reddit.com/r/adventofcode/comments/kc60ri/2020_day_13_can_anyone_give_me_a_hint_for_part_2/gfnnfm3

         Can't say I completely understand the math theory, but the idea is to search in multiples of
         the first number until a number is found that satisfies the first two requirements.
         Then multiply the search interval by the second number and search with the increased interval
         until a number is found that satisfies the first three requirements.

         Repeat with all the numbers in the input: for the nth number in the input,
         multiply the current search interval by the (n-1)th input and search for the next
         number that satisfies numbers 1 through n.
         */
        let input = getInput(pathToInput: pathToInput)

        var buses = input.buses

        let first = buses.removeFirst()
        var busesToTest: [(bus: Int, offset: Int)] = []
        busesToTest.append(first)
        var currentNumber = first.bus
        var searchInterval = 1

        let isNumberValid: (Int) -> Bool = { number in
            return busesToTest.allSatisfy({ busToTest in
                (number + busToTest.offset) % busToTest.bus == 0
            })
        }
        let nextValidNumber: (Int, Int) -> Int = { currentNumber, searchInterval in
            var currentNumber = currentNumber
            while !isNumberValid(currentNumber) {
                currentNumber += searchInterval
            }
            return currentNumber
        }

        while !buses.isEmpty {
            currentNumber = nextValidNumber(currentNumber, searchInterval)
            let first = buses.removeFirst()
            searchInterval *= busesToTest.last!.bus
            busesToTest.append(first)
        }
        currentNumber = nextValidNumber(currentNumber, searchInterval)
        print(currentNumber)
    }

    private static func getInput(pathToInput: String) -> (earliestDeparture: Int, buses: [(bus: Int, offset: Int)]) {
        guard let contents = try? String(contentsOf: URL(fileURLWithPath: pathToInput)) else { print("Unable to open input"); exit(2) }
        let lines = contents.components(separatedBy: "\n")
        let earliestDeparture = Int(lines[0])!
        let buses = lines[1].components(separatedBy: ",").enumerated().compactMap({ index, value -> (bus: Int, offset: Int)? in
            guard let value = Int(value) else { return nil }
            return (value, index)
        })
        return (earliestDeparture, buses)
    }
}
