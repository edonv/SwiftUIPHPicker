//
//  PHPicker+ViewModifiers.swift
//  
//
//  Created by Edon Valdman on 6/19/23.
//

import PhotosUI
import SwiftUI

extension View {
    public func phPicker(
        isPresented: Binding<Bool>,
        selection: Binding<[PHSelectedObject]>,
        maxSelectionCount: Int? = nil,
        matching filter: PHPickerFilter? = nil,
        preferredAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode = .automatic,
        keepLivePhotosIntact: Bool = true,
        photoLibrary: PHPhotoLibrary,
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        self
            .sheet(isPresented: isPresented, onDismiss: onDismiss) {
                PHPicker(selections: selection, keepLivePhotosIntact: keepLivePhotosIntact, photoLibrary: photoLibrary) { config in
                    config.selectionLimit = maxSelectionCount ?? 0
                    config.filter = filter
                    config.preferredAssetRepresentationMode = preferredAssetRepresentationMode
                }
            }
    }
    
    @available(iOS 15, macCatalyst 15, macOS 13, *)
    public func phPicker(
        isPresented: Binding<Bool>,
        selection: Binding<[PHSelectedObject]>,
        maxSelectionCount: Int? = nil,
        selectionBehavior: PHPickerConfiguration.Selection = .default,
        matching filter: PHPickerFilter? = nil,
        preferredAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode = .automatic,
        keepLivePhotosIntact: Bool = true,
        photoLibrary: PHPhotoLibrary,
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        self
            .sheet(isPresented: isPresented, onDismiss: onDismiss) {
                PHPicker(selections: selection, keepLivePhotosIntact: keepLivePhotosIntact, photoLibrary: photoLibrary) { config in
                    config.selectionLimit = maxSelectionCount ?? 0
                    config.selection = selectionBehavior
                    config.filter = filter
                    config.preferredAssetRepresentationMode = preferredAssetRepresentationMode
                }
            }
    }
}

extension PHPicker {
    @available(iOS 15, macCatalyst 15, macOS 13, *)
    public func updatingConfiguration(
        filter: PHPickerFilter? = nil,
        selectionLimit: Int = 0,
        selection: PHPickerConfiguration.Selection = .default
    ) -> PHPicker {
        var newView = self
        var newConfig = newView.configuration
        
        newConfig.filter = filter
        newConfig.selectionLimit = selectionLimit
        newConfig.selection = selection
        
        newView.setConfiguration(newConfig)
        return newView
    }
    
    public func updatingConfiguration(
        filter: PHPickerFilter? = nil,
        selectionLimit: Int = 0
    ) -> PHPicker {
        var newView = self
        var newConfig = newView.configuration
        
        newConfig.filter = filter
        newConfig.selectionLimit = selectionLimit
        
        newView.setConfiguration(newConfig)
        return newView
    }
    
    /// This modifier (or ``setVideoDestinationDirectory(_:)``) must be called in the case of a video being selected from the picker.
    ///
    /// When a video is loaded using `NSItemProvider`'s [`loadFileRepresentation(forTypeIdentifier:completionHandler:)`](https://developer.apple.com/documentation/foundation/nsitemprovider/2888338-loadfilerepresentation), the system saves the video to a temporary file. When leaving the scope of that function's `completionHandler`, the temporary file is deleted. In order to get that file, ``videoDestinationHandler`` is used to map the temporary `URL` to a new `URL` that the file will be moved to before the temporary file is deleted.
    ///
    /// - Note: If you want to keep the file name the same and just move it to a specific directory, you can use ``setVideoDestinationDirectory(_:)``.
    /// - Parameter handler: A closure for mapping the temporary `URL` to a new `URL` where the video file should be saved.
    public func setVideoDestinationHandler(_ handler: @escaping (URL) -> URL) -> PHPicker {
        var newView = self
        newView.videoDestinationHandler = handler
        return newView
    }
    
    /// This modifier (or ``setVideoDestinationHandler(_:)``) must be called in the case of a video being selected from the picker.
    ///
    /// When a video is loaded using `NSItemProvider`'s [`loadFileRepresentation(forTypeIdentifier:completionHandler:)`](https://developer.apple.com/documentation/foundation/nsitemprovider/2888338-loadfilerepresentation), the system saves the video to a temporary file. When leaving the scope of that function's `completionHandler`, the temporary file is deleted. In order to get that file, ``videoDestinationHandler`` is used to map the temporary `URL` to a new `URL` that the file will be moved to before the temporary file is deleted.
    ///
    /// This modifier sets the destination `URL` to the temporary `URL`'s file name within the provided `directoryURL` parameter.
    ///
    /// - Note: If you want to generate a destination `URL` for videos differently, use ``setVideoDestinationHandler(_:)``.
    /// - Parameter handler: A closure for mapping the temporary `URL` to a new `URL` where the video file should be saved.
    public func setVideoDestinationDirectory(_ directoryURL: URL) -> PHPicker {
        self.setVideoDestinationHandler { temporaryURL in
            if #available(iOS 16, macCatalyst 16, macOS 13, *) {
                return directoryURL
                    .appending(component: temporaryURL.lastPathComponent, directoryHint: .notDirectory)
            } else {
                return directoryURL
                    .appendingPathComponent(temporaryURL.lastPathComponent, isDirectory: false)
            }
        }
    }
}
