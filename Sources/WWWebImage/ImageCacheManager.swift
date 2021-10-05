//
//  ImageCacheManager.swift
//  WWWebImage
//
//  Created by William.Weng on 2021/10/1.
//

import UIKit
import WWPrint
import WWNetworking

// MARK: - 管理圖片快取
class ImageCacheManager {
    
    static let shared = ImageCacheManager()
    
    static var maximumCache: Int64 = 1_000_000_000
    static var compressionQuality: CGFloat = 1.0
    static var sizeMark: WWWebImage.Constant.SizeMark? = nil

    private let cacheInformation = (url: FileManager.default._cachesDirectory(), path: "WWWebImage")
    
    var imageUrlInfoSet: Set<String> = []
    
    init() {
        _ = cleanCachesDirectory()
        _ = createCacheImageDirectory()
    }
}

// MARK: - ImageCacheManager (public class function)
extension ImageCacheManager {
    
    /// 儲存快取圖片 => ~/Library/Caches/WWWebImage/???
    /// - Parameters:
    ///   - image: UIImage
    ///   - identifier: String
    /// - Returns: Result<Bool, Error>
    func storeCacheImage(_ image: UIImage, forKey identifier: String) -> Result<Bool, Error> {
        
        guard let cacheImageURL = cacheImageUrl(with: identifier) else { return .success(false) }
        
        var _image = image
        if let sizeMark = Self.sizeMark { _image = _image._scaled(for: sizeMark) }
        
        return FileManager.default._writeData(to: cacheImageURL, data: _image.jpegData(compressionQuality: Self.compressionQuality))
    }
    
    /// 讀取快取圖片 => ~/Library/Caches/WWWebImage/???
    /// - Parameter identifier: String
    /// - Returns: UIImage?
    func cacheImage(with identifier: String) -> UIImage? {
        
        guard let cacheImageURL = cacheImageUrl(with: identifier),
              let image = FileManager.default._readImage(from: cacheImageURL)
        else {
            return nil
        }

        return image
    }
    
    /// 取得Cache資料夾的大小
    /// - Returns: Result<Int64, Error>
    func cachesDirectorySize() -> Result<WWWebImage.Constant.FileSizeInfomation, Error> {
        
        let result = FileManager.default._fileTotalSize(with: cacheDirectoryUrl())

        switch result {
        case .failure(let error): return .failure(error)
        case .success(let info): return .success(info)
        }
    }
}

// MARK: - ImageCacheManager (private class function)
extension ImageCacheManager {
    
    /// 建立快取圖片的資料夾
    /// - Returns: Result<Bool, Error>
    private func createCacheImageDirectory() -> Result<Bool, Error> {
        
        do {
            let cacheDirectory = cacheDirectoryUrl()
            let isSuccess = try FileManager.default._createDirectory(with: cacheDirectory)
            return .success(isSuccess)
        } catch {
            return .failure(error)
        }
    }
    
    /// 移除快取圖片的資料夾
    /// - Returns: Result<Bool, Error>
    private func removeCacheImageDirectory() -> Result<Bool, Error> {
        
        do {
            let cacheDirectory = cacheDirectoryUrl()
            let isSuccess = try FileManager.default._removeFile(at: cacheDirectory).get()
            return .success(isSuccess)
        } catch {
            return .failure(error)
        }
    }
    
    /// 產生快取圖片的URL (https://ooxx/3939889/abc.jpg => ~/Library/Caches/WWWebImage/???)
    /// - Parameter identifier: String
    /// - Returns: URL?
    private func cacheImageUrl(with identifier: String) -> URL? {
        
        guard let url = URL(string: identifier),
              let filename = filenameMaker(with: url),
              let cachesFolder = cacheDirectoryUrl()
        else {
            return nil
        }
        
        return cachesFolder.appendingPathComponent(filename)
    }
    
    /// 轉換檔名 => 利用SHA1的方法轉換 (https://via.placeholder.com/200/1A20CE => 463fb403002021c0ce9d728cedf33b0f749aec50)
    /// - Parameter url: URL?
    /// - Returns: String?
    private func filenameMaker(with url: URL?) -> String? {
        return url?.absoluteString._sha1()
    }
    
    /// 取得完整Cache的路徑 => ~/Library/Caches/WWWebImage/
    /// - Returns: URL?
    private func cacheDirectoryUrl() -> URL? {
        guard let cachesFolder = cacheInformation.url else { return nil }
        return cachesFolder.appendingPathComponent(cacheInformation.path)
    }
    
    /// 清除快取的時機
    private func cleanCachesDirectory() -> Result<Bool, Error> {
                
        let result = cachesDirectorySize()

        switch result {
        case .failure(let error): return .failure(error)
        case .success(let info):
            guard info.size > Self.maximumCache else { return .success(false) }
            return removeCacheImageDirectory()
        }
    }
}
