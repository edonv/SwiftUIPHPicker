//
//  PHPicker.swift
//  
//
//  Created by Edon Valdman on 6/15/23.
//

import PhotosUI
import SwiftUI

public struct PHPicker {
    @Binding var selections: [PHImage]
    private(set) var configuration: PHPickerConfiguration
    
    public init(selections: Binding<[PHImage]>, photoLibrary: PHPhotoLibrary? = nil) {
        self._selections = selections
        if let photoLibrary {
            self.configuration = PHPickerConfiguration(photoLibrary: photoLibrary)
        } else {
            self.configuration = PHPickerConfiguration()
        }
    }
    
    public init(selections: Binding<[PHImage]>, photoLibrary: PHPhotoLibrary? = nil, configurationHandler: (_ config: inout PHPickerConfiguration) -> Void) {
        self._selections = selections
        if let photoLibrary {
            self.configuration = PHPickerConfiguration(photoLibrary: photoLibrary)
        } else {
            self.configuration = PHPickerConfiguration()
        }
        configurationHandler(&configuration)
    }
    
    public init(selections: Binding<[PHImage]>, configuration: PHPickerConfiguration) {
        self._selections = selections
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
    public typealias PHImage = UIImage
    
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
    public typealias PHImage = NSImage
    
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
            Task {
                do {
                    parent.selections = try await withThrowingTaskGroup(of: PHImage.self, returning: [PHImage].self) { taskGroup in
                        for result in results {
                            taskGroup.addTask { try await result.itemProvider.loadObject(ofClass: PHImage.self) }
                        }
                        
                        return try await taskGroup.reduce(into: []) { $0.append($1) }
                    }
                } catch {
                    print("Error loading selections:", error as NSError)
                }
            }
        }
    }
}
