//
//  PHImage.swift
//  
//
//  Created by Edon Valdman on 6/20/23.
//

#if canImport(UIKit)
import UIKit

extension PHPicker {
    public typealias PHImage = UIImage
}
#endif

#if canImport(Cocoa) && os(macOS)
import Cocoa

extension PHPicker {
    public typealias PHImage = NSImage
}
#endif
