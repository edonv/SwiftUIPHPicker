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
        selection: Binding<[PHPicker.PHImage]>,
        maxSelectionCount: Int? = nil,
        matching filter: PHPickerFilter? = nil,
        preferredAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode = .automatic,
        photoLibrary: PHPhotoLibrary,
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        self
            .sheet(isPresented: isPresented, onDismiss: onDismiss) {
                PHPicker(selections: selection, photoLibrary: photoLibrary) { config in
                    config.selectionLimit = maxSelectionCount ?? 0
                    config.filter = filter
                    config.preferredAssetRepresentationMode = preferredAssetRepresentationMode
                }
            }
    }
    
    @available(iOS 15, macCatalyst 15, macOS 13, *)
    public func phPicker(
        isPresented: Binding<Bool>,
        selection: Binding<[PHPicker.PHImage]>,
        maxSelectionCount: Int? = nil,
        selectionBehavior: PHPickerConfiguration.Selection = .default,
        matching filter: PHPickerFilter? = nil,
        preferredAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode = .automatic,
        photoLibrary: PHPhotoLibrary,
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        self
            .sheet(isPresented: isPresented, onDismiss: onDismiss) {
                PHPicker(selections: selection, photoLibrary: photoLibrary) { config in
                    config.selectionLimit = maxSelectionCount ?? 0
                    config.selection = selectionBehavior
                    config.filter = filter
                    config.preferredAssetRepresentationMode = preferredAssetRepresentationMode
                }
            }
    }
}

extension View where Self == PHPicker {
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
}
