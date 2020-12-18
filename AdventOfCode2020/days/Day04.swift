//
//  Day4.swift
//  AdventOfCode2020
//

import Foundation

private enum PassportField: String {
    case birthYear = "byr"
    case issueYear = "iyr"
    case expirationYear = "eyr"
    case height = "hgt"
    case hairColor = "hcl"
    case eyeColor = "ecl"
    case passportID = "pid"
    case countryID = "cid"
}

private enum HeightUnit: String {
    case centimeters = "cm"
    case inches = "in"
}

private struct Height {
    let value: Int
    let units: HeightUnit
}

private enum EyeColor: String {
    case amber = "amb"
    case blue = "blu"
    case brown = "brn"
    case grey = "gry"
    case green = "grn"
    case hazel = "hzl"
    case other = "oth"
}

private struct Passport {
    private let requiredFields = Set<PassportField>([.birthYear, .issueYear, .expirationYear, .height, .hairColor, .eyeColor, .passportID])
    let fields: Set<PassportField>

    let birthYear: Int?
    let issueYear: Int?
    let expirationYear: Int?
    let height: Height?
    let hairColor: String?
    let eyeColor: EyeColor?
    let passportID: String?
    let countryID: String?

    /**
     Example input:
     ```
     hcl:dab227 iyr:2012
     ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277
     ```
     */
    init(keyValuePairs: [String]) {
        // Create dictionary of keys and values for the fields
        let passportFields = keyValuePairs.compactMap({ keyValuePair -> (key: String, value: String)? in
            let components = keyValuePair.components(separatedBy: ":")
            guard let key = components.first, let value = components[safe: 1] else { return nil }
            return (key, value)
        }).reduce(into: [String: String](), { result, keyValue in
            result[keyValue.key] = keyValue.value
        })
        fields = Set(passportFields.keys.compactMap({ PassportField(rawValue: $0) }))

        if let birthYearString = passportFields["byr"] {
            birthYear = Int(birthYearString)
        } else {
            birthYear = nil
        }
        if let issueYearString = passportFields["iyr"] {
            issueYear = Int(issueYearString)
        } else {
            issueYear = nil
        }
        if let expirationYearString = passportFields["eyr"] {
            expirationYear = Int(expirationYearString)
        } else {
            expirationYear = nil
        }
        let heightPattern = #"([0-9]+)(cm|in)"# // a number followed by either cm or in
        let regex = try? NSRegularExpression(pattern: heightPattern, options: [])
        if let heightString = passportFields["hgt"],
           let match = regex?.firstMatch(in: heightString, options: [], range: NSRange(heightString.startIndex..<heightString.endIndex, in: heightString)),
           let range1 = Range(match.range(at: 1), in: heightString),
           let range2 = Range(match.range(at: 2), in: heightString),
           let heightValue = Int(heightString[range1]),
           let heightUnits = HeightUnit(rawValue: String(heightString[range2])) {
            height = Height(value: heightValue, units: heightUnits)
        } else {
            height = nil
        }
        hairColor = passportFields["hcl"]
        if let eyeColorString = passportFields["ecl"] {
            eyeColor = EyeColor(rawValue: eyeColorString)
        } else {
            eyeColor = nil
        }
        passportID = passportFields["pid"]
        countryID = passportFields["cid"]
    }

    func isValidForPart1() -> Bool {
        return fields.isSuperset(of: requiredFields)
    }

    func isValidForPart2() -> Bool {
        guard let birthYear = birthYear, let issueYear = issueYear, let expirationYear = expirationYear, let height = height, let hairColor = hairColor, let passportID = passportID else { return false }

        let isHeightValid: Bool
        switch height.units {
        case .centimeters:
            isHeightValid = (150...193).contains(height.value)
        case .inches:
            isHeightValid = (59...76).contains(height.value)
        }

        let hairColorPattern = #"#[a-f0-9]{6}"# // a # followed by exactly six characters 0-9 or a-f
        let isHairColorValid = hairColor.range(of: hairColorPattern, options: [.regularExpression]) == (hairColor.startIndex..<hairColor.endIndex)

        let passportIDPattern = #"[0-9]{9}"# // a nine-digit number
        let isPassportIDValid = passportID.range(of: passportIDPattern, options: [.regularExpression]) == (passportID.startIndex..<passportID.endIndex)

        return (1920...2002).contains(birthYear)
            && (2010...2020).contains(issueYear)
            && (2020...2030).contains(expirationYear)
            && isHeightValid
            && isHairColorValid
            && eyeColor != nil
            && isPassportIDValid
    }
}

struct Day4 {
    static func part1(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)
        let numberOfValidPassports = input.filter({ $0.isValidForPart1() }).count
        print("\(numberOfValidPassports) valid")
    }

    static func part2(pathToInput: String) {
        let input = getInput(pathToInput: pathToInput)
        let numberOfValidPassports = input.filter({ $0.isValidForPart2() }).count
        print("\(numberOfValidPassports) valid")
    }

    private static func getInput(pathToInput: String) -> [Passport] {
        guard let contents = try? String(contentsOf: URL(fileURLWithPath: pathToInput)) else { print("Unable to open input"); exit(2) }
        return contents.components(separatedBy: "\n\n").compactMap({ passport in
            let passport = String(passport)
            let keyValuePairs = passport.components(separatedBy: .whitespacesAndNewlines)
            return Passport(keyValuePairs: keyValuePairs)
        })
    }
}
