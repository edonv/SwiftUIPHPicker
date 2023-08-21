//
//  PHSelectedObject.swift
//  
//
//  Created by Edon Valdman on 6/20/23.
//

import Foundation
import Photos

/// A container type for storing different types of resulting selections from ``PHPicker``.
public enum PHSelectedObject: Hashable {
    /// Contains a ``PHPicker/PHImage`` (which is just `NSImage` on macOS and `UIImage` on iOS/macCatalyst).
    case photo(fileName: String?, image: PHPicker.PHImage)
    
    /// Contains a [`PHLivePhoto`](https://developer.apple.com/documentation/photokit/phlivephoto).
    case livePhoto(fileName: String?, image: PHLivePhoto)
    
    /// Contains a `URL`, though this hasn't been fully tested yet.
    case video(URL)
}
