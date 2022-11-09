<img src="https://raw.githubusercontent.com/exyte/media/master/common/header.png">

<p><h1 align="left">Media Picker</h1></p>

<p><h4>SwiftUI library for customizable media picker. New Apple picker only gives you a button, this library gives you the whole view, meaning you can build it into you own screens as you see fit. MediaPicker provides a default looking library picker, with ability to manage albums, and also a camera view to take photos (video is coming)</h4></p>

___

<p> We are a development agency building
  <a href="https://clutch.co/profile/exyte#review-731233?utm_medium=referral&utm_source=github.com&utm_campaign=phenomenal_to_clutch">phenomenal</a> apps.</p>

</br>

<a href="https://exyte.com/contacts"><img src="https://i.imgur.com/vGjsQPt.png" width="134" height="34"></a> <a href="https://twitter.com/exyteHQ"><img src="https://i.imgur.com/DngwSn1.png" width="165" height="34"></a>

</br></br>

[![Twitter](https://img.shields.io/badge/Twitter-@exyteHQ-blue.svg?style=flat)](http://twitter.com/exyteHQ)
[![Version](https://img.shields.io/cocoapods/v/ExyteMediaPicker.svg?style=flat)](http://cocoapods.org/pods/ExyteMediaPicker)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-0473B3.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/ExyteMediaPicker.svg?style=flat)](http://cocoapods.org/pods/ExyteMediaPicker)
[![Platform](https://img.shields.io/cocoapods/p/ExyteMediaPicker.svg?style=flat)](http://cocoapods.org/pods/ExyteMediaPicker)

# Usage
1. Add a binding bool to control picker presentation state
2. Add medias array to save selection (`[Media]`)
3. Init media picker and show it however you like, for example you can use .sheet
    ```swift
        .sheet(isPresented: $showMediaPicker) {
            MediaPicker(
                isPresented: $showMediaPicker,
                onChange: { medias = $0 }
            )
        }
    ```

### Screen rotation
If your app forbids screen rotation, you don't need this section.
We recommend that you lock orientation for MediaPicker, because default rotation animation doesn't look good on camera screen. At the moment SwiftUI doesn't have a way of locking screen orientation, so you can use AppDelegate for now. There is an init variant with `orientationHandler` parameter - that is a closure getting called when you enter/leave camera screen inside MediaPicker. In this closure use your AppDelegate to lock/unlock rotation - see example project for implementation.

### Init required parameters
`isPresented` - binding to determine if the picker should be seen on screen or hidden   
`onChange` - closure returning picked media every time selection changes

### Init optional parameters
`limit` - max allowed media quantity to select, 'nil' means unlimited    

### Available modifiers
`selectionStyle` - a way to display selected/unselected media state: either a counter or just a checkmark         
`showingLiveCameraCell` - Show live camera feed cell in top left corner of gallery greed     
`theme` - color settings. Use like this (See `MediaPickerTheme` for all available settings):    
  ```swift
MediaPicker(...)
    .mediaPickerTheme(
        main: .init(
            background: .black
        ),
        selection: .init(
            emptyTint: .white,
            emptyBackground: .black.opacity(0.25),
            selectedTint: Color("CustomPurple")
        )
    )
    ```

### Available modifiers: managing albums
`showingDefaultHeader` - Default header contains 'Done' and 'Cancel' button, and a simple switcher: Photos/Albums. Use it if you just wany out-of-the box picker (see default picker in example project for implementation)     
`albums` - List of user's albums (like in Photos app), if you want to display them differently than `showingDefaultHeader` does.           
`pickerMode` - Set this if you do not use the default header. Available options are:     
    .photos - displays default photos grid      
    .albums - displays list of albums with one preview photo for each
    .album(Album) - displays one album      
(see custom picker in example project for implementation)

## Examples

To try MediaPicker examples:
- Clone the repo `https://github.com/exyte/MediaPicker.git`
- Open `Examples/Examples.xcworkspace` in the Xcode
- Try it!

## Installation
### [Swift Package Manager](https://swift.org/package-manager/)

```swift
dependencies: [
    .package(url: "https://github.com/exyte/MediaPicker.git")
]
```

## Requirements

* iOS 15+
* Xcode 13+ 
