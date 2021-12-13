//
//  Version.swift
//  KMART
//
//  Created by Nindi Gill on 14/2/21.
//

import Foundation

/// Struct to perform **Version** operations.
struct Version {

    /// Current version.
    private static let version: String = "1.2"
    /// Current version with error message when unable to lookup latest version.
    private static var versionWithErrorMessage: String {
        "\(version) (Unable to check for latest version)"
    }

    /// Prints the current version and checks for the latest version.
    static func run() {

        guard let url: URL = URL(string: .latestReleaseURL) else {
            print(versionWithErrorMessage)
            return
        }

        do {
            let string: String = try String(contentsOf: url, encoding: .utf8)

            guard let data: Data = string.data(using: .utf8),
                let dictionary: [String: Any] = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                let tag: String = dictionary["tag_name"] as? String else {
                print(versionWithErrorMessage)
                return
            }

            let latestVersion: String = tag.replacingOccurrences(of: "v", with: "")
            print("\(version) (Latest: \(latestVersion))")

            guard version.compare(latestVersion, options: .numeric) == .orderedAscending else {
                return
            }

            print("Visit \(String.repositoryURL) to grab the latest release of \(String.appName)")
        } catch {
            print(versionWithErrorMessage)
        }
    }
}
