//
//  DownloadTaskManager.swift
//  Example
//
//  Created by William.Weng on 2026/6/5.
//

import UIKit

public extension WWWebImage {
    
    /// 下載任務管理器 - 使用 ObjC Associated Objects 將 DownloadManager 綁定到每個 UIImageView
    ///
    /// 功能：
    /// 1. 確保每個 UIImageView 只有唯一的 DownloadManager
    /// 2. 追蹤每個 ImageView 的下載狀態（currentURL, expectedURL, isCancelled）
    /// 3. 解決 TableViewCell reuse 時顯示錯誤圖片的問題
    ///
    /// 原理：
    /// - 使用 objc_setAssociatedObject / objc_getAssociatedObject 動態綁定物件
    /// - Singleton 模式確保全局只有一個管理器
    /// - 每個 ImageView 綁定自己的 DownloadManager
    final class DownloadTaskManager {
        
        public static let shared = DownloadTaskManager()    // Singleton 實例
        
        private var downloadManagerKey: UInt8 = 0           // ObjC Associated Object 的 key - 用於綁定 DownloadManager 到 ImageView => 使用 UInt8 地址作為唯一識別碼
        
        /// 獲取或創建 ImageView 的 DownloadManager
        /// - Parameter imageView: 目標 ImageView
        /// - Returns: 該 ImageView 对应的 DownloadManager（已存在則返回，不存在則創建）
        ///
        /// 工作流程：
        /// 1. 檢查是否已存在 DownloadManager（透過 getManager）
        /// 2. 如果存在 → 返回已存在的實例（確保唯一性）
        /// 3. 如果不存在 → 創建新的實例並綁定到 ImageView（透過 setManager）
        ///
        /// 關鍵：
        /// - 同一個 ImageView 多次呼叫會返回相同的 DownloadManager
        /// - 這是解決 cell reuse 問題的核心
        func manager(for imageView: UIImageView?) -> WWWebImage.DownloadManager? {
            
            guard let imageView else { return nil }
            
            if let existingManager = getManager(for: imageView) { return existingManager }
            
            let newManager = WWWebImage.DownloadManager()
            setManager(newManager, for: imageView)
            
            return newManager
        }
    }
}

// MARK: - 一般屬性擴展
extension WWWebImage.DownloadTaskManager {
    
    /// 取消指定 ImageView 的下載任務
    /// - Parameter imageView: 目標 ImageView
    ///
    /// 用途：
    /// 1. 在 TableViewCell.prepareForReuse() 中調用，取消未完成的下載
    /// 2. 手動取消當前下載
    ///
    /// 行為：
    /// - 獲取該 ImageView 的 DownloadManager
    /// - 調用 DownloadManager.cancel()（設置 isCancelled = true，取消 URLSessionTask）
    func cancel(for imageView: UIImageView?) {
        
        guard let imageView else { return }
        if let manager = getManager(for: imageView) { manager.cancel() }
    }
}

// MARK: - 私有方法擴展
private extension WWWebImage.DownloadTaskManager {
    
    /// 從 ImageView 讀取已綁定的 DownloadManager
    /// - Parameter imageView: 目標 ImageView
    /// - Returns: 已綁定的 DownloadManager，如果不存在則返回 nil
    ///
    /// 技術：
    /// - 使用 objc_getAssociatedObject 讀取 runtime 綁定的物件
    /// - 與 setManager 使用相同的 key（downloadManagerKey）
    func getManager(for imageView: UIImageView) -> WWWebImage.DownloadManager? {
        return objc_getAssociatedObject(imageView, &downloadManagerKey) as? WWWebImage.DownloadManager
    }
    
    /// 將 DownloadManager 綁定到 ImageView
    /// - Parameters:
    ///   - manager: 要綁定的 DownloadManager
    ///   - imageView: 目標 ImageView
    ///
    /// 技術：
    /// - 使用 objc_setAssociatedObject 在 runtime 動態綁定物件
    /// - .OBJC_ASSOCIATION_RETAIN_NONATOMIC: 非原子性保留政策（高效能）
    ///
    /// 效果：
    /// imageView → manager（綁定關係）
    /// 之後透過 getManager(for: imageView) 可以讀取這個 manager
    func setManager(_ manager: WWWebImage.DownloadManager, for imageView: UIImageView) {
        objc_setAssociatedObject(imageView, &downloadManagerKey, manager, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
