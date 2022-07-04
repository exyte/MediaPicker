<img src="https://raw.githubusercontent.com/exyte/media/master/common/header.png">

<p><h1 align="left">Media Picker</h1></p>

<p><h4>Media picker written with SwiftUI</h4></p>

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
1. Add a binding bool to control popup presentation state
1. Add `.popup` modifier to your view
```swift
struct ContentView: View {

    @State var isPresented = false

    var body: some View {
        MediaPicker(isPresented: $isPresented)
            .selectionStyle(.count)
            .selectionLimit(3)
            .onChangeSelection { medias in
                <...>
            }
    }
}
```

### Required parameters 
`isPresented` - binding to determine if the picker should be seen on screen or hidden   
`onChangeSelection` - closure returning picked media every time selection changes   
`onFinishSelection` - closure returning picked media once the screen is closed  

### Available customizations - optional parameters     
`selectionStyle` - a way to display selected/unselected media state: either a counter or just a checkmark  
`selectionLimit` - max allowed media quantity to select     

## Examples

To try MediaPicker examples:
- Clone the repo `https://github.com/exyte/MediaPicker.git`
- Open terminal and run `cd <MediaPickerRepo>/Example/`
- Run `pod install` to install all dependencies
- Run open `MediaPickerExample.xcworkspace/` to open project in the Xcode
- Try it!

## Installation

### [CocoaPods](http://cocoapods.org)

To install `MediaPicker`, simply add the following line to your Podfile:

```ruby
pod 'ExyteMediaPicker'
```

### [Carthage](http://github.com/Carthage/Carthage)

To integrate `MediaPicker` into your Xcode project using Carthage, specify it in your `Cartfile`

```ogdl
github "Exyte/MediaPicker"
```

### [Swift Package Manager](https://swift.org/package-manager/)

```swift
dependencies: [
    .package(url: "https://github.com/exyte/MediaPicker.git", from: "1.0.0")
]
```

### Manually

Drop [MediaPicker.swift](https://github.com/exyte/MediaPicker/blob/master/Source/MediaPicker.swift) in your project.

## Requirements

* iOS 16+
* Xcode 14+ 
