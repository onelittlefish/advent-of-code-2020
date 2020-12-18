//
//  Day2.swift
//  AdventOfCode2020
//

import Foundation

private struct PasswordPolicy {
    let character: Character
    let position1: Int
    let position2: Int
}

private struct PasswordEntry {
    let policy: PasswordPolicy
    let password: String

    func isPasswordValidForPart1() -> Bool {
        return (policy.position1...policy.position2).contains(password.filter({ $0 == policy.character }).count)
    }

    func isPasswordValidForPart2() -> Bool {
        if characterIn(password, atIndex: policy.position1 - 1) == policy.character {
            return characterIn(password, atIndex: policy.position2 - 1) != policy.character
        } else {
            return characterIn(password, atIndex: policy.position2 - 1) == policy.character
        }
    }

    private func characterIn(_ string: String, atIndex index: Int) -> Character? {
        return string[safe: string.index(string.startIndex, offsetBy: index)]
    }
}

struct Day2 {
    static func part1(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)
        let numberOfValidPasswords = input.filter({ $0.isPasswordValidForPart1() }).count
        print("\(numberOfValidPasswords) valid")
    }

    static func part2(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)
        let numberOfValidPasswords = input.filter({ $0.isPasswordValidForPart2() }).count
        print("\(numberOfValidPasswords) valid")
    }

    private static func getInput(pathToInput: String) -> [PasswordEntry] {
        guard let contents = try? String(contentsOf: URL(fileURLWithPath: pathToInput)) else { print("Unable to open input"); exit(2) }
        // Parse password and password policy
        let pattern = #"([0-9]+)-([0-9]+) ([A-Za-z]): ([A-Za-z]+)"# // Example: 1-3 a: abcde
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        return contents.split(separator: "\n").compactMap({ line in
            let line = String(line)
            if let match = regex?.firstMatch(in: line, options: [], range: NSRange(line.startIndex..<line.endIndex, in: line)) {
                if let range1 = Range(match.range(at: 1), in: line),
                   let range2 = Range(match.range(at: 2), in: line),
                   let range3 = Range(match.range(at: 3), in: line),
                   let range4 = Range(match.range(at: 4), in: line),
                   let position1 = Int(line[range1]),
                   let position2 = Int(line[range2]),
                   let policyCharacter = line[range3].first {
                    let password = line[range4]
                    return PasswordEntry(policy: PasswordPolicy(character: policyCharacter, position1: position1, position2: position2), password: String(password))
                } else {
                    print("Error initializing password entry for \(line)")
                    return nil
                }
            } else {
                print("Regex did not match \(line)")
                return nil
            }
        })
    }
}
