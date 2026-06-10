[English](./README.en.md) | [正體中文](./README.md)

# [WWWebImage](https://swiftpackageindex.com/William-Weng)

[![Swift-5.7](https://img.shields.io/badge/Swift-5.7-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![iOS-16.0](https://img.shields.io/badge/iOS-16.0-pink.svg?style=flat)](https://developer.apple.com/swift/)
![TAG](https://img.shields.io/github/v/tag/William-Weng/WWWebImage)
[![Swift Package Manager-SUCCESS](https://img.shields.io/badge/Swift_Package_Manager-SUCCESS-blue.svg?style=flat)](https://developer.apple.com/swift/)
[![LICENSE](https://img.shields.io/badge/LICENSE-MIT-yellow.svg?style=flat)](https://developer.apple.com/swift/)

An async/await-based web image downloading utility, designed as a lightweight alternative to SDWebImage / Kingfisher.

https://github.com/user-attachments/assets/6b45da12-a1f9-4a7c-85d9-0dc50cad5b87

---

## Overview

**WWWebImage** is a web image downloading utility built with Swift 6 `async/await`. It is a simplified alternative to SDWebImage and Kingfisher, powered by `WWCacheManager` and `WWNetworking`. It supports **memory caching** and **cell reuse tracking**, which helps prevent image mismatch issues in `UITableView` and `UICollectionView`.

---

### Features

| Feature | Description |
|------|------|
| 🚀 **Swift 6 Concurrency** | Native `async/await` and `MainActor` support |
| 💾 **Memory Cache** | Stores images using `WWCacheManager` |
| 🔄 **Cell Reuse Protection** | Automatically tracks and cancels outdated tasks |
| 🎯 **Wrapper Pattern** | Simple one-line image loading API |
| 📦 **SPM Support** | Ready to use with Swift Package Manager |
| 🛡️ **Error Handling** | Full `throw`-based error handling |

---

## Installation

### Swift Package Manager

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/William-Weng/WWWebImage.git", .upToNextMajor(from: "1.0.3"))
]
```

Or in Xcode:

1. `File` → `Add Packages`
2. Enter `https://github.com/William-Weng/WWWebImage.git`
3. Select the version and add the package

---

## Dependencies

This project depends on the following Swift package:

- [WWCacheManager](https://github.com/William-Weng/WWCacheManager) - Memory cache manager

---

## API Reference

| Method | Description |
|------|------|
| `download(urlString:default:)` | Downloads an image into an `ImageView` |
| `cancel()` | Cancels the current download, usually called in `prepareForReuse()` |

---

## Usage

### ImageTableViewController

```swift
import UIKit
import WWWebImage

final class ImageTableViewController: UITableViewController {
    
    private let imageUrls = [
        "https://api.cosmopolitan.com.hk/var/site/storage/images/_aliases/img_730w/2/3/1/8/7618132-1-chi-HK/1.jpg",
        "https://pbs.twimg.com/media/Evk1PiMVIAIOhtR?format=jpg&name=medium",
        "https://meet.eslite.com/CMS/Files/@M091/2024-11/2024_chiikawa/003_chiikawa.jpg",
        "https://meet.eslite.com/CMS/Files/@M091/2024-11/2024_chiikawa/001_chiikawa.jpg",
        "https://hips.hearstapps.com/hmg-prod/images/clipdown-app-333226746-761742381720284-1594220155962536035-n-6728a7fb848f6.jpg?crop=0.679xw:1.00xh;0.156xw,0&resize=1200:*",
        "https://api.cosmopolitan.com.hk/var/site/storage/images/_aliases/img_730w/2/0/4/8/7618402-1-chi-HK/2.jpg",
        "https://shoplineimg.com/media/663c6333a1cc270011604bc1/original.webp?source_format=jpg",
        "https://api.esquirehk.com/var/site/storage/images/_aliases/img_804_w/4/5/6/2/6152654-1-chi-HK/Untitled-2.jpg"
    ]
    
    private var tripledUrls: [String] { (0..<3).flatMap { _ in imageUrls } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 200
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tripledUrls.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ImageCell.identifier, for: indexPath) as! ImageCell
        let imageUrl = tripledUrls[indexPath.row]
        
        cell.configure(with: imageUrl)
        return cell
    }
}
```

### ImageCell

```swift
import UIKit

final class ImageCell: UITableViewCell {
    
    @IBOutlet weak var myImageView: UIImageView!
    
    static let identifier = "ImageCell"
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        myImageView.ww.cancel()
        myImageView.image = nil
    }
    
    func configure(with imageUrl: String) {
        Task { try await myImageView.ww.download(urlString: imageUrl, default: .placeholder) }
    }
}
```

---

## Core Architecture

### Wrapper Pattern

```swift
// Wrapper is a convenience wrapper for UIImageView
let wrapper = WWWebImage.Wrapper(imageView)

// Main methods
await wrapper.download(urlString: "https://...")  // Download image
wrapper.cancel()                                  // Cancel download
```

### Cell Reuse Protection

| Step | Description |
|------|------|
| 1️⃣ | The cell is reused, and `prepareForReuse()` calls `cancel()` |
| 2️⃣ | `cancel()` marks the old task as `isCancelled = true` |
| 3️⃣ | When the old task finishes, `shouldShowImage` returns `false` |
| 4️⃣ | The old image is not shown, preventing wrong images from appearing |
| 5️⃣ | A new task starts and downloads the new image |

```swift
// DownloadManager.shouldShowImage logic
var shouldShowImage: Bool {
    // Task cancelled, do not display
    guard !isCancelled else { return false }
    
    // URL mismatch, likely reused cell, do not display
    guard currentURL == expectedURL else { return false }
    
    return true
}
```

---

## Error Handling

```swift
enum CustomError: Error {
    case invalidImageData
    case downloadFailed
    case cacheError
}
```

---

## Acknowledgments

Thanks to the following projects for inspiration and reference:

- [SDWebImage](https://github.com/SDWebImage/SDWebImage) - A classic iOS image downloading and caching library
- [Kingfisher](https://github.com/onevcat/Kingfisher) - A pure Swift image downloading and caching library
