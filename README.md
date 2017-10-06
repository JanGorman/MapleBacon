[![Version](https://img.shields.io/cocoapods/v/MapleBacon.svg?style=flat)](http://cocoapods.org/pods/MapleBacon)
[![License](https://img.shields.io/cocoapods/l/MapleBacon.svg?style=flat)](http://cocoapods.org/pods/MapleBacon)
[![Platform](https://img.shields.io/cocoapods/p/MapleBacon.svg?style=flat)](http://cocoapods.org/pods/MapleBacon)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

<p align="center"><img src="https://www.dropbox.com/s/mlquw9k6ogvspox/MapleBacon.png?raw=1" height="210"/></p>


MapleBacon is a Swift image download and caching library. The future is happening right now in the [reboot](https://github.com/JanGorman/MapleBacon/tree/reboot) branch.

## Requirements

- Swift 4
- iOS 8.0+
- Xcode 9.0+

## Installation

The easiest way is either through [CocoaPods](http://cocoapods.org) or [Carthage](https://github.com/Carthage/Carthage). 

For the CocoaPods option, simply add the dependency to your `Podfile`, then `pod install`:

```ruby
pod 'MapleBacon'
```

For the Carthage option, add the following to your `Cartfile`, then run `carthage update`:

```ogdl
github "zalando/MapleBacon"
```

If you don't like either of those options, you can add the dependency as a git submodule:

1. Add MapleBacon as a git submodule: open your project directory in the Terminal and `git submodule add https://github.com/zalando/MapleBacon.git`
2. Open the resulting `MapleBacon` directory and drag the `Library/MapleBacon/MapleBacon.xcodeproj` file into your Xcode project
3. In the "Build Phases" tab add MapleBacon as target dependency
4. Add a "New Copy Files Phase" and rename it to "Copy Frameworks". In the "Destination" dropdown select "Frameworks" and add "MapleBacon.framework" in the list of files to copy.

---

## Using MapleBacon

### Downloading an image

The most straightforward way is the `UIImageView` extension:

```swift
import MapleBacon

…

if let imageUrl = URL(string: "…") {
	imageView.setImage(withUrl: imageUrl)
}
```

or with an optional closure, if you want to check for a possible error:

```swift
if let imageUrl = URL(string: "…") {
	imageView.setImage(withUrl: imageUrl) { instance, error in
		…
	}
}
```

There's also support for a placeholder image with optional (enabled by default) cross fading to the proper image once it's been downloaded:

```swift
if let imageUrl = URL(string: "…"), placeholder = UIImage(named: "placeholder") {
	imageView.setImage(withUrl: imageUrl, placeholder: placeholder)
}

// or

if let imageUrl = URL(string: "…"), placeholder = UIImage(named: "placeholder") {
	imageView.setImage(withUrl: imageUrl, placeholder: placeholder, crossFadePlaceholder: false)
}

```

### Using the ImageManager directly

You can also access the underlying handler directly for more advanced usage:

```swift
if let imageUrl = URL(string: "…") {
	let manager = ImageManager.sharedManager
	
	manager.downloadImageAtURL(imageUrl, completion: { imageInstance, error in
		…
	})
}
```

### Scaling images

For the quality conscious among you, MapleBacon also allows for more advanced (and more expensive) scaling of downloaded images. Under the hood this uses Core Graphics. The simplest way to use this mode is to pass in a `cacheScaled: true` Bool into the `UIImageView` extension:

```swift
imageView.setImage(withUrl: imageURL, cacheScaled: true)

// Or the call back way
imageView.setImage(withUrl: imageURL, cacheScaled: true) { imageInstance, error in
…
}

```

This will cache the scaled version of the image in the background, so the whole computation is done only once. It respects both the size and contentMode of the imageView that you call this method on.

Alternatively, you can also access the `Resizer` class directly (and use it independently of downloading images).


### Caching

MapleBacon will cache your images both in memory and on disk. Disk storage is automatically pruned after a week but you can control the maximum cache time yourself too:

```swift
let maxAgeOneDay: NSTimeInterval = 60 * 60 * 24
DiskStorage.sharedStorage.maxAge = maxAgeOneDay
```

You can also wipe the storage completely:

```swift
MapleBaconStorage.sharedStorage.clearStorage()
```

Or, should the app come under memory pressure, clear the in memory images only:

```swift
override func didReceiveMemoryWarning() {
	MapleBaconStorage.sharedStorage.clearMemoryStorage()
}
```

MapleBacon supports multiple cache regions:

```swift
let storage = DiskStorage(name: "…")
```

This requires a little more effort on your end. In this case you'll need to use the `ImageManager` directly as described above and inject your custom storage instance there:

```swift
let storage = DiskStorage(name: "…")

if let imageUrl = URL(string: "…") {
	ImageManager.sharedManager.downloadImage(atUrl: imageUrl, storage: storage) {
		imageInstance, error in
		…
	}
}
```



## Contributors

- [Dimitrios Georgakopoulos](https://github.com/gdj4ever) ([@DimitrisGeorgak](https://twitter.com/DimitrisGeorgak))
- [Jan Gorman](https://github.com/JanGorman) ([@JanGorman](https://twitter.com/JanGorman))
- [Ramy Kfoury](https://github.com/ramy-kfoury) ([@ramy_kfoury](https://twitter.com/ramy_kfoury))

## Acknowledgements

- [Resize a UIImage the right way](http://vocaro.com/trevor/blog/2009/10/12/resize-a-uiimage-the-right-way/)

## Misc

Find out a bit more on how MapleBacon came to be on the [Zalando Tech Blog](https://jobs.zalando.com/tech/blog/maple-bacon/)

## License
 
The MIT License (MIT)

Copyright (c) 2017 Jan Gorman

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
