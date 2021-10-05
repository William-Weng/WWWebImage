//
//  Extension.swift
//  WWWebImage
//
//  Created by William.Weng on 2021/10/1.
//

import UIKit
import CommonCrypto
import WWNetworking
import WWPrint

// MARK: - Collection (override class function)
extension Collection {

    /// [為Array加上安全取值特性 => nil](https://stackoverflow.com/questions/25329186/safe-bounds-checked-array-lookup-in-swift-through-optional-bindings)
    subscript(safe index: Index) -> Element? { return indices.contains(index) ? self[index] : nil }
}

// MARK: - String (class function)
extension String {
    
    // [文字 => SHA1()](https://stackoverflow.com/questions/25761344/how-to-hash-nsstring-with-sha1-in-swift)
    func _sha1() -> String {
        
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        
        data.withUnsafeBytes { _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest) }
        
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        
        return hexBytes.joined()
    }
}

// MARK: - FileManager (class function)
extension FileManager {
        
    /// [取得User的資料夾](https://cdfq152313.github.io/post/2016-10-11/)
    /// - UIFileSharingEnabled = YES => iOS設置iTunes文件共享
    /// - Parameter directory: User的資料夾名稱
    /// - Returns: [URL]
    func _userDirectory(for directory: FileManager.SearchPathDirectory) -> [URL] { return Self.default.urls(for: directory, in: .userDomainMask) }
    
    /// User的「快取」資料夾
    /// - => ~/Library/Caches
    /// - Returns: URL?
    func _cachesDirectory() -> URL? { return self._userDirectory(for: .cachesDirectory).first }

    /// 讀取UIImage
    /// - UIImage => .plist
    /// - Parameter url: 圖片的URL
    /// - Returns: UIImage?
    func _readImage(from url: URL?) -> UIImage? {
        
        guard let url = url,
              let image = UIImage(contentsOfFile: url.path)
        else {
            return nil
        }
        
        return image
    }
    
    /// 寫入Data - 二進制資料
    /// - Parameters:
    ///   - url: 寫入Data的文件URL
    ///   - data: 要寫入的資料
    /// - Returns: Bool
    func _writeData(to url: URL?, data: Data?) -> Result<Bool, Error> {
        
        guard let url = url,
              let data = data
        else {
            return .success(false)
        }
        
        do {
            try data.write(to: url)
            return .success(true)
        } catch {
            return .failure(error)
        }
    }
        
    /// 新增資料夾
    /// - Parameters:
    ///   - url: 基本資料夾位置
    ///   - path: 資料夾名稱
    /// - Throws: 會丟出錯誤
    /// - Returns: Bool
    func _createDirectory(with url: URL?) throws -> Bool {
        
        guard let url = url else { return false }
        
        try createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        return true
    }
    
    /// 移除檔案
    /// - Parameter atURL: URL
    func _removeFile(at atURL: URL?) -> Result<Bool, Error> {
        
        guard let atURL = atURL else { return .success(false) }
        
        do {
            try removeItem(at: atURL)
            return .success(true)
        } catch  {
            return .failure(error)
        }
    }
    
    /// [讀取資料夾 / 檔案名稱的列表](https://blog.csdn.net/pk_20140716/article/details/54925418)
    /// - ["1.png", "Demo"])
    /// - Parameter url: 要讀取的資料夾路徑
    /// - Returns: [String]?
    func _fileList(with url: URL?) -> Result<[String]?, Error> {
        
        guard let path = url?.path else { return .success(nil) }
        
        do {
            let fileList = try contentsOfDirectory(atPath: path)
            return .success(fileList)
        } catch  {
            return .failure(error)
        }
    }
    
    /// 取得檔案的相關屬性值
    /// - Parameter url: URL?
    /// - Returns: Result<[FileAttributeKey : Any]?, Error>
    func _fileAttributes(at url: URL?) -> Result<[FileAttributeKey : Any]?, Error> {
        
        guard let url = url else { return .success(nil) }
        
        do {
            let attributes = try attributesOfItem(atPath: url.path)
            return .success(attributes)
        } catch {
            return .failure(error)
        }
    }
    
