<img src="https://raw.githubusercontent.com/exyte/media/master/common/header.png">

<p><h1 align="left">Media Picker</h1></p>

<p><h4>SwiftUI library for a customizable media picker.</h4></p>

<img src="https://raw.githubusercontent.com/exyte/media/master/MediaPicker/banner.png" />

___

<p> We are a development agency building
  <a href="https://clutch.co/profile/exyte#review-731233?utm_medium=referral&utm_source=github.com&utm_campaign=phenomenal_to_clutch">phenomenal</a> apps.</p>

</br>

<a href="https://exyte.com/contacts"><img src="https://i.imgur.com/vGjsQPt.png" width="134" height="34"></a> <a href="https://twitter.com/exyteHQ"><img src="https://i.imgur.com/DngwSn1.png" width="165" height="34"></a>

</br>

[![Twitter](https://img.shields.io/badge/Twitter-@exyteHQ-blue.svg?style=flat)](http://twitter.com/exyteHQ)
[![Version](https://img.shields.io/cocoapods/v/ExyteMediaPicker.svg?style=flat)](http://cocoapods.org/pods/ExyteMediaPicker)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-0473B3.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/ExyteMediaPicker.svg?style=flat)](http://cocoapods.org/pods/ExyteMediaPicker)
[![Platform](https://img.shields.io/cocoapods/p/ExyteMediaPicker.svg?style=flat)](http://cocoapods.org/pods/ExyteMediaPicker)

# Features
* Photo and video picker
* Single and multiple selection
* Full-screen view
* Live photo preview & capture
* Full customization

# MediaPicker vs PhotosPicker
* The iOS 16 PhotosPicker only provides you with a button, while this library gives you the whole view, meaning you can build it into you own screens and customize it as you see fit. 
* PhotosPicker only lets you pick photos from the library - no camera. 
* MediaPicker provides a default looking library picker, with ability to manage albums, and also a camera view to take photos (the ability to capture videos is coming very soon)

# Usage
1. Add a binding Bool to control the picker presentation state.
2. Add Media array to save selection (`[Media]`).
3. Initialize the media picker and present it however you like - for example, using the .sheet modifier
    ```swift
        .sheet(isPresented: $showMediaPicker) {
            MediaPicker(
                isPresented: $showMediaPicker,
                onChange: { medias = $0 }
            )
        }
    ```

### Screen rotation
If your app restricts screen rotation, you can skip this section.

We recommend locking orientation for MediaPicker, because default rotation animations don't look good on the camera screen. At the moment SwiftUI doesn't provide a way of locking screen orientation, so the library has an initializer with an `orientationHandler` parameter - a closure that is called when you enter/leave the camera screen inside MediaPicker. In this closure you need to use AppDelegate to lock/unlock the rotation - see example project for implementation.

### Init required parameters
`isPresented` - a binding to determine whether the picker should be seen or hidden   
`onChange` - a closure that returns the selected media every time the selection changes

### Init optional parameters
`limit` - the maximum selection quantity allowed, 'nil' for unlimited selection

### Available modifiers
`selectionStyle` - a way to display selected/unselected media state: either a counter or a simple checkmark         
`showingLiveCameraCell` - show live camera feed cell in the top left corner of the gallery grid     
`theme` - color settings. Example usage (see `MediaPickerTheme` for all available settings):    
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
Here is an example of how you can customize colors and elements to create a custom looking picker:  

<img src="https://raw.githubusercontent.com/exyte/media/master/MediaPicker/1.jpg" width="250"/>

### Available modifiers: managing albums
`showingDefaultHeader` - the default header contains the 'Done' and 'Cancel' buttons, and a simple switcher between Photos and Albums. Use it for a basic  out-of-the box picker (see default picker in example project for an implementation example)     
`albums` - a list of user's albums (like in Photos app), if you want to display them differently than `showingDefaultHeader` does.           
`pickerMode` - set this if you don't plan to use the default header. Available options are:     
    .photos - displays the default photos grid      
    .albums - displays a list of albums with one preview photo for each
    .album(Album) - displays one album      
(see the custom picker in the example project for implementation)

### Camera
After making one photo, you see a preview of your and a little plus icon, by tapping it you return back to camera mode and can continue making as many photos as you like. Press "Done" once you're finished and you will be able to scroll through all the photos you've taken before confirming you'd like to user them.     

<img src="https://raw.githubusercontent.com/exyte/media/master/MediaPicker/2.jpg" width="250"/>

## Examples

To try out the MediaPicker examples:
- Clone the repo `https://github.com/exyte/MediaPicker.git`
- Open `Examples/Examples.xcworkspace` in the Xcode
- Run it!

## Installation

### [Swift Package Manager](https://swift.org/package-manager/)

```swift
dependencies: [
    .package(url: "https://github.com/exyte/MediaPicker.git")
]
```

### CocoaPods

```ruby
pod 'ExyteMediaPicker'
```

### Carthage

```ogdl
github "Exyte/MediaPicker"
```

## Requirements

* iOS 15+
* Xcode 13+ 

## Our other open source SwiftUI libraries
[PopupView](https://github.com/exyte/PopupView) - Toasts and popups library    
[Grid](https://github.com/exyte/Grid) - The most powerful Grid container    
[ScalingHeaderScrollView](https://github.com/exyte/ScalingHeaderScrollView) - A scroll view with a sticky header which shrinks as you scroll.    
[ConcentricOnboarding](https://github.com/exyte/ConcentricOnboarding) - Animated onboarding flow    
[FloatingButton](https://github.com/exyte/FloatingButton) - Floating button menu    
[ActivityIndicatorView](https://github.com/exyte/ActivityIndicatorView) - A number of animated loading indicators    
[ProgressIndicatorView](https://github.com/exyte/ProgressIndicatorView) - A number of animated progress indicators    
[SVGView](https://github.com/exyte/SVGView) - SVG parser    
[LiquidSwipe](https://github.com/exyte/LiquidSwipe) - Liquid navigation animation    
