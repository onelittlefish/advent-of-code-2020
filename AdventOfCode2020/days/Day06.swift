//
//  Day6.swift
//  AdventOfCode2020
//

import Foundation

struct Day6 {
    static func part1(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)
        let uniqueAnswersPerGroup = input.map({ group -> Set<Character> in
            var uniqueAnswers = Set<Character>([])
            group.forEach({ $0.forEach({ uniqueAnswers.insert($0) }) })
            return uniqueAnswers
        })
        let sum = uniqueAnswersPerGroup.reduce(into: 0, { $0 += $1.count })
        print("Sum of answers where anyone in group said yes: \(sum)")
    }

    static func part2(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)
        let unaninmousAnswersPerGroup = input.map({ group -> [Character] in
            // Map characters to number of times someone in the group answered yes
            var answersPerCharacter: [Character: Int] = [:]
            group.forEach({ answers in
                answers.forEach({ character in
                    answersPerCharacter[character] = (answersPerCharacter[character] ?? 0) + 1
                })
            })
            // Unaninmous answers will have been answered by everyone in the group
            let unaninmousAnswers = answersPerCharacter.filter({ _, numberOfAnswers in
                numberOfAnswers == group.count
            })
            return Array(unaninmousAnswers.keys)
        })
        let sum = unaninmousAnswersPerGroup.reduce(into: 0, { $0 += $1.count })
        print("Sum of answers where everyone in group said yes: \(sum)")
    }

    private static func getInput(pathToInput: String) -> [[String]] {
        guard let contents = try? String(contentsOf: URL(fileURLWithPath: pathToInput)) else { print("Unable to open input"); exit(2) }
        return contents.components(separatedBy: "\n\n").compactMap({ group in
            let group = String(group)
            let answers = group.components(separatedBy: "\n").filter({ !String($0).isEmpty })
            return answers
        })
    }
}
