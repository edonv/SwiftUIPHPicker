//
//  PHPicker.swift
//  
//
//  Created by Edon Valdman on 6/15/23.
//

import PhotosUI
import SwiftUI

public struct PHPicker {
    @Binding var selections: [Data]
    private(set) var configuration: PHPickerConfiguration
    
    public init(selections: Binding<[Data]>, photoLibrary: PHPhotoLibrary? = nil) {
        self._selections = selections
        if let photoLibrary {
            self.configuration = PHPickerConfiguration(photoLibrary: photoLibrary)
        } else {
            self.configuration = PHPickerConfiguration()
        }
    }
    
    public init(selections: Binding<[Data]>, photoLibrary: PHPhotoLibrary? = nil, configurationHandler: (_ config: inout PHPickerConfiguration) -> Void) {
        self._selections = selections
        if let photoLibrary {
            self.configuration = PHPickerConfiguration(photoLibrary: photoLibrary)
        } else {
            self.configuration = PHPickerConfiguration()
        }
        configurationHandler(&configuration)
    }
    
    public init(selections: Binding<[Data]>, configuration: PHPickerConfiguration) {
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
        
//        #if canImport(UIKit)
//        @available(iOS 14.0, *)
        public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            #if canImport(UIKit) && (os(iOS) || targetEnvironment(macCatalyst))
            picker.dismiss(animated: true)
            #endif
            
            #if canImport(Cocoa) && os(macOS)
            picker.parent?.dismiss(picker)
            #endif
            
            Task {
                await self.parent.selections = self.decodeResults(results)
            }
        }
//        #endif

//        #if canImport(Cocoa) && os(macOS)
//        @available(macOS 13.0, *)
//        public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//            picker.parent?.dismiss(picker)
//
//            guard let provider = results.first?.itemProvider else { return }
//
//            if provider.canLoadObject(ofClass: NSImage.self) {
//                provider.loadObject(ofClass: NSImage.self) { nsImage, _ in
//                    if let image = nsImage as? NSImage {
//                        self.parent.image = Image(nsImage: image)
//                    }
//                }
//            }
//        }
//        #endif
        
        /// https://christianselig.com/2020/09/phpickerviewcontroller-efficiently/
        private func decodeResults(_ results: [PHPickerResult]) async -> [Data] {
//            let dispatchQueue = DispatchQueue(label: "com.ValdmanWorks.SwiftUIPHPicker.ImageSelectionQueue")
            var selectedImageDataArr = [Data?](repeating: nil, count: results.count)
            var totalConversionsCompleted = 0
            
            for (index, result) in results.enumerated() {
                do {
                    let url = try await result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier)
                    
                    //                result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { (url, error) in
//                    guard let url else {
//                        dispatchQueue.sync { totalConversionsCompleted += 1 }
//                        return
//                    }
                    
                    let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
                    
                    guard let source = CGImageSourceCreateWithURL(url as CFURL, sourceOptions) else {
//                        dispatchQueue.sync {
                        totalConversionsCompleted += 1
//                        }
//                        return
                        continue
                    }
                    
                    let downsampleOptions = [
                        kCGImageSourceCreateThumbnailFromImageAlways: true as Any,
                        kCGImageSourceCreateThumbnailWithTransform: true as Any,
                        kCGImageSourceThumbnailMaxPixelSize: 2_000 as Any,
                    ] as CFDictionary
                    
                    guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, downsampleOptions) else {
//                        dispatchQueue.sync {
                        totalConversionsCompleted += 1
//                        }
//                        return
                        continue
                    }
                    
                    let data = NSMutableData()
                    
                    guard let imageDestination = CGImageDestinationCreateWithData(data, UTType.jpeg.identifier as CFString, 1, nil) else {
//                        dispatchQueue.sync {
                        totalConversionsCompleted += 1
//                        }
//                        return
                        continue
                    }
                    
                    // Don't compress PNGs
                    let isPNG: Bool = {
                        guard let utType = cgImage.utType else { return false }
                        return (utType as String) == UTType.png.identifier
                    }()
                    
                    let destinationProperties = [
                        kCGImageDestinationLossyCompressionQuality: isPNG ? 1.0 : 0.75
                    ] as CFDictionary
                    
                    CGImageDestinationAddImage(imageDestination, cgImage, destinationProperties)
                    CGImageDestinationFinalize(imageDestination)
                    
//                    dispatchQueue.sync {
                        selectedImageDataArr[index] = data as Data
                        totalConversionsCompleted += 1
//                    }
//                }
                } catch {
                    totalConversionsCompleted += 1
                }
            }
            
//            return dispatchQueue.sync {
            return selectedImageDataArr.compactMap { $0 }
//            }
        }
    }
}
