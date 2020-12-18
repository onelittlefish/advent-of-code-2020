//
//  Collection.swift
//  AdventOfCode2020
//

import Foundation

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }

    subscript (safe range: Range<Index>) -> Self.SubSequence? {
        return indices.contains(range.lowerBound) &&  indices.contains(range.upperBound) ? self[range] : nil
    }

    subscript (safe range: PartialRangeFrom<Index>) -> Self.SubSequence? {
        return indices.contains(range.lowerBound) ? self[range] : nil
    }
}
