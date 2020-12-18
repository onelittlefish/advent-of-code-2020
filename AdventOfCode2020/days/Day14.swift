//
//  Day14.swift
//  AdventOfCode2020
//

import Foundation

private enum Operation {
    case mask(mask: String)
    case write(address: Int, value: Int)
}

struct Day14 {
    static func part1(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)

        var currentMask: String!
        var memory: [Int: Int] = [:]

        input.forEach({ operation in
            switch operation {
            case .mask(let mask):
                currentMask = mask
            case .write(let address, let value):
                memory[address] = applyPart1(mask: currentMask, to: value)
            }
        })

        let sum = memory.values.reduce(0, +)
        print(sum)
    }

    static func part2(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)

        var currentMask: String!
        var memory: [Int: Int] = [:]

        input.forEach({ operation in
            switch operation {
            case .mask(let mask):
                currentMask = mask
            case .write(let address, let value):
                let addresses = applyPart2(mask: currentMask, to: address)
                addresses.forEach({ address in
                    memory[address] = value
                })
            }
        })

        let sum = memory.values.reduce(0, +)
        print(sum)
    }

    private static func applyPart1(mask: String, to value: Int) -> Int {
        var bits = self.intToBits(UInt64(value))
        mask.enumerated().forEach({ (maskIndex, maskBit) in
            if maskBit == "0" {
                bits[(64 - mask.count) + maskIndex] = 0
            } else if maskBit == "1" {
                bits[(64 - mask.count) + maskIndex] = 1
            }
        })
        return bitsToInt(bits)
    }

    private static func applyPart2(mask: String, to value: Int) -> [Int] {
        let bits = self.intToBits(UInt64(value))

        let results = applyPart2(mask: mask, toBits: Array(bits.dropFirst(bits.count - mask.count)))

        return results.map({ resultBits in
            return bitsToInt(resultBits)
        })
    }

    private static func applyPart2(mask: String, toBits bits: [Int]) -> [[Int]] {
        guard mask.count == bits.count else { fatalError("Mask and bits should have same number of elements") }

        if mask.count == 1 {
            // Base case: return [0, 1] for "X", [1] for "!", and bit for "0"
            return applyPart2(mask: mask.last!, toBit: bits.last!).map({ [$0] })
        } else {
            // Calculate options for first bit, then add to rest of bits
            // e.g. if there are two bits and the mask is "XX",
            // the first bit can be [0, 1] and the second bit can be [0, 1],
            // so the result is [[0, 0], [1, 0], [1, ]0, [1, 1]]
            let optionsForFirstBit = applyPart2(mask: mask.first!, toBit: bits.first!)
            let optionsForRestOfBits = applyPart2(mask: String(mask[mask.index(mask.startIndex, offsetBy: 1)...]), toBits: Array(bits[(bits.startIndex + 1)...]))

            return optionsForRestOfBits.map({ option -> [[Int]] in
                return optionsForFirstBit.map({ firstBit in
                    [firstBit] + option
                })
            }).flatMap({ $0 })
        }
    }

    private static func applyPart2(mask: Character, toBit bit: Int) -> [Int] {
        switch mask {
        case "1":
            return [1]
        case "X":
            return [0, 1]
        default:
            return [bit]
        }
    }

    private static func intToBits(_ int: UInt64) -> [Int] {
        // https://stackoverflow.com/questions/44807378/swift-convert-uint8-byte-to-array-of-bits
        var target = int
        var bits = [Int](repeating: 0, count: 64)
        for i in 0..<64 {
            let currentBit = target & 0x01
            bits[i] = Int(currentBit)
            target >>= 1
        }

        return bits.reversed()
    }

    private static func bitsToInt(_ bits: [Int]) -> Int {
        let bitString = bits.reduce("", { "\($0)\($1)" })
        return Int(bitString, radix: 2)!
    }

    private static func getInput(pathToInput: String) -> [Operation] {
        guard let contents = try? String(contentsOf: URL(fileURLWithPath: pathToInput)) else { print("Unable to open input"); exit(2) }

        let memPattern = #"mem\[([0-9]+)\]"# // e.g. mem[8]
        let regex = try? NSRegularExpression(pattern: memPattern, options: [])

        return contents.components(separatedBy: "\n").compactMap({ line in
            let components = line.components(separatedBy: " = ")
            if components[0] == "mask" {
                return .mask(mask: components[1])
            } else if
                let match = regex?.firstMatch(in: components[0], options: [], range: NSRange(components[0].startIndex..<components[0].endIndex, in: components[0])),
                let range1 = Range(match.range(at: 1), in: components[0]),
                let memAddress = Int(components[0][range1]),
                let memValue = Int(components[1]) {
                return .write(address: memAddress, value: memValue)
            } else {
                return nil
            }
        })
    }
}
