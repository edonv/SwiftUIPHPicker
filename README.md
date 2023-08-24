# SwiftUIPHPicker

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fedonv%2FSwiftUIPHPicker%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/edonv/SwiftUIPHPicker)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fedonv%2FSwiftUIPHPicker%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/edonv/SwiftUIPHPicker)

`SwiftUI` wrapper of [`PhotoKit`](https://developer.apple.com/documentation/photokit)'s [`PHPickerViewController`](https://developer.apple.com/documentation/photokit/phpickerviewcontroller).  

The majority of the base of the code came from Hacking With Swift's post on this very topic: <https://www.hackingwithswift.com/books/ios-swiftui/importing-an-image-into-swiftui-using-phpickerviewcontroller>.

I added support for more than 1 selection, as well as practical extensions, and hope to extend for ease-of-use with [`PhotosPicker`](https://developer.apple.com/documentation/photokit/photospicker), which is only available in iOS 16+.

## To-Do's
- [x] Add support for multiple selections.
- [ ] Add support for selecting other Live Photos (currently only supports standard photos).
- [ ] Add support for videos.
  - Currently, this works but requires the developer to use `videoDestination` or `videoDestinationDirectory`. Would it be better to just internally save it to the temporary directory and return that and require that they clean it up after?

## Usage

```swift
import SwiftUI
import SwiftUIPHPicker

struct ContentView: View {
    @State private var showPicker = false
    @State private var pickerSelection = [PHSelectedObject]()
    
    var body: some View {
        Text("Hello world!")
            .sheet(isPresented: $showPicker) {
                PHPicker(selections: $pickerSelection, photoLibrary: .shared())
                    .maxSelectionCount(5)
                    .filter(.all(of: [.images, .not(.livePhotos), .videos]))
                    .videoDestinationDirectory(DOCUMENT DIRECTORY) /* more code needed for this */
            }
    }
}
```

### Notes

- If you'd like to support video selections, then you *must* use either the `setVideoDestinationDirectory(_:)` or `setVideoDestinationHandler(_:)` view modifier. Without them, there won't be somewhere set to save the video file and the system's temporary file will be be deleted before it's accessible.
