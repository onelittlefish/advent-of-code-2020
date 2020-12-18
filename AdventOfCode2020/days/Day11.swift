//
//  Day11.swift
//  AdventOfCode2020
//

import Foundation

private enum WaitingRoomSpace {
    case floor, emptySeat, occupiedSeat
}

struct Day11 {
    static func part1(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)
        var previousLayout = input
        var nextLayout = applyPart1Rules(previousLayout)
        while nextLayout != previousLayout {
            previousLayout = nextLayout
            nextLayout = applyPart1Rules(previousLayout)
        }
        let occupiedSeats = sum(previousLayout, where: { $0 == .occupiedSeat })
        print("\(occupiedSeats) occupied seats (part 1 rules)")
    }

    static func part2(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)
        var previousLayout = input
        var nextLayout = applyPart2Rules(previousLayout)
        while nextLayout != previousLayout {
            previousLayout = nextLayout
            nextLayout = applyPart2Rules(previousLayout)
        }
        let occupiedSeats = sum(previousLayout, where: { $0 == .occupiedSeat })
        print("\(occupiedSeats) occupied seats (part 2 rules)")
    }

    private static func sum(_ layout: [[WaitingRoomSpace]], where predicate: (WaitingRoomSpace) -> Bool) -> Int {
        return layout.reduce(0, { $0 + $1.reduce(0, { $0 + (predicate($1) ? 1 : 0) }) })
    }

    private static func applyPart1Rules(_ layout: [[WaitingRoomSpace]]) -> [[WaitingRoomSpace]] {
        return layout.enumerated().map({ rowIndex, row in
            return row.enumerated().map({ columnIndex, column -> WaitingRoomSpace in
                switch column {
                case .floor:
                    return .floor
                case .emptySeat:
                    if getAdjacentSpaces(in: layout, row: rowIndex, column: columnIndex).filter({ $0 == .occupiedSeat }).isEmpty { // No occupied seats
                        return .occupiedSeat
                    } else {
                        return .emptySeat
                    }
                case .occupiedSeat:
                    if getAdjacentSpaces(in: layout, row: rowIndex, column: columnIndex).filter({ $0 == .occupiedSeat }).count >= 4 { // 4+ occupied seats
                        return .emptySeat
                    } else {
                        return .occupiedSeat
                    }
                }
            })
        })
    }

    private static func applyPart2Rules(_ layout: [[WaitingRoomSpace]]) -> [[WaitingRoomSpace]] {
        return layout.enumerated().map({ rowIndex, row in
            return row.enumerated().map({ columnIndex, column -> WaitingRoomSpace in
                switch column {
                case .floor:
                    return .floor
                case .emptySeat:
                    if getVisibleAdjacentSpaces(in: layout, row: rowIndex, column: columnIndex).filter({ $0 == .occupiedSeat }).isEmpty { // No occupied seats
                        return .occupiedSeat
                    } else {
                        return .emptySeat
                    }
                case .occupiedSeat:
                    if getVisibleAdjacentSpaces(in: layout, row: rowIndex, column: columnIndex).filter({ $0 == .occupiedSeat }).count >= 5 { // 5+ occupied seats
                        return .emptySeat
                    } else {
                        return .occupiedSeat
                    }
                }
            })
        })
    }

    private static func getAdjacentSpaces(in layout: [[WaitingRoomSpace]], row: Int, column: Int) -> [WaitingRoomSpace] {
        let adjacentCoordinates = [
            (row - 1, column - 1),
            (row - 1, column),
            (row - 1, column + 1),
            (row, column - 1),
            (row, column + 1),
            (row + 1, column - 1),
            (row + 1, column),
            (row + 1, column + 1)
        ]
        return adjacentCoordinates.compactMap({ (row, column) in
            return layout[safe: row]?[safe: column]
        })
    }

    private static func getVisibleAdjacentSpaces(in layout: [[WaitingRoomSpace]], row: Int, column: Int) -> [WaitingRoomSpace] {
        let adjacentCoordinates = [
            (-1, -1),
            (-1, 0),
            (-1, 1),
            (0, -1),
            (0, 1),
            (1, -1),
            (1, 0),
            (1, 1)
        ]
        return adjacentCoordinates.compactMap({ (rowDelta, columnDelta) in
            var currentRow = row + rowDelta
            var currentColumn = column + columnDelta
            var space = layout[safe: currentRow]?[safe: currentColumn]

            while let nnSpace = space, nnSpace == .floor {
                currentRow += rowDelta
                currentColumn += columnDelta
                space = layout[safe: currentRow]?[safe: currentColumn]
            }
            return space
        })
    }

    private static func getInput(pathToInput: String) -> [[WaitingRoomSpace]] {
        guard let contents = try? String(contentsOf: URL(fileURLWithPath: pathToInput)) else { print("Unable to open input"); exit(2) }
        return contents.components(separatedBy: "\n").map({ line in
            return line.map({ character -> WaitingRoomSpace in
                switch character {
                case ".": return .floor
                case "L": return .emptySeat
                default: fatalError("Invalid input character: \(character)")
                }
            })
        })
    }
}
