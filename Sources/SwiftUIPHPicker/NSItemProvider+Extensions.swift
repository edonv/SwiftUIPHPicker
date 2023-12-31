//
//  NSItemProvider+Extensions.swift
//  
//
//  Created by Edon Valdman on 6/19/23.
//

import Foundation

extension NSItemProvider {
    public func loadFileRepresentation(
        forTypeIdentifier typeIdentifier: String,
        destinationHandler: ((URL) -> URL?)? = nil
    ) async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            loadFileRepresentation(forTypeIdentifier: typeIdentifier) { (url, error) in
                if let url {
                    if let destinationHandler,
                       let newURL = destinationHandler(url),
                       FileManager.default.secureCopyItem(at: url, to: newURL) {
                        continuation.resume(returning: newURL)
                    } else {
                        continuation.resume(returning: url)
                    }
                } else if let error {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public func loadObject<T>(
        ofClass aClass: T.Type
    ) async throws -> T where T : NSItemProviderReading {
        return try await withCheckedThrowingContinuation { continuation in
            loadObject(ofClass: aClass.self) { object, error in
                if let object {
                    continuation.resume(returning: object as! T)
                } else if let error {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
