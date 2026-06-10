//
//  DownloadManeger.swift
//  Example
//
//  Created by William.Weng on 2026/6/5.
//

import Foundation

extension WWWebImage {
    
    /// 下載管理器 - 追蹤單一 ImageView 的下載狀態
    ///
    /// 責任：
    /// 1. 記錄當前正在下載的 URL（currentURL）
    /// 2. 記錄期望顯示的 URL（expectedURL）
    /// 3. 追蹤取消狀態（isCancelled）
    /// 4. 驗證是否應該顯示圖片（shouldShowImage）
    ///
    /// 由 DownloadTaskManager 透過 ObjC Associated Object 綁定到每個 ImageView
    final class DownloadManager {
        
        var task: URLSessionDownloadTask?       // 當前的 URLSessionDownloadTask => 用於在取消時調用 task?.cancel()
        var currentURL: String?                 // 當前正在下載的 URL => 在下載完成時設置為最終下載的 URL
        var expectedURL: String?                // 期望顯示的 URL => 在開始下載時設置為新的 URL
        var isCancelled = false                 // 取消狀態標記
    }
}

// MARK: - 一般屬性擴展
extension WWWebImage.DownloadManager {
    
    /// 驗證是否應該顯示圖片
    /// - Returns: 如果 currentURL 等於 expectedURL 且未被取消，返回 true
    ///
    /// 驗證條件：
    /// 1. currentURL == expectedURL → 下載的圖片是期望的圖片
    /// 2. !isCancelled → 下載未被取消
    var shouldShowImage: Bool {
        return currentURL == expectedURL && !isCancelled
    }
}

// MARK: - 一般方法擴展
extension WWWebImage.DownloadManager {
        
    /// 取消下載
    ///
    /// 行為：
    /// 1. 設置 isCancelled = true → 標記為已取消
    /// 2. 調用 task?.cancel() → 取消 URLSessionTask
    /// 3. 設置 currentURL = nil → 清除當前 URL
    ///
    /// 注意：
    /// - 保留 expectedURL（用於驗證舊任務是否應該顯示）
    /// - isCancelled 會在下次 download() 時重置為 false
    func cancel() {
        isCancelled = true
        task?.cancel()
        currentURL = nil
    }
}
