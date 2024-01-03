//
//  PHPicker+PresentationModifier.swift
//  
//
//  Created by Edon Valdman on 1/2/24.
//

import SwiftUI
import PhotosUI

private struct PHPickerSheetModifier: ViewModifier {
    @Binding private var isPresented: Bool
    private var keepLivePhotosIntact: Bool
    private var onCompletion: (Result<[PHSelectedObject], Error>) -> Void
    
    fileprivate init(
        isPresented: Binding<Bool>,
        keepLivePhotosIntact: Bool,
        onCompletion: @escaping (Result<[PHSelectedObject], Error>) -> Void) {
            self._isPresented = isPresented
            self.keepLivePhotosIntact = keepLivePhotosIntact
            self.onCompletion = onCompletion
        }
    
    func body(content: Content) -> some View {
        content.sheet(isPresented: $isPresented) {
            PHPicker(keepLivePhotosIntact: false, onCompletion: onCompletion)
                .ignoresSafeArea()
        }
    }
}

extension View {
    /// Presents a Photos picker for choosing assets from the photo library.
    /// - Parameters:
    ///   - isPresented: A binding to whether the interface should be shown.
    ///   - keepLivePhotosIntact: When set to `true`, selected Live Photos are returned as a ``PHSelectedObject/livePhoto(fileName:image:)``. Otherwise, they're returned in the form of a ``PHSelectedObject/photo(fileName:image:)``.
    ///   - onCompletion: A callback that will be invoked when the operation has succeeded or failed.
    ///   - result: A `Result` indicating whether the operation succeeded or failed, containing selected items if successful.
    public func phPicker(
        isPresented: Binding<Bool>,
        keepLivePhotosIntact: Bool = true,
        onCompletion: @escaping (_ result: Result<[PHSelectedObject], Error>) -> Void
    ) -> some View {
        self.modifier(
            PHPickerSheetModifier(isPresented: isPresented,
                                  keepLivePhotosIntact: keepLivePhotosIntact,
                                  onCompletion: onCompletion)
        )
    }
}
