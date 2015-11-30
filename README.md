[![Version](https://img.shields.io/cocoapods/v/MapleBacon.svg?style=flat)](http://cocoapods.org/pods/Zoetrope)
[![License](https://img.shields.io/cocoapods/l/MapleBacon.svg?style=flat)](http://cocoapods.org/pods/Zoetrope)
[![Platform](https://img.shields.io/cocoapods/p/MapleBacon.svg?style=flat)](http://cocoapods.org/pods/Zoetrope)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

<p align="center"><img src="https://dl.dropboxusercontent.com/u/512759/MapleBacon.png" height="210"/></p>


MapleBacon is a Swift image download and caching library.

## Requirements

- iOS 8.0+
- Xcode 7.0


## Installation

The easiest way is either through [CocoaPods](http://cocoapods.org). Simply add the dependency to your `Podfile` and then `pod install`:

```ruby
pod 'MapleBacon'
```

or [Carthage](https://github.com/Carthage/Carthage). Add the following to your `Cartfile` and then run `carthage update`:

```ogdl
github "zalando/MapleBacon"
```


If you don't like any of those options, you can add the dependency as a git submdoule:

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

if let imageURL = NSURL(string: "…") {
	imageView.setImageWithURL(imageURL)
}
```

or with an optional closure, if you want to check for a possible error:

```swift
if let imageURL = NSURL(string: "…") {
	imageView.setImageWithURL(imageURL) { instance, error in
		…
	}
}
```

There's also support for a placeholder image with optional (enabled by default) cross fading to the proper image once it's been downloaded:

```swift
if let imageURL = NSURL(string: "…"), placeholder = UIImage(named: "placeholder") {
	imageView.setImageWithURL(imageURL, placeholder: placeholder)
}

// or

if let imageURL = NSURL(string: "…"), placeholder = UIImage(named: "placeholder") {
	imageView.setImageWithURL(imageURL, placeholder: placeholder, crossFadePlaceholder: false)
}

```

### Using the ImageManager directly

You can also access the underlying handler directly for more advanced usage:

```swift
if let imageURL = NSURL(string: "…") {
	let manager = ImageManager.sharedManager
	
	manager.downloadImageAtURL(imageURL, completion: { imageInstance, error in
		…
	})
}
```

### Scaling images

For the quality conscious among you, MapleBacon also allows for more advanced (and more expensive) scaling of downloaded images. Under the hood this uses Core Graphics. The simplest way to use this mode is to pass in a `cacheScaled: true` Bool into the `UIImageView` extension:

```swift
imageView.setImageWithURL(imageURL, cacheScaled: true)

// Or the call back way
imageView.setImageWithURL(imageURL, cacheScaled: true) { imageInstance, error in
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

if let imageURL = NSURL(string: "…") {
	ImageManager.sharedManager.downloadImageAtURL(imageURL, storage: storage) {
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

Find out a bit more on how MapleBacon came to be on the [Zalando Tech Blog](http://tech.zalando.com/posts/maple-bacon.html)

## Licence

MapleBacon is released under the MIT license. See LICENSE for details
