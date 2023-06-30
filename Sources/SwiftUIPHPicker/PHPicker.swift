//
//  PHPicker.swift
//  
//
//  Created by Edon Valdman on 6/15/23.
//

import PhotosUI
import SwiftUI

public struct PHPicker {
    @Binding var selections: [PHSelectedObject]
    private(set) var configuration: PHPickerConfiguration
    
    /// When set to `true`, selected Live Photos are returned as a ``PHSelectedObject/livePhoto(fileName:image:)``. Otherwise, they're returned in the form of a ``PHSelectedObject/photo(fileName:image:)``.
    var keepLivePhotosIntact: Bool = true
    
    public init(selections: Binding<[PHSelectedObject]>, keepLivePhotosIntact: Bool = true, photoLibrary: PHPhotoLibrary? = nil) {
        self._selections = selections
        self.keepLivePhotosIntact = keepLivePhotosIntact
        
        if let photoLibrary {
            self.configuration = PHPickerConfiguration(photoLibrary: photoLibrary)
        } else {
            self.configuration = PHPickerConfiguration()
        }
    }
    
    public init(selections: Binding<[PHSelectedObject]>, keepLivePhotosIntact: Bool = true, photoLibrary: PHPhotoLibrary? = nil, configurationHandler: (_ config: inout PHPickerConfiguration) -> Void) {
        self._selections = selections
        self.keepLivePhotosIntact = keepLivePhotosIntact
        
        if let photoLibrary {
            self.configuration = PHPickerConfiguration(photoLibrary: photoLibrary)
        } else {
            self.configuration = PHPickerConfiguration()
        }
        configurationHandler(&configuration)
    }
    
    public init(selections: Binding<[PHSelectedObject]>, keepLivePhotosIntact: Bool = true, configuration: PHPickerConfiguration) {
        self._selections = selections
        self.keepLivePhotosIntact = keepLivePhotosIntact
        self.configuration = configuration
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    internal mutating func setConfiguration(_ newConfiguration: PHPickerConfiguration) {
        self.configuration = newConfiguration
    }
}

#if canImport(UIKit)
import UIKit

extension PHPicker: UIViewControllerRepresentable {
    public func makeUIViewController(context: Context) -> PHPickerViewController {
        let picker = PHPickerViewController(configuration: self.configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }
}
#endif

#if canImport(Cocoa) && os(macOS)
import Cocoa

extension PHPicker: NSViewControllerRepresentable {
    public func makeNSViewController(context: Context) -> PHPickerViewController {
        let picker = PHPickerViewController(configuration: self.configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    public func updateNSViewController(_ nsViewController: PHPickerViewController, context: Context) {
        
    }
}
#endif

extension PHPicker {
    public class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PHPicker
        
        init(_ parent: PHPicker) {
            self.parent = parent
        }
        
        public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            #if canImport(UIKit) && (os(iOS) || targetEnvironment(macCatalyst))
            picker.dismiss(animated: true)
            #endif
            
            #if canImport(Cocoa) && os(macOS)
            picker.parent?.dismiss(picker)
            #endif
            
            asyncLoadSelectedImages(from: results)
        }
        
        private func asyncLoadSelectedImages(from results: [PHPickerResult]) {
            let keepLivePhotosIntact = parent.keepLivePhotosIntact
            Task { [keepLivePhotosIntact] in
                do {
                    parent.selections = try await withThrowingTaskGroup(of: PHSelectedObject?.self,
                                                                        returning: [PHSelectedObject].self) { taskGroup in
                        for result in results {
                            taskGroup.addTask {
                                let provider = result.itemProvider
                                
                                // Define functions for platform-specific behavior
                                let checkIfProviderIsLivePhoto = { (_ provider: NSItemProvider) -> Bool in
                                    #if canImport(Cocoa) && os(macOS)
                                    return false
                                    #else
                                    return provider.canLoadObject(ofClass: PHLivePhoto.self)
                                    #endif
                                }
                                
                                // Different file types
                                // Live Photo first (they return true when checked as standard image)
                                if checkIfProviderIsLivePhoto(provider) && keepLivePhotosIntact {
                                    // For some reason, PHLivePhoto is not supported in this way on macOS
                                    #if canImport(Cocoa) && os(macOS)
                                    return nil
                                    #else
                                    let livePhoto = try await provider.loadObject(ofClass: PHLivePhoto.self)
                                    return .livePhoto(fileName: provider.suggestedName, image: livePhoto)
                                    #endif
                                } else if provider.canLoadObject(ofClass: PHImage.self) {
                                    let image = try await provider.loadObject(ofClass: PHImage.self)
                                    return .photo(fileName: provider.suggestedName, image: image)
                                } else if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                                    // TODO: This path needs testing
                                    let videoURL = try await provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier)
                                    return .video(videoURL)
                                } else {
                                    print("Result can not be loaded as an image, a live photo, or a video:",
                                          result.assetIdentifier as Any)
                                    return nil
                                }
                            }
                        }
                        
                        return try await taskGroup
                            .compactMap { $0 }
                            .reduce(into: []) { $0.append($1) }
                    }
                } catch {
                    print("Error loading selections:", error as NSError)
                }
            }
        }
    }
}
