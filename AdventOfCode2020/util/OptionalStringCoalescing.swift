//
//  OptionalStringCoalescing.swift
//  AdventOfCode2020
//

import Foundation

infix operator ???: NilCoalescingPrecedence

/*
 **Usage:**
 ````
 DDLogInfo("The value is \(variableThatMayBeNil ??? "nil")")
 ````

 Reference: [oleb.net](https://oleb.net/blog/2016/12/optionals-string-interpolation/)
 */

// swiftlint:disable:next operator_whitespace
public func ???<T>(optional: T?, defaultValue: @autoclosure () -> String) -> String {
    switch optional {
    case let value?: return String(describing: value)
    case nil: return defaultValue()
    }
}
