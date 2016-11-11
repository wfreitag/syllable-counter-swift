# syllable-counter-swift
Lightweight library to count syllables in words, based on the excellent Java implementation found at https://github.com/m09/syllable-counter

## Requirements
Xcode 8.0 or greater. Uses Swift 3.0.

## Installation
There's no sample project here. No CocoaPods integration needed. Just follow these steps:
 1. Copy `SyllableCounter.swift` into your Xcode project.
 2. Add `SyllableCounter-Exceptions.txt` into your `Assets.xcassets` bundle as a data asset. Name the asset `SyllableCounter-Exceptions`.

## How to use
SyllableCounter uses a shared instance that is initialized on first use.
There is one public method: `count()`, which takes a string.

```swift
let syllableCount = SyllableCounter.shared.count(word: "wonderful")
print("There are \(syllableCount) syllables in 'wonderful'.")
```

... or you can use the extension on `String`:

```swift
let syllableCount = "wonderful".syllables
print("There are \(syllableCount) syllables in 'wonderful'.)
```

The original [Java implementation](https://github.com/m09/syllable-counter) has a caching option. This feature was not ported over to this implementation.

## License
Licensed under the Apache 2.0 License. Feel free to use and modify according to the terms expressed in the license. Contributions welcome.
