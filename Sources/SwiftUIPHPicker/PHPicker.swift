//
//  PHPicker.swift
//  
//
//  Created by Edon Valdman on 6/15/23.
//

import PhotosUI
import SwiftUI

public struct PHPicker {
    public init(image: Binding<Image?>, photoLibrary: PHPhotoLibrary? = nil, configuration: PHPickerConfiguration = PHPickerConfiguration()) {
        self._image = image
        self.photoLibrary = photoLibrary
        self.configuration = configuration
    }
    
    @Binding var image: Image?
    
    let photoLibrary: PHPhotoLibrary?
    
    private var configuration: PHPickerConfiguration
    
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
        
        #if canImport(UIKit)
        @available(iOS 14.0, *)
        public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { uiImage, _ in
                    if let image = uiImage as? UIImage {
                        DispatchQueue.main.async {
                            self.parent.image = Image(uiImage: image)
                        }
                    }
                }
            }
        }
        #endif
        
        #if canImport(Cocoa) && os(macOS)
        @available(macOS 13.0, *)
        public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.parent?.dismiss(picker)
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: NSImage.self) {
                provider.loadObject(ofClass: NSImage.self) { nsImage, _ in
                    if let image = nsImage as? NSImage {
                        self.parent.image = Image(nsImage: image)
                    }
                }
            }
        }
        #endif
    }
}
