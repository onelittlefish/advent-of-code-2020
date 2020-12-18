//
//  Day24.swift
//  AdventOfCode2020
//

import Foundation

private enum Direction: String, CaseIterable {
    case east = "e"
    case southeast = "se"
    case southwest = "sw"
    case west = "w"
    case northwest = "nw"
    case northeast = "ne"
}

private struct Coordinates: Hashable {
    let x: Int
    let y: Int

    /**
     - returns: The coordinates after following the directions from this coordinate
     */
    func getCoordinates(directions: [Direction]) -> Coordinates {
        return directions.reduce(self, { result, direction in
            return result.getNeighbor(direction: direction)
        })
    }

    /**
     - returns: The 6 neighbors adjacent to this coordinates
     */
    func getNeighbors() -> [Coordinates] {
        return Direction.allCases.map({ getNeighbor(direction: $0) })
    }

    /**
     - returns: The coordinates of the neighbor in the direction adjacent to this coordinate
     */
    private func getNeighbor(direction: Direction) -> Coordinates {
        /*
         Since a hex grid doesn't exactly line up, even and odd rows will be horizontally offset.

         1:    1   2   3   4
         2:  1   2   3   4
         3:    1   2   3   4
         4:  1   2   3   4

         For example, southwest of row 1, column 2 is row 2, column 3
         and soutwest of row 2, column 2 is row 3, column 2.
         */
        switch direction {
        case .east:
            return Coordinates(x: x + 1, y: y)
        case .southeast:
            return Coordinates(x: y % 2 == 0 ? x : x + 1, y: y + 1)
        case .southwest:
            return Coordinates(x: y % 2 == 0 ? x - 1 : x, y: y + 1)
        case .west:
            return Coordinates(x: x - 1, y: y)
        case .northwest:
            return Coordinates(x: y % 2 == 0 ? x - 1 : x, y: y - 1)
        case .northeast:
            return Coordinates(x: y % 2 == 0 ? x : x + 1, y: y - 1)
        }
    }
}

struct Day24 {
    static func part1(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)
        let blackTiles = getInitialBlackTiles(input: input)
        print(blackTiles.count)
    }

    static func part2(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)
        let initialBlackTiles = getInitialBlackTiles(input: input)
        let result = simulate(days: 100, initialBlackTiles: initialBlackTiles)
        print(result.count)
    }

    /**
     - parameters:
        - input: A list of lists of Directions. Each inner list of Directions identifies one tile from the reference tile.
     - returns: The black tiles after flipping each tile identified by the directions from the reference tile
     */
    private static func getInitialBlackTiles(input: [[Direction]]) -> Set<Coordinates> {
        let referenceTile = Coordinates(x: 0, y: 0)
        var blackTiles = Set<Coordinates>()

        input.forEach({ directions in
            let tileToFlip = referenceTile.getCoordinates(directions: directions)
            if blackTiles.contains(tileToFlip) {
                blackTiles.remove(tileToFlip)
            } else {
                blackTiles.insert(tileToFlip)
            }
        })

        return blackTiles
    }

    private static func simulate(days: Int, initialBlackTiles: Set<Coordinates>) -> Set<Coordinates> {
        return (1...days).reduce(initialBlackTiles, { result, _ in
            simulate(initialBlackTiles: result)
        })
    }

    private static func simulate(initialBlackTiles: Set<Coordinates>) -> Set<Coordinates> {
        var newBlackTiles: [Coordinates] = []

        // Any black tile with zero or more than 2 black tiles immediately adjacent to it is flipped to white
        // i.e., any black tile with 1 or 2 black tiles stays black
        initialBlackTiles.forEach({ tile in
            let adjacentBlackTiles = tile.getNeighbors().filter({ initialBlackTiles.contains($0) })
            if adjacentBlackTiles.count == 1 || adjacentBlackTiles.count == 2 {
                newBlackTiles.append(tile)
            }
        })

        // Any white tile with exactly 2 black tiles immediately adjacent to it is flipped to black
        // Identify the white tiles adjacent to the black tiles and track the number of adjacent black tiles
        var whiteTilesAdjacentToBlackTiles: [Coordinates: Int] = [:]
        initialBlackTiles.forEach({ tile in
            let adjacentWhiteTiles = tile.getNeighbors().filter({ !initialBlackTiles.contains($0) })
            adjacentWhiteTiles.forEach({ whiteTile in
                whiteTilesAdjacentToBlackTiles[whiteTile, default: 0] += 1
            })
        })
        // Flip white tiles with 2 adjacent black tiles
        whiteTilesAdjacentToBlackTiles.filter({ $0.value == 2 }).forEach({ coordinates, _ in
            newBlackTiles.append(coordinates)
        })

        return Set(newBlackTiles)
    }

    private static func getInput(pathToInput: String) -> [[Direction]] {
        guard let contents = try? String(contentsOf: URL(fileURLWithPath: pathToInput)) else { print("Unable to open input"); exit(2) }

        return contents.components(separatedBy: "\n").compactMap({ line in
            var directions: [Direction] = []
            var skipNext = false

            line.enumerated().forEach({ index, character in
                guard !skipNext else {
                    skipNext = false
                    return
                }

                // If next two characters form a direction, append that direction and skip the next character
                let index = line.index(line.startIndex, offsetBy: index)
                if line.index(after: index) < line.endIndex {
                    let twoCharacterString = line[index...line.index(after: index)]
                    if let twoCharacterDirection = Direction(rawValue: String(twoCharacterString)) {
                        directions.append(twoCharacterDirection)
                        skipNext = true
                        return
                    }
                }

                // Else try to form a direction from the current character by itself
                if let direction = Direction(rawValue: String(character)) {
                    directions.append(direction)
                }
            })

            return directions.isEmpty ? nil : directions
        })
    }
}
