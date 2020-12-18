//
//  Day17.swift
//  AdventOfCode2020
//

import Foundation

private protocol Coordinates: Hashable {
    func getNeighbors() -> [Self]
}

private struct Coordinates3D: Coordinates {
    let x: Int
    let y: Int
    let z: Int

    func getNeighbors() -> [Coordinates3D] {
        var neighbors: [Coordinates3D] = []
        (z - 1...z + 1).forEach({ zIndex in
            (y - 1...y + 1).forEach({ yIndex in
                (x - 1...x + 1).forEach({ xIndex in
                    if xIndex != x || yIndex != y || zIndex != z {
                        neighbors.append(Coordinates3D(x: xIndex, y: yIndex, z: zIndex))
                    }
                })
            })
        })
        return neighbors
    }
}

private struct Coordinates4D: Coordinates {
    let x: Int
    let y: Int
    let z: Int
    let w: Int

    func getNeighbors() -> [Coordinates4D] {
        var neighbors: [Coordinates4D] = []
        (w - 1...w + 1).forEach({ wIndex in
            (z - 1...z + 1).forEach({ zIndex in
                (y - 1...y + 1).forEach({ yIndex in
                    (x - 1...x + 1).forEach({ xIndex in
                        if xIndex != x || yIndex != y || zIndex != z || wIndex != w {
                            neighbors.append(Coordinates4D(x: xIndex, y: yIndex, z: zIndex, w: wIndex))
                        }
                    })
                })
            })
        })
        return neighbors
    }
}

struct Day17 {
    static func part1(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)
        let active = simulate(active: input, cycles: 6)
        print(active.count)
    }

    static func part2(pathToInput: String) {
        let input = Set(getInput(pathToInput: pathToInput).map({ Coordinates4D(x: $0.x, y: $0.y, z: $0.z, w: 0) }))
        let active = simulate(active: input, cycles: 6)
        print(active.count)
    }

    private static func simulate<T: Coordinates>(active: Set<T>, cycles: Int) -> Set<T> {
        var newActive = active

        (1...cycles).forEach({ _ in
            // Reset state
            let currentActive = newActive
            newActive.removeAll()
            var coordinatesConsidered = Set<T>()

            // Update cells
            currentActive.forEach({ active in
                let neighbors = active.getNeighbors()

                // Determine if active cell should remain active
                let activeNeighbors = neighbors.filter({ currentActive.contains($0) })
                if activeNeighbors.count == 2 || activeNeighbors.count == 3 {
                    newActive.insert(active)
                }

                // Determine if inactive neighbors should become active
                neighbors.forEach({ neighbor in
                    guard !currentActive.contains(neighbor) && !coordinatesConsidered.contains(neighbor) else { return }

                    coordinatesConsidered.insert(neighbor)

                    let neighbors = neighbor.getNeighbors()
                    let activeNeighbors = neighbors.filter({ currentActive.contains($0) })
                    if activeNeighbors.count == 3 {
                        newActive.insert(neighbor)
                    }
                })
            })
        })

        return newActive
    }

    private static func getInput(pathToInput: String) -> Set<Coordinates3D> {
        guard let contents = try? String(contentsOf: URL(fileURLWithPath: pathToInput)) else { print("Unable to open input"); exit(2) }

        let coordinates = contents.components(separatedBy: "\n").enumerated().map({ yIndex, line in
            return line.enumerated().compactMap({ xIndex, character -> Coordinates3D? in
                if character == "#" {
                    return Coordinates3D(x: xIndex, y: yIndex, z: 0)
                } else {
                    return nil
                }
            })
        }).flatMap({ $0 })

        return Set(coordinates)
    }
}
