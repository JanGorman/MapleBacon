# MapleBacon

[![Build Status](https://travis-ci.org/JanGorman/MapleBacon.svg?branch=reboot)](https://travis-ci.org/JanGorman/MapleBacon)
[![codecov.io](https://codecov.io/github/JanGorman/MapleBacon/coverage.svg?branch=master)](https://codecov.io/github/JanGorman/MapleBacon?branch=reboot)
[![Version](https://img.shields.io/cocoapods/v/MapleBacon.svg?style=flat)](http://cocoapods.org/pods/MapleBacon)
[![License](https://img.shields.io/cocoapods/l/MapleBacon.svg?style=flat)](http://cocoapods.org/pods/MapleBacon)
[![Platform](https://img.shields.io/cocoapods/p/MapleBacon.svg?style=flat)](http://cocoapods.org/pods/MapleBacon)

## Reboot

This branch is work in progress. 

- Reduces the API surface area of MapleBacon
- Speed
- Smarter defaults
- Better progress reporting
- Image processing pipeline

## Example

The folder `Example` contains a sample project for you to try.

## Requirements

- Swift 4
- iOS 9.3+
- Xcode 9+

## Installation

MapleBacon is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MapleBacon"
```

## Usage

### UIImageView

The most basic usage is via an extension on `UIImageView`. You pass it a URL:

```swift
import MapleBacon

private var imageView: UIImageView!

func someFunc() {
  let url = URL(string: "…")
  imageView.setImage(url)
}
```

Just loading images is a little bit boring. Instead of just passing the URL you can also provide a placeholder, a progress handler that informs you about the download progress and a completion handler for any additional processing. Each of these parameters is optional, opt in to what you need:

```swift
func someFunc() {
  let url = URL(string: "…")
  imageView.setImage(url, placeholder: UIImage(named: "placeholder"), progress: { received, total in
    // Report progress
  }, completion: { [weak self] image in
    // Do something else with the image
  })

}
```

### UIButton

MapleBacon also comes with an extension on `UIButton` that works similar to the image view. The only additional parameter is the `UIControlState` that the images is for:

```swift
import MapleBacon

@IBOutlet private var button: UIButton! {
  didSet {
    let normalUrl = URL(string: "…")
    button.setImage(with: normalUrl, for: .normal)
    let selectedUrl = URL(string: "…")
    button.setImage(with: selectedUrl, for: .selected)
  }
}
```

And just like the `UIImageView` extension you can also pass in a progress and completion handler.

## License

MapleBacon is available under the MIT license. See the LICENSE file for more info.
