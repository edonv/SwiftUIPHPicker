//
//  FileManager+Extensions.swift
//  
//
//  Created by Edon Valdman on 8/23/23.
//

import Foundation

extension FileManager {
    /// Copies an item from `sourceURL` to `destinationURL`.
    ///
    /// The function checks that there isn't already a file at the destination, but doesn't check if there is a file to copy at `sourceURL`. This is because when calling from some contexts (i.e. `.fileImporter`), this check always fails, even if it actually exists.
    /// - Returns: A `Bool` describing if it succeeded or not in copying.
    @discardableResult
    func secureCopyItem(at sourceURL: URL, to destinationURL: URL) -> Bool {
        do {
            if !FileManager.default.fileExists(atPath: destinationURL.absoluteString) {
                try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
                return true
            }
        } catch {
            print("Cannot copy item at \(sourceURL) to \(destinationURL): \(error)")
        }
        
        return false
    }
}
