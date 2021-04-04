//
//  PrettyPrint.swift
//  KMART
//
//  Created by Nindi Gill on 16/2/21.
//

import Foundation

struct PrettyPrint {

    enum PrintType: String {
        case info = "✅"
        case warning = "⚠️"
        case error = "⛔️"

        var identifier: String {
            rawValue
        }
    }

    static func print(_ type: PrintType, prefix: Bool = true, string: String, carriageReturn: Bool = false, newLine: Bool = true) {
        let carriageReturn: String = carriageReturn ? "\r" : ""
        let terminator: String = newLine ? "\n" : ""
        let string: String = "\(prefix ? "\(type.identifier) [\(Date())] - \(string)" : string)\(carriageReturn)"
        Swift.print(string, terminator: terminator)
    }
}
