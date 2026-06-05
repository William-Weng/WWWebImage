//
//  DownloadTaskManager.swift
//  Example
//
//  Created by William.Weng on 2026/6/5.
//

import UIKit

public extension WWWebImage {
    
    /// 下載任務管理器 - 使用 ObjC Associated Objects 將 DownloadManeger 綁定到每個 UIImageView
    ///
    /// 功能：
    /// 1. 確保每個 UIImageView 只有唯一的 DownloadManeger
    /// 2. 追蹤每個 ImageView 的下載狀態（currentURL, expectedURL, isCancelled）
    /// 3. 解決 TableViewCell reuse 時顯示錯誤圖片的問題
    ///
    /// 原理：
    /// - 使用 objc_setAssociatedObject / objc_getAssociatedObject 動態綁定物件
    /// - Singleton 模式確保全局只有一個管理器
    /// - 每個 ImageView 綁定自己的 DownloadManeger
    final class DownloadTaskManager {
        
        public static let shared = DownloadTaskManager()    // Singleton 實例
        
        private var downloadManegerKey: UInt8 = 0           // ObjC Associated Object 的 key - 用於綁定 DownloadManeger 到 ImageView => 使用 UInt8 地址作為唯一識別碼
        
        /// 獲取或創建 ImageView 的 DownloadManeger
        /// - Parameter imageView: 目標 ImageView
        /// - Returns: 該 ImageView 对应的 DownloadManeger（已存在則返回，不存在則創建）
        ///
        /// 工作流程：
        /// 1. 檢查是否已存在 DownloadManeger（透過 getManeger）
        /// 2. 如果存在 → 返回已存在的實例（確保唯一性）
        /// 3. 如果不存在 → 創建新的實例並綁定到 ImageView（透過 setManeger）
        ///
        /// 關鍵：
        /// - 同一個 ImageView 多次呼叫會返回相同的 DownloadManeger
        /// - 這是解決 cell reuse 問題的核心
        func maneger(for imageView: UIImageView?) -> WWWebImage.DownloadManeger? {
            
            guard let imageView else { return nil }
            
            if let existingManager = getManeger(for: imageView) { return existingManager }
            
            let newManager = WWWebImage.DownloadManeger()
            setManeger(newManager, for: imageView)
            
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
    /// - 獲取該 ImageView 的 DownloadManeger
    /// - 調用 DownloadManeger.cancel()（設置 isCancelled = true，取消 URLSessionTask）
    func cancel(for imageView: UIImageView?) {
        
        guard let imageView else { return }
        if let manager = getManeger(for: imageView) { manager.cancel() }
    }
}

// MARK: - 私有方法擴展
private extension WWWebImage.DownloadTaskManager {
    
    /// 從 ImageView 讀取已綁定的 DownloadManeger
    /// - Parameter imageView: 目標 ImageView
    /// - Returns: 已綁定的 DownloadManeger，如果不存在則返回 nil
    ///
    /// 技術：
    /// - 使用 objc_getAssociatedObject 讀取 runtime 綁定的物件
    /// - 與 setManeger 使用相同的 key（downloadManegerKey）
    func getManeger(for imageView: UIImageView) -> WWWebImage.DownloadManeger? {
        return objc_getAssociatedObject(imageView, &downloadManegerKey) as? WWWebImage.DownloadManeger
    }
    
    /// 將 DownloadManeger 綁定到 ImageView
    /// - Parameters:
    ///   - manager: 要綁定的 DownloadManeger
    ///   - imageView: 目標 ImageView
    ///
    /// 技術：
    /// - 使用 objc_setAssociatedObject 在 runtime 動態綁定物件
    /// - .OBJC_ASSOCIATION_RETAIN_NONATOMIC: 非原子性保留政策（高效能）
    ///
    /// 效果：
    /// imageView → manager（綁定關係）
    /// 之後透過 getManeger(for: imageView) 可以讀取這個 manager
    func setManeger(_ manager: WWWebImage.DownloadManeger, for imageView: UIImageView) {
        objc_setAssociatedObject(imageView, &downloadManegerKey, manager, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
