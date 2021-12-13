//
//  Department.swift
//  KMART
//
//  Created by Nindi Gill on 15/2/21.
//

import Foundation

struct Department: Codable {
    var id: Int = -1
    var name: String = ""
    var dictionary: [String: Any] {
        [
            "id": id,
            "name": name
        ]
    }
}
