 //
//  Day25.swift
//  AdventOfCode2020
//

import Foundation

 struct Day25 {
    static func part1(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)

        let publicKeyToUseForLoopSize = input.0 < input.1 ? input.0 : input.1
        let publicKeyToUseForEncryptionKey = publicKeyToUseForLoopSize == input.0 ? input.1 : input.0

        let loopSize = getLoopSize(publicKey: publicKeyToUseForLoopSize)
        let encryptionKey = getEncryptionKey(publicKey: publicKeyToUseForEncryptionKey, loopSize: loopSize)

        print(encryptionKey)
    }

    private static func getLoopSize(publicKey: Int) -> Int {
        var value = 1
        var loopSize = 0

        repeat {
            value = transform(value: value, subjectNumber: 7)
            loopSize += 1
        } while value != publicKey

        return loopSize
    }

    private static func getEncryptionKey(publicKey: Int, loopSize: Int) -> Int {
        return transform(value: 1, subjectNumber: publicKey, loopSize: loopSize)
    }

    private static func transform(value: Int, subjectNumber: Int, loopSize: Int) -> Int {
        return (1...loopSize).reduce(value, { result, _ in
            return transform(value: result, subjectNumber: subjectNumber)
        })
    }

    private static func transform(value: Int, subjectNumber: Int) -> Int {
        let divisor = 20201227
        return (value * subjectNumber) % divisor
    }

    static func part2(pathToInput: String) {}

    private static func getInput(pathToInput: String) -> (Int, Int) {
        guard let contents = try? String(contentsOf: URL(fileURLWithPath: pathToInput)) else { print("Unable to open input"); exit(2) }
        let publicKeys = contents.components(separatedBy: "\n").compactMap({ Int($0) })
        guard publicKeys.count == 2 else { print("Input should contain two numbers"); exit(2) }
        return (publicKeys[0], publicKeys[1])
    }
 }

