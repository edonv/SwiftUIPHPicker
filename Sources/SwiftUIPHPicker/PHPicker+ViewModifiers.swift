//
//  PHPicker+ViewModifiers.swift
//  
//
//  Created by Edon Valdman on 6/19/23.
//

import PhotosUI
import SwiftUI

extension PHPicker {
    /// This modifier (or ``PHPicker/videoDestinationDirectory(_:)``) must be called in the case of a video being selected from the picker.
    ///
    /// When a video is loaded using `NSItemProvider`'s [`loadFileRepresentation(forTypeIdentifier:completionHandler:)`](https://developer.apple.com/documentation/foundation/nsitemprovider/2888338-loadfilerepresentation), the system saves the video to a temporary file. When leaving the scope of that function's `completionHandler`, the temporary file is deleted. In order to access the file before it's deleted, the `URL` returned by `handler` is used to map the temporary `URL` to a new `URL` that the file will be moved to before access is lost.
    ///
    /// - Note: If you want to keep the file name the same and just move it to a specific directory, you can use ``videoDestinationDirectory(_:)``.
    /// - Parameter handler: A closure for mapping the temporary `URL` to a new `URL` where the video file should be saved.
    public func videoDestination(_ handler: ((URL) -> URL?)?) -> PHPicker {
        var newView = self
        newView.videoDestinationHandler = handler
        return newView
    }
    
    /// This modifier (or ``PHPicker/videoDestination(_:)``) must be called in the case of a video being selected from the picker.
    ///
    /// When a video is loaded using `NSItemProvider`'s [`loadFileRepresentation(forTypeIdentifier:completionHandler:)`](https://developer.apple.com/documentation/foundation/nsitemprovider/2888338-loadfilerepresentation), the system saves the video to a temporary file. When leaving the scope of that function's `completionHandler`, the temporary file is deleted. In order to access the file before it's deleted, the `URL` returned by `handler` is used to map the temporary `URL` to a new `URL` that the file will be moved to before access is lost.
    ///
    /// This modifier sets the destination `URL` to the temporary `URL`'s file name within the provided `directoryURL` parameter.
    ///
    /// - Note: If you want to generate a destination `URL` for videos differently, use ``videoDestination(_:)``.
    /// - Parameter handler: A closure for mapping the temporary `URL` to a new `URL` where the video file should be saved.
    public func videoDestinationDirectory(_ directoryURL: URL?) -> PHPicker {
        self.videoDestination { temporaryURL in
            if #available(iOS 16, macCatalyst 16, macOS 13, *) {
                return directoryURL?
                    .appending(component: temporaryURL.lastPathComponent, directoryHint: .notDirectory)
            } else {
                return directoryURL?
                    .appendingPathComponent(temporaryURL.lastPathComponent, isDirectory: false)
            }
        }
    }
}
