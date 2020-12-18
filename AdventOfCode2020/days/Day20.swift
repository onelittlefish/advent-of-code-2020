//
//  Day20.swift
//  AdventOfCode2020
//

import Foundation

private struct Coordinates: Hashable {
    let row: Int
    let column: Int
}

private struct Border: Hashable {
    let hashes: [Int]
    let size: Int

    init(hashes: [Int], size: Int) {
        self.hashes = hashes
        self.size = size
    }

    init(string: String) {
        hashes = string.enumerated().compactMap({ $0.element == "#" ? $0.offset : nil })
        size = string.count
    }

    func flipped() -> Border {
        // ..##.#..#. = 2, 3, 5, 8
        // .#..#.##.. = 1, 4, 6, 7
        let flipped = hashes.map({ (size - 1) - $0 }).sorted()
        return Border(hashes: flipped, size: size)
    }
}

private struct Tile: Hashable, CustomStringConvertible {
    let id: Int
    private(set) var contents: [String]

    var top: Border {
        return Border(string: contents.first!)
    }
    var bottom: Border {
        return Border(string: contents.last!)
    }
    var left: Border {
        let leftString = contents.reduce("", { $0.appending($1.first.flatMap({ String($0) }) ?? "") })
        return Border(string: leftString)
    }
    var right: Border {
        let rightString = contents.reduce("", { $0.appending($1.last.flatMap({ String($0) }) ?? "") })
        return Border(string: rightString)
    }

    init(id: Int, contents: [String]) {
        self.id = id
        self.contents = contents
    }

    init(string: String) {
        let lines = string.components(separatedBy: "\n")
        let id = Int(lines[0].dropFirst("Tile ".count).dropLast())!
        let contents = Array(lines[1...])
        self.init(id: id, contents: contents)
    }

    /// - returns: All possible borders including when the tile is rotated or flipped
    func getBorders() -> [Border] {
        return [top, top.flipped(), bottom, bottom.flipped(), left, left.flipped(), right, right.flipped()]
    }

    /// - returns: The tile that results from rotating this one 90 degrees clockwise
    func rotated() -> Tile {
        let newContents = (0..<contents[0].count).map({ column -> String in // Assuming each tile is a square
            let columnString = contents.reduce("", { result, row in
                let index = row.index(row.startIndex, offsetBy: column)
                return result.appending(row[index..<row.index(after: index)])
            })
            return String(columnString.reversed())
        })
        return Tile(id: id, contents: newContents)
    }

    /// - returns: The tile that results from flipping this one vertically
    func flipped() -> Tile {
        let newContents = Array(contents.reversed())
        return Tile(id: id, contents: newContents)
    }

    /// - returns: All possible results from rotating or flipping this tile, plus the identity transformation
    func getTransformations() -> [Tile] {
        let rotations = (1...3).map({ times -> Tile in
            let rotated = (1...times).reduce(self, { result, _ in
                return result.rotated()
            })
            return rotated
        })
        return [self, flipped()] + rotations + rotations.map({ $0.flipped() })
    }

    /// - returns: The tile that results from removing the borders from this one
    func removingBorders() -> Tile {
        let newContents = contents[1..<(contents.count - 1)].map({ row in
            return String(row.dropFirst().dropLast())
        })
        return Tile(id: id, contents: newContents)
    }

    func toString() -> String {
        var string = ""
        contents.forEach({ row in
            string.append("\(row)\n")
        })
        return string
    }

    var description: String {
        return "\(id)"
    }
}

