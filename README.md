# syllable-counter-swift
Lightweight library to count syllables in words, based on the excellent Java implementation found at https://github.com/m09/syllable-counter

## Requirements
Swift 5.3 or newer on macOS or Linux.

## Installation
Add the following dependency to your project's `Package.swift`:

```swift
.package(url: "https://github.com/wfreitag/syllable-counter-swift.git", .revision("8bdd5abe0e429f3554a655cb40b1f9fda8dd8a18"))
```

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
