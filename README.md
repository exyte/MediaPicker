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
2. Add medias array to save selection (`[Media]`)
3. Add modifier to your view
    ```swift
        .mediaPicker(isPresented: $<showPicker>, onChange: { <mediasArray> = $0 })
    ```
    or
    ```swift
        .sheet(isPresented: $<showPicker>) {
            MediaPicker(isPresented: $<showPicker>, onChange: { medias = $0 })
        }
    ```

### Init required parameters
`isPresented` - binding to determine if the picker should be seen on screen or hidden   
`onChange` - closure returning picked media every time selection changes

### Init optional parameters
`limit` - max allowed media quantity to select   
`leadingNavigation` and `trailingNavigation` - ViewBuilder for leading and trailing navigation items respectively   

### Available customizations - modifiers
`selectionStyle` - a way to display selected/unselected media state: either a counter or just a checkmark   

## Examples

To try MediaPicker examples:
- Clone the repo `https://github.com/exyte/MediaPicker.git`
- Open `Example/MediaPickerExample.xcworkspace` in the Xcode
- Try it!

## Installation
### [Swift Package Manager](https://swift.org/package-manager/)

```swift
dependencies: [
    .package(url: "https://github.com/exyte/MediaPicker.git", from: "1.0.0")
]
```

## Requirements

* iOS 15+
* Xcode 13+ 
