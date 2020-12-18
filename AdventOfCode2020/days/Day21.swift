//
//  Day21.swift
//  AdventOfCode2020
//

import Foundation

private struct Food {
    let ingredients: [String]
    let allergens: [String]
}

struct Day21 {
    static func part1(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)

        var possibleIngredientsWithAllergen: [String: Set<String>] = [:]
        var allIngredients: Set<String> = []

        input.forEach({ food in
            let ingredients = Set(food.ingredients)
            allIngredients.formUnion(ingredients)
            food.allergens.forEach({ allergen in
                possibleIngredientsWithAllergen[allergen, default: ingredients].formIntersection(ingredients)
            })
        })

        let possibleIngredientsWithAnyAllergen = possibleIngredientsWithAllergen.values.flatMap({ $0 })
        let ingredientsWithoutAllergens = allIngredients.subtracting(possibleIngredientsWithAnyAllergen)

        let numberOfAppearancesInFoods = input.reduce(0, { result, food in
            let numberOfIngredientsWithoutAllergens = Set(food.ingredients).intersection(ingredientsWithoutAllergens).count
            return result + numberOfIngredientsWithoutAllergens
        })
        print(numberOfAppearancesInFoods)
    }

    static func part2(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)

        var possibleIngredientsWithAllergen: [String: Set<String>] = [:]
        var allIngredients: Set<String> = []

        input.forEach({ food in
            let ingredients = Set(food.ingredients)
            allIngredients.formUnion(ingredients)
            food.allergens.forEach({ allergen in
                possibleIngredientsWithAllergen[allergen, default: ingredients].formIntersection(ingredients)
            })
        })

        // Allergens mapped to one possible ingredient are locked in
        var lockedInAllergens = possibleIngredientsWithAllergen.filter({ $0.value.count == 1 })
            .map({ (allergen: $0.key, ingredient: $0.value.first!) })
        var lockedInAllergensIndex = lockedInAllergens.startIndex

        while lockedInAllergensIndex < lockedInAllergens.endIndex {
            let lockedInAllergen = lockedInAllergens[lockedInAllergensIndex]

            possibleIngredientsWithAllergen.removeValue(forKey: lockedInAllergen.allergen)

            // Remove locked-in ingredient from other foods
            possibleIngredientsWithAllergen.forEach({ (allergen, possibleIngredients) in
                possibleIngredientsWithAllergen[allergen]?.remove(lockedInAllergen.ingredient)
                // If allergen only has one possible ingredient left, add it to the list of locked-in ingredients
                if let ingredientsWithAllergen = possibleIngredientsWithAllergen[allergen], ingredientsWithAllergen.count == 1, !lockedInAllergens.contains(where: { $0.allergen == allergen }) {
                    lockedInAllergens.append((allergen, ingredientsWithAllergen.first!))
                }
            })

            lockedInAllergensIndex += 1
        }

        // Sort ingredients with allergens alphabetically by allergen and join into comma-separated list
        let dangerousIngredients = lockedInAllergens.sorted(by: { lhs, rhs in
            return lhs.allergen < rhs.allergen
        }).map({ $0.ingredient }).joined(separator: ",")
        print(dangerousIngredients)
    }

    private static func getInput(pathToInput: String) -> [Food] {
        guard let contents = try? String(contentsOf: URL(fileURLWithPath: pathToInput)) else { print("Unable to open input"); exit(2) }

        let pattern = #"([A-Za-z\s]+) \(contains ([A-Za-z,\s]+)\)"# // e.g. sqjhc mxmxvkd sbzzf (contains fish)
        let regex = try? NSRegularExpression(pattern: pattern, options: [])

        return contents.components(separatedBy: "\n").compactMap({ line in
            if let match = regex?.firstMatch(in: line, options: [], range: NSRange(line.startIndex..<line.endIndex, in: line)),
               let range1 = Range(match.range(at: 1), in: line),
               let range2 = Range(match.range(at: 2), in: line) {
                let ingredients = line[range1].components(separatedBy: .whitespaces)
                let allergens = line[range2].components(separatedBy: ", ")
                return Food(ingredients: ingredients, allergens: allergens)
            } else {
                return nil
            }
        })
    }
}
