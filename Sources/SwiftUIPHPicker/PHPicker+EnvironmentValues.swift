//
//  PHPicker+EnvironmentValues.swift
//
//
//  Created by Edon Valdman on 1/2/24.
//

import SwiftUI
import PhotosUI

private struct PHPickerConfigurationEnvironmentKey: EnvironmentKey {
    static let defaultValue: PHPickerConfiguration = .init(photoLibrary: .shared())
}

extension EnvironmentValues {
    internal var phPickerConfiguration: PHPickerConfiguration {
        get { self[PHPickerConfigurationEnvironmentKey.self] }
        set { self[PHPickerConfigurationEnvironmentKey.self] = newValue }
    }
}

extension View {
    /// Sets the `PHPickerConfiguration` property of the specified key path to the given value.
    /// - Parameters:
    ///   - keyPath: A key path that indicates the property of the `PHPickerConfiguration` structure to update.
    ///   - value: The new value to set for the item specified by `keyPath`.
    public func phPickerConfiguration<V>(
        _ keyPath: WritableKeyPath<PHPickerConfiguration, V>,
        _ value: V
    ) -> some View {
        self.transformEnvironment(\.phPickerConfiguration) { config in
            config[keyPath: keyPath] = value
        }
    }
    
    /// Transforms the `PHPickerConfiguration` with the given function.
    public func phPickerTransformConfiguration(_ configurationHandler: @escaping (_ config: inout PHPickerConfiguration) -> Void) -> some View {
        self.transformEnvironment(\.phPickerConfiguration) { config in
            configurationHandler(&config)
        }
    }
    
    /// Sets the maximum number of selections the user can make.
    ///
    /// The default value is `1`. Setting the value to `0` or `nil` sets the selection limit to the maximum that the system supports.
    /// - Parameter limit: The new maximum number of selections the user can make.
    public func maxSelectionCount(_ limit: Int?) -> some View {
        self.transformEnvironment(\.phPickerConfiguration) { config in
            config.selectionLimit = limit ?? 0
        }
    }
    
    /// Sets the selection behavior for the picker.
    /// - Parameter behavior: The new selection behavior for the picker.
    @available(iOS 15, macCatalyst 15, macOS 13, *)
    public func selectionBehavior(_ behavior: PHPickerConfiguration.Selection) -> some View {
        self.transformEnvironment(\.phPickerConfiguration) { config in
            config.selection = behavior
        }
    }
    
    /// Sets the filter applied to restrict the asset types the picker displays.
    ///
    /// By default, a configuration object displays all asset types: images, Live Photos, and videos.
    /// - Parameter filter: The new filter applied to restrict the asset types the picker displays.
    public func filter(_ filter: PHPickerFilter?) -> some View {
        self.transformEnvironment(\.phPickerConfiguration) { config in
            config.filter = filter
        }
    }
    
    /// Sets the mode that determines which representation to use if an asset contains more than one.
    ///
    /// An asset can contain many representations under the same uniform type identifier, or you can prefer a specific format. This mode determines which representation an [`NSItemProvider`](https://developer.apple.com/documentation/foundation/nsitemprovider) uses if many exist.
    ///
    /// The system may perform additional transcoding to convert the asset you request to the compatable representation. Use [`PHPickerConfiguration.AssetRepresentationMode.current`](https://developer.apple.com/documentation/photokit/phpickerconfiguration/assetrepresentationmode/current) to avoid transcoding, if possible.
    /// - Parameter mode: The new mode that determines which representation to use if an asset contains more than one.
    public func preferredAssetRepresentationMode(_ mode: PHPickerConfiguration.AssetRepresentationMode) -> some View {
        self.transformEnvironment(\.phPickerConfiguration) { config in
            config.preferredAssetRepresentationMode = mode
        }
    }
}
