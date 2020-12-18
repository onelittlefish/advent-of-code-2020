//
//  Day22.swift
//  AdventOfCode2020
//

import Foundation

struct Day22 {
    static func part1(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)
        guard input.count == 2 else { print("Unexpected number of decks"); exit(2) }

        var player1Deck = input[0]
        var player2Deck = input[1]

        while !player1Deck.isEmpty && !player2Deck.isEmpty {
            let player1Card = player1Deck.removeFirst()
            let player2Card = player2Deck.removeFirst()

            if player1Card > player2Card {
                player1Deck.append(contentsOf: [player1Card, player2Card])
            } else if player2Card > player1Card {
                player2Deck.append(contentsOf: [player2Card, player1Card])
            } else {
                fatalError("Undefined behavior for both players drawing same card value")
            }
        }

        let winningDeck = [player1Deck, player2Deck].first(where: { !$0.isEmpty })!
        let score = winningDeck.enumerated().reduce(0, { result, item in
            let elementScore = item.element * (winningDeck.count - item.offset)
            return result + elementScore
        })
        print(score)
    }

    static func part2(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)
        guard input.count == 2 else { print("Unexpected number of decks"); exit(2) }

        let result = playRecursiveCombat(player1Deck: input[0], player2Deck: input[1])

        let winningDeck = result.winningDeck
        let score = winningDeck.enumerated().reduce(0, { result, item in
            let elementScore = item.element * (winningDeck.count - item.offset)
            return result + elementScore
        })
        print(score)
    }

    private static func playRecursiveCombat(player1Deck: [Int], player2Deck: [Int]) -> (player1Won: Bool, winningDeck: [Int]) {
        var player1Deck = player1Deck
        var player2Deck = player2Deck

        var previousRounds = Set<[[Int]]>()

        while !player1Deck.isEmpty && !player2Deck.isEmpty {
            guard !previousRounds.contains([player1Deck, player2Deck]) else {
                // If the same cards were played in a previous round, player 1 wins
                return (true, player1Deck )
            }

            previousRounds.insert([player1Deck, player2Deck])

            let player1Card = player1Deck.removeFirst()
            let player2Card = player2Deck.removeFirst()

            let player1WonThisRound: Bool
            if player1Deck.count >= player1Card && player2Deck.count >= player2Card {
                // Play a recursive game using the next n cards in each player's deck where n is the value of the card just drawn
                let recursiveResult = playRecursiveCombat(player1Deck: Array(player1Deck[..<player1Card]), player2Deck: Array(player2Deck[..<player2Card]))
                player1WonThisRound = recursiveResult.player1Won
            } else {
                player1WonThisRound = player1Card > player2Card
            }

            if player1WonThisRound {
                player1Deck.append(contentsOf: [player1Card, player2Card])
            } else { // Assuming no ties will occur
                player2Deck.append(contentsOf: [player2Card, player1Card])
            }
        }

        let player1Won = !player1Deck.isEmpty
        let winningDeck = player1Won ? player1Deck : player2Deck
        return (player1Won, winningDeck)
    }

    private static func getInput(pathToInput: String) -> [[Int]] {
        guard let contents = try? String(contentsOf: URL(fileURLWithPath: pathToInput)) else { print("Unable to open input"); exit(2) }

        let decks = contents.components(separatedBy: "Player")
        return decks.compactMap({ deck in
            guard !deck.isEmpty else { return nil }
            return deck.components(separatedBy: "\n").compactMap({ Int($0) })
        })
    }
}
