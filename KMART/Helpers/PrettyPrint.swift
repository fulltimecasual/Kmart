//
//  PrettyPrint.swift
//  KMART
//
//  Created by Nindi Gill on 16/2/21.
//

import Foundation

/// Struct used to perform all **PrettyPrint** operations.
struct PrettyPrint {

    enum Prefix: String {
        case `default` = "  ├─ "
        case ending    = "  └─ "
    }

    /// Maximum column width for printing
    static let maximumWidth: Int = 80

    /// Prints a string with a border, in blue.
    ///
    /// - Parameters:
    ///   - header: The string to print.
    static func printHeader(_ header: String) {
        let horizontal: String = String(repeating: "─", count: header.count + 2)
        let string: String = "┌\(horizontal)┐\n│ \(header) │\n└\(horizontal)┘"
        Swift.print(string.color(.blue))
    }

    /// Prints a string with an optional custom prefix.
    ///
    /// - Parameters:
    ///   - string:      The string to print.
    ///   - prefix:      The optional prefix.
    ///   - prefixColor: The optional prefix color.
    ///   - replacing:   Optionally set to `true` to replace the previous line.
    static func print(_ string: String, prefix: Prefix = .default, prefixColor: String.Color = .green, replacing: Bool = false) {
        let replacing: String = replacing ? "\u{1B}[1A\u{1B}[K" : ""
        let string: String = "\(replacing)\(prefix.rawValue.color(prefixColor))\(string)"
        Swift.print(string)
    }
}
