# MapleBacon

[![CI](https://github.com/JanGorman/MapleBacon/workflows/CI/badge.svg)](https://github.com/JanGorman/MapleBacon/actions?query=workflow%3ACI)
[![codecov.io](https://codecov.io/github/JanGorman/MapleBacon/coverage.svg)](https://codecov.io/github/JanGorman/MapleBacon)
[![Version](https://img.shields.io/cocoapods/v/MapleBacon.svg?style=flat)](http://cocoapods.org/pods/MapleBacon)
[![License](https://img.shields.io/cocoapods/l/MapleBacon.svg?style=flat)](http://cocoapods.org/pods/MapleBacon)
[![Platform](https://img.shields.io/cocoapods/p/MapleBacon.svg?style=flat)](http://cocoapods.org/pods/MapleBacon)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![SPM](https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat)](https://swift.org/package-manager)

<p align="center"><img src="https://www.dropbox.com/s/mlquw9k6ogvspox/MapleBacon.png?raw=1" height="210"/></p>

# Introduction

MapleBacon is a lightweight and fast Swift library for downloading and caching images.

## Example

The folder `Example` contains a sample projects for you to try.

## Requirements

- Swift 5.1
- iOS 10.0+
- Xcode 10.2+

## Installation

MapleBacon is available through [CocoaPods](http://cocoapods.org). To install add it to your Podfile:

```ruby
pod "MapleBacon"
```

[Carthage](https://github.com/Carthage/Carthage) / [punic](https://github.com/schwa/punic):

```ogdl
github "JanGorman/MapleBacon"
```

and [Swift Package Manager](https://swift.org/package-manager).

## Usage

### UIImageView

The most basic usage is via an extension on `UIImageView`. You pass it URL:

```swift
import MapleBacon

private var imageView: UIImageView!

func someFunc() {
  let url = URL(string: "…")
  imageView.setImage(with: url)
}
```

If you want to add a placeholder while the image is downloading you specify that like this:

```swift
func someFunc() {
  let url = URL(string: "…")
  imageView.setImage(with: url, placeholder: UIImage(named: "placeholder"))
}
```

If your backend returns images that are not optimised for display, it's good practice to downsample them. MapleBacon comes with support for downsampling via `displayOptions`:

```swift
func someFunc() {
  let url = URL(string: "…")
  imageView.setImage(with: url, displayOptions: .downsampled)
}
```

### Image Transformers

MapleBacon allows you to apply transformations to images and have the results cached so that you app doesn't need to perform the same work over and over. To make your own transformer, create a class conforming to the `ImageTransforming` protocol. A transform can be anything you like, let's create one that applies a Core Image sepia filter:

```swift
private class SepiaImageTransformer: ImageTransforming {

  // The identifier is used as part of the cache key. Make sure it's something unique
  let identifier = "com.schnaub.SepiaImageTransformer"

  func transform(image: UIImage) -> UIImage? {
    let filter = CIFilter(name: "CISepiaTone")!

    let ciImage = CIImage(image: image)
    filter.setValue(ciImage, forKey: kCIInputImageKey)
    filter.setValue(0.5, forKey: kCIInputIntensityKey)

    let context = CIContext()
    guard let outputImage = filter.outputImage,
          let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return image
    }

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

Or if you prefer, using the custom `>>>` operator:

```swift
let chainedTransformer = SepiaImageTransformer() >>> DifferentTransformer() >>> AnotherTransformer()
```

(Keep in mind that if you are using Core Image it might not be optimal to chain individual transformers but rather create one transformer that applies multiple `CIFilter`s in one pass. See the [Core Image Programming Guide](https://developer.apple.com/library/content/documentation/GraphicsImaging/Conceptual/CoreImaging/ci_intro/ci_intro.html#//apple_ref/doc/uid/TP30001185).)

### Caching

MapleBacon will cache your images both in memory and on disk. Disk storage is automatically pruned after a week (taking into account the last access date as well) but you can control the maximum cache time yourself too:

```swift
let oneDaySeconds: TimeInterval = 60 * 60 * 24
MapleBacon.default.maxCacheAgeSeconds = oneDaySeconds
```

### Combine

On iOS13 and above, you can use `Combine` to fetch images from MapleBacon

```swift
MapleBacon.shared.image(with: url)
  .receive(on: DispatchQueue.main) // Dispatch to the right queue if updating the UI
  .sink(receiveValue: { image in
    // Do something with your image
  })
  .store(in: &subscriptions) // Hold on to and dispose your subscriptions
```

## Migrating from 5.x

There is a small [migration guide](https://github.com/JanGorman/MapleBacon/wiki/Migration-Guide-Version-5.x-→-6.x) in the wiki when moving from the 5.x branch to 6.x

## License

MapleBacon is available under the MIT license. See the LICENSE file for more info.
