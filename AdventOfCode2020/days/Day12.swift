//
//  Day12.swift
//  AdventOfCode2020
//

import Foundation

private enum Action: Character {
    case north = "N"
    case south = "S"
    case east = "E"
    case west = "W"
    case left = "L"
    case right = "R"
    case forward = "F"
}

private struct Instruction {
    let action: Action
    let value: Int
}

private enum Direction: Int {
    case north = 0
    case south = 180
    case east = 90
    case west = 270

    /**
     - parameters:
        - degrees: Positive = clockwise, negative = counter-clockwise. Only degrees divisible by 90 will return a non-nil result.
     */
    func rotate(degrees: Int) -> Direction? {
        let positiveDegrees = degrees < 0 ? 360 - abs(degrees) : degrees
        return Direction(rawValue: (rawValue + positiveDegrees) % 360)
    }
}

private struct Coordinates {
    let x: Int
    let y: Int

    func move(direction: Direction, amount: Int) -> Coordinates {
        switch direction {
        case .north:
            return Coordinates(x: x, y: y + amount)
        case .south:
            return Coordinates(x: x, y: y - amount)
        case .east:
            return Coordinates(x: x + amount, y: y)
        case .west:
            return Coordinates(x: x - amount, y: y)
        }
    }

    func rotate(degrees: Int) -> Coordinates? {
        let positiveDegrees = degrees < 0 ? 360 - abs(degrees) : degrees
        switch positiveDegrees {
        case 90:
            return Coordinates(x: y, y: -x)
        case 180:
            return Coordinates(x: -x, y: -y)
        case 270:
            return Coordinates(x: -y, y: x)
        default:
            return nil
        }
    }
}

struct Day12 {
    static func part1(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)
        var coordinates = Coordinates(x: 0, y: 0)
        var orientation = Direction.east
        input.forEach({ instruction in
            switch instruction.action {
            case .north:
                coordinates = coordinates.move(direction: .north, amount: instruction.value)
            case .south:
                coordinates = coordinates.move(direction: .south, amount: instruction.value)
            case .east:
                coordinates = coordinates.move(direction: .east, amount: instruction.value)
            case .west:
                coordinates = coordinates.move(direction: .west, amount: instruction.value)
            case .left:
                orientation = orientation.rotate(degrees: -instruction.value)!
            case .right:
                orientation = orientation.rotate(degrees: instruction.value)!
            case .forward:
                switch orientation {
                case .north:
                    coordinates = coordinates.move(direction: .north, amount: instruction.value)
                case .south:
                    coordinates = coordinates.move(direction: .south, amount: instruction.value)
                case .east:
                    coordinates = coordinates.move(direction: .east, amount: instruction.value)
                case .west:
                    coordinates = coordinates.move(direction: .west, amount: instruction.value)
                }
            }
        })
        let manhattanDistance = abs(coordinates.x) + abs(coordinates.y)
        print("Final coordinates: \(coordinates.x), \(coordinates.y); Manhattan distance: \(manhattanDistance)")
    }

    static func part2(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)
        var shipCoordinates = Coordinates(x: 0, y: 0)
        var waypointCoordinates = Coordinates(x: 10, y: 1)
        input.forEach({ instruction in
            switch instruction.action {
            case .north:
                waypointCoordinates = waypointCoordinates.move(direction: .north, amount: instruction.value)
            case .south:
                waypointCoordinates = waypointCoordinates.move(direction: .south, amount: instruction.value)
            case .east:
                waypointCoordinates = waypointCoordinates.move(direction: .east, amount: instruction.value)
            case .west:
                waypointCoordinates = waypointCoordinates.move(direction: .west, amount: instruction.value)
            case .left:
                waypointCoordinates = waypointCoordinates.rotate(degrees: -instruction.value)!
            case .right:
                waypointCoordinates = waypointCoordinates.rotate(degrees: instruction.value)!
            case .forward:
                shipCoordinates = Coordinates(x: shipCoordinates.x + instruction.value * waypointCoordinates.x, y: shipCoordinates.y + instruction.value * waypointCoordinates.y)
            }
        })
        let manhattanDistance = abs(shipCoordinates.x) + abs(shipCoordinates.y)
        print("Final coordinates: \(shipCoordinates.x), \(shipCoordinates.y); Manhattan distance: \(manhattanDistance)")
    }

    private static func getInput(pathToInput: String) -> [Instruction] {
        guard let contents = try? String(contentsOf: URL(fileURLWithPath: pathToInput)) else { print("Unable to open input"); exit(2) }
        return contents.components(separatedBy: "\n").compactMap({ line in
            guard !line.isEmpty else { return nil }
            let action = Action(rawValue: line.first!)!
            let value = Int(line[line.index(line.startIndex, offsetBy: 1)...])!
            return Instruction(action: action, value: value)
        })
    }
}
