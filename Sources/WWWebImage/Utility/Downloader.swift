//
//  Utility.swift
//  Example
//
//  Created by William.Weng on 2026/6/5.
//

import Foundation

extension WWWebImage {
    
    // MARK: - 圖片下載工具
    class Downloader {
        
        /// 下載圖片（使用 URLSessionDownloadTask，透過 startHandler 傳出 task）
        /// - Parameters:
        ///   - urlString: 圖片網址
        ///   - startHandler: task 開始時的回调（可以保存 task）
        /// - Returns: 圖片 Data
        static func start(urlString: String, startHandler: ((URLSessionDownloadTask) -> Void)) async throws -> Data {
            
            guard let url = URL(string: urlString) else { throw CustomError.urlInvalid }
            
            return try await withCheckedThrowingContinuation { continuation in
                
                let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
                let task = session.downloadTask(with: url) { location, response, error in
                    
                    if let error = error { continuation.resume(throwing: error); return }
                    
                    guard let location = location else { continuation.resume(throwing: CustomError.urlInvalid); return }
                    
                    do {
                        let data = try Data(contentsOf: location)
                        continuation.resume(returning: data)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
                
                startHandler(task)
                task.resume()
            }
        }
    }
}
