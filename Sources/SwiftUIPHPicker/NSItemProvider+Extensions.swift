//
//  NSItemProvider+Extensions.swift
//  
//
//  Created by Edon Valdman on 6/19/23.
//

import Foundation

extension NSItemProvider {
    public func loadFileRepresentation(
        forTypeIdentifier typeIdentifier: String
    ) async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            _ = loadFileRepresentation(forTypeIdentifier: typeIdentifier) { (url, error) in
                if let url {
                    continuation.resume(returning: url)
                } else if let error {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
