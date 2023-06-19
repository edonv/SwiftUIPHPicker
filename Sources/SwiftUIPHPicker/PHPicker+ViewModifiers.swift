//
//  PHPicker+ViewModifiers.swift
//  
//
//  Created by Edon Valdman on 6/19/23.
//

import PhotosUI
import SwiftUI

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