    /// 取得檔案大小
    /// - Parameter url: URL?
    /// - Returns: Result<Int64?, Error>
    func _fileSize(at url: URL?) -> Result<Int64?, Error> {
        
        let result = _fileAttributes(at: url)
        
        switch result {
        case .failure(let error): return .failure(error)
        case .success(let dictionary): return .success(dictionary?[.size] as? Int64)
        }
    }
    
    /// 該目錄的檔案總大小 (不含子目錄)
    /// - Parameter url: URL?
    /// - Returns: Result<Int64, Error>
    func _fileTotalSize(with url: URL?) -> Result<WWWebImage.Constant.FileSizeInfomation, Error> {
        
        let listResult = self._fileSizeList(with: url)
        
        switch listResult {
        case .failure(let error): return .failure(error)
        case .success(let list):
            
            guard let list = list else { return .success((0, 0)) }
            
            let totalSize = list.reduce(0) { return $0 + $1.fileSize }
            return .success((list.count, totalSize))
        }
    }
    
    /// 該目錄的檔案大小列表 (不含子目錄)
    /// - Parameter url: URL?
    /// - Returns: Result<[FileSizeList]?, Error>
    func _fileSizeList(with url: URL?) -> Result<[WWWebImage.Constant.FileSizeList]?, Error> {
        
        let result = FileManager.default._fileList(with: url)
        
        switch result {
        case .failure(let error): return .failure(error)
        case .success(let list):
            
            guard let list = list?.sorted() else { return .success(nil) }
            
            let fileSizeList = list.compactMap({ filename -> WWWebImage.Constant.FileSizeList? in

                guard let fullPath = url?.appendingPathComponent(filename),
                      let fileSize = try? FileManager.default._fileSize(at: fullPath).get()
                else {
                    return nil
                }
                
                return (filename: filename, fileSize: fileSize)
            })
            
            return .success(fileSizeList)
        }
    }
}

// MARK: - UIView (static function)
extension UIView {
    
    /// UIView動畫開關 => UITableViewCell的更新動畫…
    /// - Parameter enabled: 開 / 關
    static func _animationsEnabled(enabled: Bool) { Self.setAnimationsEnabled(enabled) }
}

// MARK: - UIImage (class function)
extension UIImage {
    
    /// 依照比例縮放圖片
    /// - Parameters:
    ///   - mark: 以寬度 / 高度為準
    ///   - number: 要多寬 / 多高
    /// - Returns: UIImage
    func _scaled(for mark: WWWebImage.Constant.SizeMark) -> UIImage {

        switch mark {
        case .height(let number): return _scaled(toHeight: number)
        case .width(let number): return _scaled(toWidth: number)
        }
    }
}

// MARK: - UIImage (private class function)
extension UIImage {

    /// 依照比例縮放圖片
    /// - 以寬度為準
    /// - Parameter width: 寬度大小
    /// - Returns: UIImage
    private func _scaled(toWidth width: CGFloat) -> UIImage {
        
        let scale = width / size.width
        let newSize = CGSize(width: width, height: size.height * scale)
        let newImage = _resized(for: newSize)
        
        return newImage
    }
    
    /// 依照比例縮放圖片
    /// - 以高度為準
    /// - Parameter height: 高度大小
    /// - Returns: UIImage
    private func _scaled(toHeight height: CGFloat) -> UIImage {
        
        let scale = height / size.height
        let newSize = CGSize(width: size.width * scale, height: height)
        let newImage = _resized(for: newSize)
        
        return newImage
    }
    
    /// 改變圖片大小
    /// - Parameter size: 設定的大小
    /// - Returns: UIImage
    private func _resized(for size: CGSize) -> UIImage {

        let renderer = UIGraphicsImageRenderer(size: size)
        let resizeImage = renderer.image { (context) in draw(in: renderer.format.bounds) }
        
        return resizeImage
    }
}

// MARK: - UIView (class function)
extension UIView {
    
    /// [尋找該View的上層為該類型的View -> superview](https://stackoverflow.com/questions/15711645/how-to-get-uitableview-from-uitableviewcell)
    /// - Returns: T?
    func _parentView<T: UIView>(of type: T.Type) -> T? {
        guard let view = superview else { return nil }
        return (view as? T) ?? view._parentView(of: T.self)
    }
}
