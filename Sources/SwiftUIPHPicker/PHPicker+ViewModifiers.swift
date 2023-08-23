//
//  PHPicker+ViewModifiers.swift
//  
//
//  Created by Edon Valdman on 6/19/23.
//

import PhotosUI
import SwiftUI

extension PHPicker {
    /// Sets the maximum number of selections the user can make.
    ///
    /// The default value is `1`. Setting the value to `0` sets the selection limit to the maximum that the system supports.
    /// - Parameter limit: The new maximum number of selections the user can make.
    /// - Returns: A ``PHPicker`` with an updated selection limit.
    public func maxSelectionCount(_ limit: Int?) -> PHPicker {
        configuration { $0.selectionLimit = limit ?? 0 }
    }
    
    /// Sets the selection behavior for the picker.
    /// - Parameter behavior: The new selection behavior for the picker.
    /// - Returns: A ``PHPicker`` with an updated selection behavior.
    @available(iOS 15, macCatalyst 15, macOS 13, *)
    public func selectionBehavior(_ behavior: PHPickerConfiguration.Selection) -> PHPicker {
        configuration { $0.selection = behavior }
    }
    
    /// Sets the filter applied to restrict the asset types the picker displays.
    ///
    /// By default, a configuration object displays all asset types: images, Live Photos, and videos.
    /// - Parameter filter: The new filter applied to restrict the asset types the picker displays.
    /// - Returns: A ``PHPicker`` with an updated filter.
    public func filter(_ filter: PHPickerFilter?) -> PHPicker {
        configuration { $0.filter = filter }
    }
    
    /// Sets the mode that determines which representation to use if an asset contains more than one.
    ///
    /// An asset can contain many representations under the same uniform type identifier, or you can prefer a specific format. This mode determines which representation an [`NSItemProvider`](https://developer.apple.com/documentation/foundation/nsitemprovider) uses if many exist.
    ///
    /// The system may perform additional transcoding to convert the asset you request to the compatable representation. Use [`PHPickerConfiguration.AssetRepresentationMode.current`](https://developer.apple.com/documentation/photokit/phpickerconfiguration/assetrepresentationmode/current) to avoid transcoding, if possible.
    /// - Parameter mode: The new mode that determines which representation to use if an asset contains more than one.
    /// - Returns: A ``PHPicker`` with an updated preferred asset representation mode.
    public func preferredAssetRepresentationMode(_ mode: PHPickerConfiguration.AssetRepresentationMode) -> PHPicker {
        configuration { $0.preferredAssetRepresentationMode = mode }
    }
    
    /// Sets the asset identifiers to preselect in the picker.
    ///
    /// Preselection works only when initializing a [`PHPickerConfiguration`](https://developer.apple.com/documentation/photokit/phpickerconfiguration) object with a photo library. Otherwise, the system returns an error.
    ///
    /// The number of preselected asset identifiers can exceed your selection limit. The system disables the done action until the selection count becomes lower than [`selectionLimit`](https://developer.apple.com/documentation/photokit/phpickerconfiguration/3606592-selectionlimit).
    ///
    /// Additionally, when providing preselected identifiers:
    /// - Results include all preselected identifiers when canceling the picker.
    /// - Results don’t include item providers for preselected assets that remain selected.
    /// - When deselecting all assets, the system keeps the done action enabled.
    /// - Parameter identifiers: The asset identifiers to preselect in the picker.
    /// - Returns: A ``PHPicker`` with asset identifiers set to be preselected.
    @available(iOS 15, macCatalyst 15, macOS 13, *)
    public func preselectedAssetIdentifiers(_ identifiers: [String]) -> PHPicker {
        configuration { $0.preselectedAssetIdentifiers = identifiers }
    }
    
    /// This modifier (or ``setVideoDestinationDirectory(_:)``) must be called in the case of a video being selected from the picker.
    ///
    /// When a video is loaded using `NSItemProvider`'s [`loadFileRepresentation(forTypeIdentifier:completionHandler:)`](https://developer.apple.com/documentation/foundation/nsitemprovider/2888338-loadfilerepresentation), the system saves the video to a temporary file. When leaving the scope of that function's `completionHandler`, the temporary file is deleted. In order to get that file, ``videoDestinationHandler`` is used to map the temporary `URL` to a new `URL` that the file will be moved to before the temporary file is deleted.
    ///
    /// - Note: If you want to keep the file name the same and just move it to a specific directory, you can use ``videoDestinationDirectory(_:)``.
    /// - Parameter handler: A closure for mapping the temporary `URL` to a new `URL` where the video file should be saved.
    public func videoDestinationHandler(_ handler: ((URL) -> URL?)?) -> PHPicker {
        var newView = self
        newView.videoDestinationHandler = handler
        return newView
    }
    
    /// This modifier (or ``videoDestinationHandler(_:)``) must be called in the case of a video being selected from the picker.
    ///
    /// When a video is loaded using `NSItemProvider`'s [`loadFileRepresentation(forTypeIdentifier:completionHandler:)`](https://developer.apple.com/documentation/foundation/nsitemprovider/2888338-loadfilerepresentation), the system saves the video to a temporary file. When leaving the scope of that function's `completionHandler`, the temporary file is deleted. In order to get that file, ``videoDestinationHandler`` is used to map the temporary `URL` to a new `URL` that the file will be moved to before the temporary file is deleted.
    ///
    /// This modifier sets the destination `URL` to the temporary `URL`'s file name within the provided `directoryURL` parameter.
    ///
    /// - Note: If you want to generate a destination `URL` for videos differently, use ``videoDestinationHandler(_:)``.
    /// - Parameter handler: A closure for mapping the temporary `URL` to a new `URL` where the video file should be saved.
    public func videoDestinationDirectory(_ directoryURL: URL?) -> PHPicker {
        self.videoDestinationHandler { temporaryURL in
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
