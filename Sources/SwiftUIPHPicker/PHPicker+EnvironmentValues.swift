//
//  PHPicker+EnvironmentValues.swift
//
//
//  Created by Edon Valdman on 1/2/24.
//

import SwiftUI
import PhotosUI

// MARK: - PHPickerConfigurationEnvironmentKey

private struct PHPickerConfigurationEnvironmentKey: EnvironmentKey {
    static let defaultValue: PHPickerConfiguration = .init(photoLibrary: .shared())
}

extension EnvironmentValues {
    internal var phPickerConfiguration: PHPickerConfiguration {
        get { self[PHPickerConfigurationEnvironmentKey.self] }
        set { self[PHPickerConfigurationEnvironmentKey.self] = newValue }
    }
}

// MARK: - Video Destination

private struct PHPickerVideoDestinationEnvironmentKey: EnvironmentKey {
    static let defaultValue: ((URL) -> URL?)? = nil
}

extension EnvironmentValues {
    /// This value must be used in the case of a video being selected from the picker.
    ///
    /// When a video is loaded using `NSItemProvider`'s [`loadFileRepresentation(forTypeIdentifier:completionHandler:)`](https://developer.apple.com/documentation/foundation/nsitemprovider/2888338-loadfilerepresentation), the system saves the video to a temporary file. When leaving the scope of that function's `completionHandler`, the temporary file is deleted. In order to get that file, this property is used to map the temporary `URL` to a new `URL` that the file will be moved to before the temporary file is deleted.
    public var phPickerVideoDestination: ((URL) -> URL?)? {
        get { self[PHPickerVideoDestinationEnvironmentKey.self] }
        set { self[PHPickerVideoDestinationEnvironmentKey.self] = newValue }
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
    public func phPickerMaxSelectionCount(_ limit: Int?) -> some View {
        self.transformEnvironment(\.phPickerConfiguration) { config in
            config.selectionLimit = limit ?? 0
        }
    }
    
    /// Sets the selection behavior for the picker.
    /// - Parameter behavior: The new selection behavior for the picker.
    @available(iOS 15, macCatalyst 15, macOS 13, *)
    public func phPickerSelectionBehavior(_ behavior: PHPickerConfiguration.Selection) -> some View {
        self.transformEnvironment(\.phPickerConfiguration) { config in
            config.selection = behavior
        }
    }
    
    /// Sets the filter applied to restrict the asset types the picker displays.
    ///
    /// By default, a configuration object displays all asset types: images, Live Photos, and videos.
    /// - Parameter filter: The new filter applied to restrict the asset types the picker displays.
    public func phPickerFilter(_ filter: PHPickerFilter?) -> some View {
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
    public func phPickerPreferredAssetRepresentationMode(_ mode: PHPickerConfiguration.AssetRepresentationMode) -> some View {
        self.transformEnvironment(\.phPickerConfiguration) { config in
            config.preferredAssetRepresentationMode = mode
        }
    }
    
    /// This modifier (or <doc:/documentation/SwiftUIPHPicker/SwiftUI/View/phPickerVideoDestinationDirectory(_:)>) must be called in the case of a video being selected from the picker.
    ///
    /// When a video is loaded using `NSItemProvider`'s [`loadFileRepresentation(forTypeIdentifier:completionHandler:)`](https://developer.apple.com/documentation/foundation/nsitemprovider/2888338-loadfilerepresentation), the system saves the video to a temporary file. When leaving the scope of that function's `completionHandler`, the temporary file is deleted. In order to access the file before it's deleted, <doc:/documentation/SwiftUIPHPicker/SwiftUI/EnvironmentValues/phPickerVideoDestination> is used to map the temporary `URL` to a new `URL` that the file will be moved to before access is lost.
    ///
    /// - Note: If you want to keep the file name the same and just move it to a specific directory, you can use <doc:/documentation/SwiftUIPHPicker/SwiftUI/View/phPickerVideoDestinationDirectory(_:)>.
    /// - Parameter handler: A closure for mapping the temporary `URL` to a new `URL` where the video file should be saved.
    public func phPickerVideoDestination(_ handler: ((_ temporaryURL: URL) -> URL?)?) -> some View {
        self.environment(\.phPickerVideoDestination, handler)
    }
    
    /// This modifier (or <doc:/documentation/SwiftUIPHPicker/SwiftUI/View/phPickerVideoDestination(_:)>) must be called in the case of a video being selected from the picker.
    ///
    /// When a video is loaded using `NSItemProvider`'s [`loadFileRepresentation(forTypeIdentifier:completionHandler:)`](https://developer.apple.com/documentation/foundation/nsitemprovider/2888338-loadfilerepresentation), the system saves the video to a temporary file. When leaving the scope of that function's `completionHandler`, the temporary file is deleted. In order to access the file before it's deleted, <doc:/documentation/SwiftUIPHPicker/SwiftUI/EnvironmentValues/phPickerVideoDestination> is used to map the temporary `URL` to a new `URL` that the file will be moved to before access is lost.
    ///
    /// This modifier sets the destination `URL` to the temporary `URL`'s file name within the provided `directoryURL` parameter.
    ///
    /// - Note: If you want to generate a destination `URL` for videos differently, use <doc:/documentation/SwiftUIPHPicker/SwiftUI/View/phPickerVideoDestination(_:)>.
    /// - Parameter handler: A closure for mapping the temporary `URL` to a new `URL` where the video file should be saved.
    public func phPickerVideoDestinationDirectory(_ directoryURL: URL?) -> some View {
        self.phPickerVideoDestination { temporaryURL in
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
