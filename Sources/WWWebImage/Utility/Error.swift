//
//  Error.swift
//  Example
//
//  Created by iOS on 2026/6/5.
//

import Foundation

public extension WWWebImage {
    
    /// 自訂錯誤
    ///
    /// 用於圖片下載過程中可能發生的錯誤類型
    enum CustomError: Error {
        
        /// URL 無效
        /// - 說明：當 `urlString` 無法轉換為有效的 `URL` 時發生
        /// - 示例：空字符串、格式錯誤的 URL
        /// - 處理：檢查輸入的 URL 格式
        case urlInvalid
        
        /// Response 無效
        /// - 說明：當 HTTP Response 狀態碼不在 200-299 範圍內時發生
        /// - 示例：404 Not Found、500 Internal Server Error
        /// - 處理：檢查伺服器回應或網路狀態
        case invalidResponse
        
        /// 圖片資料錯誤
        /// - 說明：當 `Data` 無法轉換為有效的 `UIImage` 時發生
        /// - 示例：圖片格式錯誤、圖片損壞
        case invalidImageData
        
        /// 沒有 location
        /// - 說明：當 `URLSessionDownloadTask` 完成但未返回臨時文件位置時發生
        /// - 示例：下載失敗、文件損壞
        /// - 處理：重試下載或檢查伺服器
        case noLocation
    }
}
