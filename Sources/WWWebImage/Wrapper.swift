//
//  Wrapper.swift
//  Example
//
//  Created by William.Weng on 2026/6/5.
//

import UIKit
import WWCacheManager

public extension WWWebImage {
    
    /// ImageView 的擴展包裝器 - 提供圖片下載功能
    class Wrapper<T: UIImageView> {
        
        private weak var imageView: T?
        
        /// 初始化
        /// - Parameter imageView: 可用的 ImageView（弱引用避免記憶體洩漏）
        init(_ imageView: T) {
            self.imageView = imageView
        }
    }
}

// MARK: - 公開方法
public extension WWWebImage.Wrapper {
    
    /// 下載圖片到 ImageView
    /// - Parameter urlString: 圖片網址
    /// - Throws: 下載失敗時的錯誤
    ///
    /// 工作流程：
    /// 1. 獲取或創建 DownloadManeger（透過 DownloadTaskManager）
    /// 2. 取消之前的下載（如果存在）
    /// 3. 設置期望 URL（expectedURL）
    /// 4. 清空 ImageView（佔位圖）
    /// 5. 開始下載圖片
    /// 6. 下載完成時驗證是否應該顯示（shouldShowImage）
    /// 7. 顯示圖片（只在 main thread）
    ///
    /// Cell Reuse 追蹤：
    /// - 如果 ImageView 被 reuse，舊任務會被打標為 cancelled
    /// - 舊任務完成時，shouldShowImage 返回 false，不顯示圖片
    func download(urlString: String) async throws {
        
        guard let manager = prepareDownloadManager(urlString: urlString) else { return }
        
        await MainActor.run { self.imageView?.image = nil }
        try await cacheImage(with: urlString, manager: manager)
    }
    
    /// 取消當前下載
    ///
    /// 通常在 TableViewCell.prepareForReuse() 中調用
    func cancel() {
        guard let imageView = imageView else { return }
        WWWebImage.DownloadTaskManager.shared.cancel(for: imageView)
    }
}

// MARK: - 一般方法擴展
private extension WWWebImage.Wrapper {
    
    /// 獲取或創建 DownloadManeger，並設置下載狀態
    /// - Parameter urlString: 要下載的圖片網址
    /// - Returns: DownloadManeger（用於追蹤下載狀態）
    ///
    /// 工作流程：
    /// 1. 從 DownloadTaskManager 獲取 ImageView 的 DownloadManeger
    /// 2. 取消之前的下載（如果存在）
    /// 3. 設置期望 URL（expectedURL）
    /// 4. 重置取消狀態（isCancelled = false）
    /// 5. 返回 DownloadManeger
    ///
    /// 關鍵：
    /// - 每次 download() 都會先取消舊任務
    /// - 設置新的 expectedURL
    /// - 舊任務完成時，shouldShowImage 返回 false，不顯示圖片
    func prepareDownloadManager(urlString: String) -> WWWebImage.DownloadManeger? {
        
        let manager = WWWebImage.DownloadTaskManager.shared.maneger(for: imageView)
        guard let manager else { return nil }
        
        manager.cancel()
        manager.expectedURL = urlString
        manager.isCancelled = false
        
        return manager
    }
    
    /// 獲取圖片（從 Cache 或下載）
    /// - Parameters:
    ///   - urlString: 圖片網址
    ///   - manager: DownloadManeger（保存 task）
    /// - Throws: 下載失敗時的錯誤
    ///
    /// 工作流程：
    /// 1. 檢查 Cache（如果存在則直接顯示）
    /// 2. 下載圖片（如果 Cache 不存在）
    /// 3. 設置 currentURL
    /// 4. 檢查是否應該顯示（cell reuse 驗證）
    /// 5. Cache 圖片並顯示
    func cacheImage(with urlString: String, manager: WWWebImage.DownloadManeger) async throws {
        
        if let image = WWWebImage.cacheManager.value(forKey: urlString) {
            await MainActor.run { self.imageView?.image = image }
            return
        }
                
        let data = try await WWWebImage.Downloader.start(urlString: urlString) { manager.task = $0 }
        
        manager.currentURL = urlString
        
        guard manager.shouldShowImage else { return }
        guard let image = UIImage(data: data) else { throw WWWebImage.CustomError.invalidImageData }
        
        await MainActor.run {
            WWWebImage.cacheManager.setValue(image, forKey: urlString)
            self.imageView?.image = image
        }
    }
}