struct Day20 {
    static func part1(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)
        let (neighbors, _, _) = calculateNeighbors(input: input)
        let corners = getCornerTiles(neighbors: neighbors)
        let product = corners.reduce(1, *)
        print(product)
    }

    static func part2(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)
        let (neighbors, sharedBordersForTile, tilesByID) = calculateNeighbors(input: input)

        let length = Int(sqrt(Double(input.count))) // Image is square
        let image = constructImage(neighbors: neighbors, sharedBordersForTile: sharedBordersForTile, tilesByID: tilesByID, length: length)
        let combinedImage = flattenImage(image, length: length)

        let numberOfSeaMonsters = findSeaMonsters(tile: combinedImage)
        let hashesPerSeaMonster = 15
        let hashesToRemove = numberOfSeaMonsters * hashesPerSeaMonster
        let totalHashes = combinedImage.contents.reduce(0, { $0 + $1.filter({ $0 == "#"}).count })
        let result = totalHashes - hashesToRemove
        print(result)
    }

    /**
     - returns:
        - neighbors: A mapping from each Tile's id to its neighbors
        - bordersForTIle: A mapping from each Tile's id to the borders it shares with its neighbors
        - tilesByID: A mapping from each Tile's id to the Tile itself
     */
    private static func calculateNeighbors(input: [Tile]) -> (neighbors: [Int: Set<Tile>], sharedBordersForTile: [Int: Set<Border>], tilesByID: [Int: Tile]) {
        var borders: [Border: Tile] = [:]
        var neighbors: [Int: Set<Tile>] = [:]
        var sharedBordersForTile: [Int: Set<Border>] = [:]
        var tilesByID: [Int: Tile] = [:]

        input.forEach({ tile in
            tilesByID[tile.id] = tile

            var tileBorders = Set(tile.getBorders())
            let borderMatches = tileBorders.filter({ borders[$0] != nil })
            borderMatches.forEach({ match in
                tileBorders.remove(match)
                let otherTile = borders.removeValue(forKey: match)!
                neighbors[tile.id, default: []].insert(otherTile)
                neighbors[otherTile.id, default: []].insert(tile)
                sharedBordersForTile[tile.id, default: []].insert(match)
                sharedBordersForTile[otherTile.id, default: []].insert(match)
            })

            tileBorders.forEach({ borders[$0] = tile })
        })

        return (neighbors, sharedBordersForTile, tilesByID)
    }

    private static func getCornerTiles(neighbors: [Int: Set<Tile>]) -> [Int] {
        return Array(neighbors.filter({ $0.value.count == 2 }).keys) // Corner tiles have only 2 neighbors
    }

    /**
     Uses neighbor and border information to stitch the tiles into an image composed of tiles at specified coordinates
     */
    private static func constructImage(neighbors: [Int: Set<Tile>], sharedBordersForTile: [Int: Set<Border>], tilesByID: [Int: Tile], length: Int) -> [Coordinates: Tile] {
        let corners = getCornerTiles(neighbors: neighbors)

        var image: [Coordinates: Tile] = [:]

        // Pick a corner tile and construct the image with that tile in the top left corner
        guard let corner = corners.first, let topLeft = tilesByID[corner] else { return [:] }

        // Transform the corner tile until its shared borders are the the right and bottom (i.e. it's in the top left)
        let transformedTopLeft = topLeft.getTransformations().first(where: { candidate -> Bool in
            guard let sharedBorders = sharedBordersForTile[candidate.id] else { return false }
            return sharedBorders.contains(candidate.right) && sharedBorders.contains(candidate.bottom)
        })!

        // Construct the image left to right, top to bottom
        var next: (tile: Tile, coordinates: Coordinates)? = (transformedTopLeft, Coordinates(row: 0, column: 0))

        while next != nil {
            guard let current = next else { break }

            next = nil

            image[current.coordinates] = current.tile

            if current.coordinates.column == length - 1 {
                // Reached the end of the row; find the first tile in next row
                if current.coordinates.row < length - 1 {
                    let firstTileInThisRow = image[Coordinates(row: current.coordinates.row, column: 0)]!

                    // The first tile in the next row shares a border with the bottom border of the first tile in this row
                    guard let neighbors = neighbors[firstTileInThisRow.id], let nextCandidate = neighbors.first(where: { neighbor in
                        return neighbor.getBorders().contains(firstTileInThisRow.bottom)
                    }) else { continue }

                    // Transform the next tile so that its top border is shared with the bottom border of the first tile in this row
                    let transformedNext = nextCandidate.getTransformations().first(where: { $0.top == firstTileInThisRow.bottom })!

                    next = (transformedNext, Coordinates(row: current.coordinates.row + 1, column: 0))
                }
            } else {
                // Find next tile in this row
                // The next tile in this row shares a border with the right border of the current tile
                guard let neighbors = neighbors[current.tile.id], let nextCandidate = neighbors.first(where: { neighbor in
                    return neighbor.getBorders().contains(current.tile.right)
                }) else { continue }

                // Transform the next tile so that its left border is shared with the right border of current tile
                let transformedNext = nextCandidate.getTransformations().first(where: { $0.left == current.tile.right })!

                next = (transformedNext, Coordinates(row: current.coordinates.row, column: current.coordinates.column + 1))
            }
        }

        return image
    }

    /**
     Flattens an image composed of tiles at specified coordinates into a single tile
     */
    private static func flattenImage(_ image: [Coordinates: Tile], length: Int) -> Tile {
        // An array of strings where each string is a row of the entire image
        let imageAsString = (0..<length).map({ tileRow -> [String] in
            // Get all the tiles in this tile row and remove their borders
            let tilesInRow = (0..<length).compactMap({ tileColumn in
                return image[Coordinates(row: tileRow, column: tileColumn)]
            }).map({ $0.removingBorders() })

            // Construct the individual image rows by combining the rows from each tile
            let imageRows = (0..<tilesInRow[0].contents.count).map({ tileRow -> String in
                let imageRow = tilesInRow.reduce("", { $0 + $1.contents[tileRow] })
                return imageRow
            })

            return imageRows
        }).flatMap({ $0 })

        return Tile(id: 1, contents: imageAsString)
    }

    private static func findSeaMonsters(tile: Tile) -> Int {
        let middleOfMonster = #"#....##....##....###"#
        let middleOfMonsterRegex = try? NSRegularExpression(pattern: middleOfMonster, options: [])

        // For each of the tile's transformations, calculate the number of monsters
        let numberOfMonstersPerTransformedTile = tile.getTransformations().map({ transformedTile -> Int in
            // For each of the transformed tile's rows, calculate the number of valid occurrences of a middle monster pattern (a row can have more than one monster)
            let numberOfMonsterMiddlesPerRow = transformedTile.contents.enumerated().map({ row -> Int in
                // The middle of the monster can't be in the first or last row
                guard row.offset > transformedTile.contents.startIndex && row.offset < transformedTile.contents.endIndex - 1 else { return 0 }

                // Look for the middle monster pattern, then verify that the previous and next rows match the top and bottom monster patterns
                if let middleOfMonsterMatches = middleOfMonsterRegex?.matches(in: row.element, options: [], range: NSRange(row.element.startIndex..<row.element.endIndex, in: row.element)) {
                    // Filter the middle matches to find full matches
                    let fullMonsterMatches = middleOfMonsterMatches.filter({ match in
                        let leftOffset = match.range.location
                        let rightOffset = row.element.count - match.range.length - leftOffset

                        let previousRow = transformedTile.contents[row.offset - 1]
                        let topOfMonster = ".{\(leftOffset)}.{18}#..{\(rightOffset)}"
                        let previousRowMatches = previousRow.range(of: topOfMonster, options: .regularExpression) == (previousRow.startIndex..<previousRow.endIndex)

                        let nextRow = transformedTile.contents[row.offset + 1]
                        let bottomOfMonster = ".{\(leftOffset)}.#..#..#..#..#..#....{\(rightOffset)}"
                        let nextRowMatches = nextRow.range(of: bottomOfMonster, options: .regularExpression) == (nextRow.startIndex..<nextRow.endIndex)

                        return previousRowMatches && nextRowMatches
                    })

                    return fullMonsterMatches.count
                } else {
                    return 0
                }
            })
            // Sum up the monsters in the transformed tile
            return numberOfMonsterMiddlesPerRow.reduce(0, +)
        })

        let numberOfSeaMonsters = numberOfMonstersPerTransformedTile.max() ?? 0
        return numberOfSeaMonsters
    }

    private static func getInput(pathToInput: String) -> [Tile] {
        guard let contents = try? String(contentsOf: URL(fileURLWithPath: pathToInput)) else { print("Unable to open input"); exit(2) }

        let tiles = contents.components(separatedBy: "\n\n")

        return tiles.compactMap({ tile in
            guard !tile.isEmpty else { return nil }
            return Tile(string: tile.trimmingCharacters(in: .whitespacesAndNewlines))
        })
    }
}
