//
//  Day7.swift
//  AdventOfCode2020
//

import Foundation
import SwiftGraph

struct Day7 {
    static func part1(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput, graphDirectedTowardContents: false)
        let numberReachableFromStart = input.findAllDfs(from: "shiny gold", goalTest: { $0 != "shiny gold" })
        print("\(numberReachableFromStart.count) bags contain shiny gold")
    }

    static func part2(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput, graphDirectedTowardContents: true)

        guard let startIndex = input.indexOfVertex("shiny gold") else { print("Color not found"); return }

        let nestedNumberOfBags = fullDFSReduce(graph: input, fromIndex: startIndex, initialResult: 1, nextPartialResult: { resultSoFar, resultForNeighbor, edge in
            return resultSoFar + edge.weight * resultForNeighbor
        })
        print("\(nestedNumberOfBags - 1) bags nested in shiny gold bag") // Subtract one for the top-level shiny gold bag
    }

    /**
     Performs a full depth-first traversal starting at `fromIndex` with a reduce over the visited vertices.
     - parameters:
        - initialResult: The base case for the result before `nextPartialResult` is applied. E.g., if you want to sum the edge weights, this would be` 0`.
        - nextPartialResult: A closure that returns an updated result after visiting a vertex's neighbor.
        Paramaters are the result for the vertex so far, the cumulative result for the neighbor, and the edge to the neighbor.
        E.g., if you want to sum the edge weights, this would return `$0 + $1 + $2.weight`.
     - returns: The cumulative result over the visited vertices, applying `nextPartialResult` to the `iniitalResult`
     */
    private static func fullDFSReduce<T>(
        graph: WeightedGraph<String, Int>,
        fromIndex initialVertexIndex: Int,
        initialResult: T,
        nextPartialResult: (T, T, WeightedEdge<Int>) -> T
    ) -> T {
        var resultForVertex = initialResult

        let neighbors = graph.edgesForIndex(initialVertexIndex)
        if neighbors.isEmpty {
            return initialResult
        }

        neighbors.forEach({ neighbor in
            let resultForNeighbor = fullDFSReduce(graph: graph, fromIndex: neighbor.v, initialResult: initialResult, nextPartialResult: nextPartialResult)
            resultForVertex = nextPartialResult(resultForVertex, resultForNeighbor, neighbor)
        })

        return resultForVertex
    }

    private static func getInput(pathToInput: String, graphDirectedTowardContents: Bool) -> WeightedGraph<String, Int> {
        guard let contents = try? String(contentsOf: URL(fileURLWithPath: pathToInput)) else { print("Unable to open input"); exit(2) }

        let graph = WeightedGraph<String, Int>()
        let addVertexIfNecessary: (String) -> Void = { vertex in
            if !graph.contains(vertex) {
                _ = graph.addVertex(vertex)
            }
        }

        let contentPattern = #"([0-9]+) ([A-Za-z\s]+) bag(s)*"# // e.g. <#> <color> bag(s)
        let regex = try? NSRegularExpression(pattern: contentPattern, options: [])

        contents.components(separatedBy: "\n").forEach({ line in
            let components = line.dropLast().components(separatedBy: "bags contain") // Remove period, split into color and contents
            guard let color = components.first?.trimmingCharacters(in: .whitespaces), let contents = components[safe: 1]?.components(separatedBy: ",") else { return }
            contents.forEach({ content in
                let content = content.trimmingCharacters(in: .whitespaces)
                if content == "no other bags" {
                    addVertexIfNecessary(color)
                } else if let match = regex?.firstMatch(in: content, options: [], range: NSRange(content.startIndex..<content.endIndex, in: content)),
                          let range1 = Range(match.range(at: 1), in: content),
                          let range2 = Range(match.range(at: 2), in: content),
                          let contentNumber = Int(content[range1]) {
                    let contentColor = String(content[range2])
                    addVertexIfNecessary(color)
                    addVertexIfNecessary(contentColor)
                    if graphDirectedTowardContents {
                        graph.addEdge(from: color, to: contentColor, weight: contentNumber, directed: true)
                    } else {
                        graph.addEdge(from: contentColor, to: color, weight: contentNumber, directed: true)
                    }
                }
            })
        })
        return graph
    }
}

