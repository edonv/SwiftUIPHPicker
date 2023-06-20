//
//  NSItemProvider+Extensions.swift
//  
//
//  Created by Edon Valdman on 6/19/23.
//

import Foundation

extension NSItemProvider {
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
