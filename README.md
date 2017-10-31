# MapleBacon

[![Build Status](https://travis-ci.org/JanGorman/MapleBacon.svg)](https://travis-ci.org/JanGorman/MapleBacon)
[![codecov.io](https://codecov.io/github/JanGorman/MapleBacon/coverage.svg)](https://codecov.io/github/JanGorman/MapleBacon)
[![Version](https://img.shields.io/cocoapods/v/MapleBacon.svg?style=flat)](http://cocoapods.org/pods/MapleBacon)
[![License](https://img.shields.io/cocoapods/l/MapleBacon.svg?style=flat)](http://cocoapods.org/pods/MapleBacon)
[![Platform](https://img.shields.io/cocoapods/p/MapleBacon.svg?style=flat)](http://cocoapods.org/pods/MapleBacon)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

<p align="center"><img src="https://www.dropbox.com/s/mlquw9k6ogvspox/MapleBacon.png?raw=1" height="210"/></p>

## Reboot

Migrating from an older version? Check out the [Migration Guide](https://github.com/JanGorman/MapleBacon/wiki/Migration-Guide-Version-4-→-Version-5).

## Example

The folder `Example` contains a sample project for you to try.

## Requirements

- Swift 4
- iOS 9.0+
- Xcode 9+

## Installation

MapleBacon is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MapleBacon"
```

As well as [Carthage](https://github.com/Carthage/Carthage) / [punic](https://github.com/schwa/punic):

```ogdl
github "JanGorman/MapleBacon"
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

### Image Transformers

MapleBacon allows you to apply transformations to images and have the results cached so that you app doesn't need to perform the same work over and over. To make your own transformer, create a class conforming to the `ImageTransformer` protocol. A transform can be anything you like, let's create one that applies a Core Image sepia filter:

```swift
private class SepiaImageTransformer: ImageTransformer {

  // The identifier is used as part of the cache key. Make sure it's something unique
  let identifier = "com.schnaub.SepiaImageTransformer"

  func transform(image: UIImage) -> UIImage? {
    guard let filter = CIFilter(name: "CISepiaTone") else { return image }

    let ciImage = CIImage(image: image)
    filter.setValue(ciImage, forKey: kCIInputImageKey)
    filter.setValue(0.5, forKey: kCIInputIntensityKey)

    let context = CIContext()
    guard let outputImage = filter.outputImage,
          let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return image }

    // Return the transformed image which will be cached (or used by another transformer)
    return UIImage(cgImage: cgImage)
  }

}
```

You then pass this filter to MapleBacon in one of the convenience methods:

```swift
let url = URL(string: "…")
let transformer = SepiaImageTransformer()
imageView.setImage(with: url, transformer: transformer)
```

If you want to apply multiple transforms to an image, you can chain your transformers:

```swift
let chainedTransformer = SepiaImageTransformer()
  .appending(transformer: DifferentTransformer())
  .appending(transformer: AnotherTransformer())
```

(Keep in mind that if you are using Core Image it might not be optimal to chain individual transformers but rather create one transformer that applies multiple `CIFilter`s in one pass. See the [Core Image Programming Guide](https://developer.apple.com/library/content/documentation/GraphicsImaging/Conceptual/CoreImaging/ci_intro/ci_intro.html#//apple_ref/doc/uid/TP30001185).)

And just like the `UIImageView` extension you can also pass in a progress and completion handler.

### Caching

MapleBacon will cache your images both in memory and on disk. Disk storage is automatically pruned after a week (taking into account the last access date as well) but you can control the maximum cache time yourself too:

```swift
let oneDaySeconds: TimeInterval = 60 * 60 * 24
Cache.shared.maxCacheAgeSeconds = oneDaySeconds
```

MapleBacon handles clearing the in memory cache by itself should your app come under memory pressure.

### Tests

MapleBacon uses [Hippolyte](https://github.com/JanGorman/Hippolyte) for stubbing network requests so if you'd like to run the tests yourself, after checking out the repository, run `git submodule init` to fetch the dependency.

## License

MapleBacon is available under the MIT license. See the LICENSE file for more info.
