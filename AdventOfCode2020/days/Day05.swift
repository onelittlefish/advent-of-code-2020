//
//  Day5.swift
//  AdventOfCode2020
//

import Foundation

private enum SeatPartition {
    case lower, upper
}

private struct BoardingPass {
    let rowPositions: [SeatPartition]
    let columnPositions: [SeatPartition]

    /// Example input: `FBFBBFFRLR`
    init(seat: String) {
        rowPositions = seat[safe: seat.startIndex..<seat.index(seat.startIndex, offsetBy: 7)]?.compactMap({ character in
            switch character {
            case "F": return .lower
            case "B": return .upper
            default: return nil
            }
        }) ?? []
        columnPositions = seat[safe: seat.index(seat.startIndex, offsetBy: 7)...]?.compactMap({ character in
            switch character {
            case "L": return .lower
            case "R": return .upper
            default: return nil
            }
        }) ?? []
    }

    func getSeatID() -> Int {
        let row = getPosition(rowPositions, maxSection: 127)
        let column = getPosition(columnPositions, maxSection: 7)
        return row * 8 + column
    }

    private func getPosition(_ partitions: [SeatPartition], maxSection: Int) -> Int {
        var currentRange = (0...maxSection)
        for partition in partitions {
            switch partition {
            case .lower:
                currentRange = (currentRange.lowerBound...currentRange.lowerBound + currentRange.count/2)
            case .upper:
                currentRange = (currentRange.lowerBound + currentRange.count/2...currentRange.upperBound)
            }
        }
        return currentRange.lowerBound
    }
}

struct Day5 {
    static func part1(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)
        let maxSeatID = input.map({ $0.getSeatID() }).max()
        print("Max Seat ID: \(maxSeatID ??? "nil")")
    }

    static func part2(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)
        let seatIDs = input.map({ $0.getSeatID() }).sorted()
        guard let startingSeatID = seatIDs.first else { return }
        for (index, seatID) in seatIDs.enumerated() {
            let expectedSeatID = startingSeatID + index
            if seatID != expectedSeatID {
                print("Missing Seat ID: \(expectedSeatID)")
                break
            }
        }
    }

    private static func getInput(pathToInput: String) -> [BoardingPass] {
        guard let contents = try? String(contentsOf: URL(fileURLWithPath: pathToInput)) else { print("Unable to open input"); exit(2) }
        return contents.split(separator: "\n").map({ line in
            return BoardingPass(seat: String(line))
        })
    }
}
