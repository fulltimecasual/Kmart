//
//  Slacker.swift
//  KMART
//
//  Created by Nindi Gill on 20/8/21.
//

import Foundation

struct Slacker {

    private static let chatPostMessageURL: String = "https://slack.com/api/chat.postMessage"
    private static let filesUploadURL: String = "https://slack.com/api/files.upload"

    static func send(_ reports: Reports, using configuration: Configuration) {
        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
        let slack: Slack = configuration.slack

        PrettyPrint.print(.info, string: "Sending Report(s) via Slack")

        guard let timestamp: String = message(slack, using: semaphore) else {
            return
        }

        for outputType in OutputType.allCases {

            if let boolean: Bool = slack.attachments[outputType],
                boolean,
                let data: Data = reports.data(type: outputType, using: configuration) {
                upload(data, of: outputType, for: slack, timestamp: timestamp, using: semaphore)
            }
        }
    }

    private static func message(_ slack: Slack, using semaphore: DispatchSemaphore) -> String? {

        var timestamp: String?

        guard let url: URL = URL(string: chatPostMessageURL) else {
            PrettyPrint.print(.error, string: "Invalid URL: \(chatPostMessageURL)")
            return nil
        }

        guard let data: Data = messageData(for: slack) else {
            return nil
        }

        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(slack.token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = data

        let task: URLSessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in

            if let error: Error = error {
                PrettyPrint.print(.error, string: "\(error.localizedDescription)")
                semaphore.signal()
                return
            }

            guard let response: URLResponse = response,
                let httpResponse: HTTPURLResponse = response as? HTTPURLResponse else {
                PrettyPrint.print(.error, string: "Unable to get response from URL: \(url)")
                semaphore.signal()
                return
            }

            guard httpResponse.statusCode == 200 else {
                let string: String = HTTP.errorMessage(httpResponse.statusCode, url: url)
                PrettyPrint.print(.error, string: string)
                semaphore.signal()
                return
            }

            guard let data: Data = data,
                let dictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                PrettyPrint.print(.error, string: "Invalid response data from URL: \(url)")
                semaphore.signal()
                return
            }

            guard let string: String = dictionary["ts"] as? String else {
                PrettyPrint.print(.error, string: "Missing key 'ts' from response dictionary")
                semaphore.signal()
                return
            }

            timestamp = string
            semaphore.signal()
        }

        task.resume()
        semaphore.wait()
        return timestamp
    }

    private static func messageData(for slack: Slack) -> Data? {

        let dictionary: [String: Any] = [
            "channel": slack.channel,
            "blocks": [
                [
                    "type": "section",
                    "text": [
                        "type": "mrkdwn",
                        "text": slack.text
                    ]
                ]
            ],
            "text": Slack.defaultText
        ]

        guard let data: Data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else {
            PrettyPrint.print(.error, string: "Invalid dictionary: \(dictionary)")
            return nil
        }

        return data
    }

    private static func upload(_ data: Data, of outputType: OutputType, for slack: Slack, timestamp: String, using semaphore: DispatchSemaphore) {

        guard let url: URL = URL(string: filesUploadURL) else {
            PrettyPrint.print(.error, string: "Invalid URL: \(filesUploadURL)")
            return
        }

        guard let data: Data = uploadData(from: data, of: outputType, for: slack, timestamp: timestamp) else {
            return
        }

        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(slack.token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = data

        PrettyPrint.print(.info, string: "Uploading \(outputType.description) report via Slack")

        let task: URLSessionDataTask = URLSession.shared.dataTask(with: request) { _, response, error in

            if let error: Error = error {
                PrettyPrint.print(.error, string: "\(error.localizedDescription)")
                semaphore.signal()
                return
            }

            guard let response: URLResponse = response,
                let httpResponse: HTTPURLResponse = response as? HTTPURLResponse else {
                PrettyPrint.print(.error, string: "Unable to get response from URL: \(url)")
                semaphore.signal()
                return
            }

            guard httpResponse.statusCode == 200 else {
                let string: String = HTTP.errorMessage(httpResponse.statusCode, url: url)
                PrettyPrint.print(.error, string: string)
                semaphore.signal()
                return
            }

            semaphore.signal()
        }

        task.resume()
        semaphore.wait()
    }

    private static func uploadData(from data: Data, of outputType: OutputType, for slack: Slack, timestamp: String) -> Data? {

        guard let string: String = String(data: data, encoding: .utf8) else {
            PrettyPrint.print(.error, string: "Invalid \(outputType.description) report data")
            return nil
        }

        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString: String = dateFormatter.string(from: Date())
        let filename: String = "KMART Report \(dateString).\(outputType.fileExtension)"

        var requestComponents: URLComponents = URLComponents()
        requestComponents.queryItems = [
            URLQueryItem(name: "channels", value: slack.channel),
            URLQueryItem(name: "content", value: string),
            URLQueryItem(name: "filename", value: filename),
            URLQueryItem(name: "filetype", value: outputType.filetype),
            URLQueryItem(name: "thread_ts", value: timestamp),
            URLQueryItem(name: "title", value: filename)
        ]

        guard let query: String = requestComponents.query else {
            PrettyPrint.print(.error, string: "Invalid query from query items")
            return nil
        }

        guard let data: Data = query.data(using: .utf8) else {
            PrettyPrint.print(.error, string: "Invalid data from query \(query)")
            return nil
        }

        return data
    }
}
