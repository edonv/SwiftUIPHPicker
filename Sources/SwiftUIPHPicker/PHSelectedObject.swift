//
//  PHSelectedObject.swift
//  
//
//  Created by Edon Valdman on 6/20/23.
//

import Foundation
import Photos

public enum PHSelectedObject {
    case photo(PHPicker.PHImage)
    case livePhoto(PHLivePhoto)
    case video(URL)
}
