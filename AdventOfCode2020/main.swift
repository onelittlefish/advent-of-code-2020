//
//  main.swift
//  AdventOfCode2020
//

import Foundation

let args = CommandLine.arguments

guard let day = args[safe: 1], let input = args[safe: 2] else {
    print("""
    Usage: AdventOfCode2020 <day (e.g. 1)> <path to input file>
    """)
    exit(2)
}

switch day {
case "1":
    Day1.part1(pathToInput: input)
    Day1.part2(pathToInput: input)
case "2":
    Day2.part1(pathToInput: input)
    Day2.part2(pathToInput: input)
case "3":
    Day3.part1(pathToInput: input)
    Day3.part2(pathToInput: input)
case "4":
    Day4.part1(pathToInput: input)
    Day4.part2(pathToInput: input)
case "5":
    Day5.part1(pathToInput: input)
    Day5.part2(pathToInput: input)
case "6":
    Day6.part1(pathToInput: input)
    Day6.part2(pathToInput: input)
case "7":
    Day7.part1(pathToInput: input)
    Day7.part2(pathToInput: input)
case "8":
    Day8.part1(pathToInput: input)
    Day8.part2(pathToInput: input)
case "9":
    Day9.part1(pathToInput: input)
    Day9.part2(pathToInput: input)
case "10":
    Day10.part1(pathToInput: input)
    Day10.part2(pathToInput: input)
case "11":
    Day11.part1(pathToInput: input)
    Day11.part2(pathToInput: input)
case "12":
    Day12.part1(pathToInput: input)
    Day12.part2(pathToInput: input)
case "13":
    Day13.part1(pathToInput: input)
    Day13.part2(pathToInput: input)
case "14":
    Day14.part1(pathToInput: input)
    Day14.part2(pathToInput: input)
case "15":
    Day15.part1(pathToInput: input)
    Day15.part2(pathToInput: input)
case "16":
    Day16.part1(pathToInput: input)
    Day16.part2(pathToInput: input)
case "17":
    Day17.part1(pathToInput: input)
    Day17.part2(pathToInput: input)
case "18":
    Day18.part1(pathToInput: input)
    Day18.part2(pathToInput: input)
case "19":
    Day19.part1(pathToInput: input)
    Day19.part2(pathToInput: input)
case "20":
    Day20.part1(pathToInput: input)
    Day20.part2(pathToInput: input)
case "21":
    Day21.part1(pathToInput: input)
    Day21.part2(pathToInput: input)
case "22":
    Day22.part1(pathToInput: input)
    Day22.part2(pathToInput: input)
case "23":
    Day23.part1(pathToInput: input)
    Day23.part2(pathToInput: input)
case "24":
    Day24.part1(pathToInput: input)
    Day24.part2(pathToInput: input)
case "25":
    Day25.part1(pathToInput: input)
    Day25.part2(pathToInput: input)
default:
    print("Invalid day \(day)")
    exit(2)
}
