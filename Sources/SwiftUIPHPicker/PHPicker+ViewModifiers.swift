//
//  PHPicker+ViewModifiers.swift
//  
//
//  Created by Edon Valdman on 6/19/23.
//

import PhotosUI
import SwiftUI

extension View where Self == PHPicker {
    /// Allows for configuration of the ``PHPicker``.
    /// - Parameter configuration: A new [`PHPickerConfiguration`](https://developer.apple.com/documentation/photokit/phpickerconfiguration).
    /// - Returns: A new ``PHPicker`` with the provided configuration.
    public func withConfiguration(_ configuration: PHPickerConfiguration) -> PHPicker {
        var newView = self
        newView.setConfiguration(configuration)
        return newView
    }
    
    /// Allows for configuration of the ``PHPicker``.
    /// - Parameter configurationHandler: A closure for creating a [`PHPickerConfiguration`](https://developer.apple.com/documentation/photokit/phpickerconfiguration).
    /// - Returns: A new ``PHPicker`` with the provided configuration.
    public func withConfiguration(_ configurationHandler: () -> PHPickerConfiguration) -> PHPicker {
        self.withConfiguration(configurationHandler())
    }
}
