[English](./README.en.md) | [正體中文](./README.md)

# [WWWebImage - 簡易的非同步網路圖片下載工具](https://swiftpackageindex.com/William-Weng)

[![Swift-5.7](https://img.shields.io/badge/Swift-5.7-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![iOS-16.0](https://img.shields.io/badge/iOS-16.0-pink.svg?style=flat)](https://developer.apple.com/swift/)
![TAG](https://img.shields.io/github/v/tag/William-Weng/WWWebImage)
[![Swift Package Manager-SUCCESS](https://img.shields.io/badge/Swift_Package_Manager-SUCCESS-blue.svg?style=flat)](https://developer.apple.com/swift/)
[![LICENSE](https://img.shields.io/badge/LICENSE-MIT-yellow.svg?style=flat)](https://developer.apple.com/swift/)
  
Async/Await 版的網路圖片下載工具，類似 SDWebImage / Kingfisher 的簡化實作。

https://github.com/user-attachments/assets/6b45da12-a1f9-4a7c-85d9-0dc50cad5b87

---

## 📋 簡介

**WWWebImage** 是一個使用 Swift 6 `async/await` 的網路圖片下載工具，類似於 SDWebImage 或 Kingfisher 的簡化版本。它使用 `WWCacheManager` 實作，支援 **記憶體快取** 和 **Cell Reuse 追蹤**，能有效避免 UITableView/UICollectionView 的圖片錯亂問題。

---

### 主要特性

| 特性 | 說明 |
|------|------|
| 🚀 **Swift 6 Concurrency** | 原生 `async/await` + `MainActor` |
| 💾 **記憶體快取** | 使用 `WWCacheManager` 儲存圖片 |
| 🔄 **Cell Reuse 防錯亂** | 自動追蹤與取消舊任務 |
| 🎯 **Wrapper 包裝器** | 一行程式碼設定圖片 |
| 📦 **SPM 支援** | Swift Package Manager 直接安裝 |
| 🛡️ **錯誤處理** | 完整的 `throw` 錯誤機制 |

---

## 📦 安裝

### Swift Package Manager

在 `Package.swift` 中添加：

```swift
dependencies: [
    .package(url: "https://github.com/William-Weng/WWWebImage.git", .upToNextMajor(from: "1.0.3"))
]
```

或在 Xcode 中：
1. `File` → `Add Packages`
2. 輸入 `https://github.com/William-Weng/WWWebImage.git`
3. 選擇版本並添加

---

## 📝 依賴專案

此專案依賴以下你的其他 Swift 套件：

- [WWCacheManager](https://github.com/William-Weng/WWCacheManager) - 記憶體快取管理套件

---
## 📊 API 參考

| 方法 | 說明 |
|------|------|
| `download(urlString:default:)` | 下載圖片到 `ImageView` |
| `cancel()` | 取消當前下載 (通常在 `TableViewCell.prepareForReuse()` 中調用) |

---

## 🚀 使用指南

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
    
    private var tripledUrls: [String] { (0..<3).flatMap { _ in self.imageUrls } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 200
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tripledUrls.count
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

```
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

## 🔧 核心架構

### Wrapper 包裝器模式

```swift
// Wrapper 是.ImageView 的擴展包裝器
let wrapper = WWWebImage.Wrapper(imageView)

// 主要方法
await wrapper.download(urlString: "https://...")  // 下載圖片
wrapper.cancel()                                  // 取消下載
```

### Cell Reuse 防錯亂機制

| 步驟 | 說明 |
|------|------|
| 1️⃣ | Cell 被 reuse → `prepareForReuse()` 調用 `cancel()` |
| 2️⃣ | `cancel()` → 舊任務的 `isCancelled = true` |
| 3️⃣ | 舊任務完成 → `shouldShowImage` 返回 `false` |
| 4️⃣ | 舊任務不顯示圖片，避免錯亂 |
| 5️⃣ | 新任務開始，下載新圖片 |

```swift
// DownloadManager.shouldShowImage 的邏輯
var shouldShowImage: Bool {
    // 任務被取消 → 不顯示
    guard !isCancelled else { return false }
    
    // URL 不匹配 → Cell 被 reuse 了 → 不顯示
    guard currentURL == expectedURL else { return false }
    
    return true
}
```

---

## 🧪 錯誤處理

```swift
enum CustomError: Error {
    case invalidImageData  // 圖片數據無效
    case downloadFailed    // 下載失敗
    case cacheError        // 快取錯誤
}
```

---

## 🙏 Acknowledgments

感謝以下專案的靈感與參考：

- [SDWebImage](https://github.com/SDWebImage/SDWebImage) - iOS 圖片下載與快取經典庫
- [Kingfisher](https://github.com/onevcat/Kingfisher) - 純 Swift 圖片下載與快取庫
