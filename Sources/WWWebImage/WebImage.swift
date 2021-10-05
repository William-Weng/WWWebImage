//
//  WebImageWrapper.swift
//  WWWebImage
//
//  Created by William.Weng on 2021/10/1.
//

import UIKit
import WWPrint
import WWNetworking

private var lastIdentifier: Void?

// MARK: - WWWebImage (class function)
open class WWWebImage {
    
    public class Constant: NSObject {}
    
    /// [基本參數設定](https://www.jianshu.com/p/4e69bc24795d)
    /// - Parameters:
    ///   - maximumCache: [最大的快取大小](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/防止重覆利用的-cell-顯示之前的照片-e2671b1a120b)
    ///   - compressionQuality: [圖片壓縮率](https://www.jianshu.com/p/774329cd4bc2)
    ///   - sizeMark: [圖片等比縮放大小](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/collection-view-table-view-的網路圖片顯示問題-e83c5ca487c8)
    public static func configure(maximumCache: Int64 = 1_000_000_000, compressionQuality: CGFloat = 1.0, sizeMark: WWWebImage.Constant.SizeMark? = nil) {
        ImageCacheManager.maximumCache = maximumCache
        ImageCacheManager.compressionQuality = compressionQuality
        ImageCacheManager.sizeMark = sizeMark
    }
    
    /// 取得Cache資料夾的大小
    /// - Returns: Result<Int64, Error>
    public static func cachesDirectorySize() -> Result<WWWebImage.Constant.FileSizeInfomation, Error> {
        return ImageCacheManager.shared.cachesDirectorySize()
    }
}

// MARK: - UIImageView (class function)
extension UIImageView {
    var identifier: String? { get { return objc_getAssociatedObject(self, &lastIdentifier) as? String }}
    func setIdentifier(_ urlString: String) { objc_setAssociatedObject(self, &lastIdentifier, urlString, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
}

// MARK: - WWWebImageWrapper (class function)
open class WWWebImageWrapper<T: UIImageView> {
    
    private var myImageView: T
    
    public init(_ imageView: T) { self.myImageView = imageView }
    
    /// 下載圖片
    /// - Parameters:
    ///   - urlString: String
    ///   - result: Result<ImageViewUpdateInformation?, Error>
    public func downloadImage(with urlString: String, result: @escaping ((Result<WWWebImage.Constant.ImageViewUpdateInformation?, Error>) -> Void)) {
        
        myImageView.setIdentifier(urlString)
        
        if let downloadedImage = ImageCacheManager.shared.cacheImage(with: urlString) {
            DispatchQueue.main.async { self.myImageView.image = downloadedImage }; return
        }
        
        guard !ImageCacheManager.shared.imageUrlInfoSet.contains(urlString) else { return }
        ImageCacheManager.shared.imageUrlInfoSet.insert(urlString)
        
        _ = WWNetworking().download(urlString: urlString, delegateQueue: nil, progress: { info in
            // FIXME: - 下一版再處理
        
        }, completion: { _result in
            
            switch _result {
            case .failure(let error):
                
                ImageCacheManager.shared.imageUrlInfoSet.remove(urlString)
                result(.failure(error))
            
            case .success(let info):
                
                guard let imageData = info.data,
                      let downloadedImage = UIImage(data: imageData)
                else {
                    ImageCacheManager.shared.imageUrlInfoSet.remove(urlString)
                    result(.failure(WWWebImage.Constant.MyError.notImage)); return
                }
                
                _ = ImageCacheManager.shared.storeCacheImage(downloadedImage, forKey: urlString)
                DispatchQueue.main.async { result(.success(self.imageViewUpdate(forKey: urlString))) }
            }
        })
    }
}

// MARK: - WWWebImageWrapper (private class function)
extension WWWebImageWrapper {
    
    /// UIImageView更新
    /// - Parameter identifier: String
    /// - Returns: ImageViewUpdateInformation
    private func imageViewUpdate(forKey identifier: String) -> WWWebImage.Constant.ImageViewUpdateInformation {
        
        let identifier = self.imageViewGeneralUpdate(forKey: identifier)
        let superViewType = self.imageViewExtraUpdate()
        
        return (identifier, superViewType)
    }
    
    /// 更新ImageView => 一般型
    /// - Parameter identifier: String
    /// - Returns: String
    private func imageViewGeneralUpdate(forKey identifier: String) -> String? {
        
        guard identifier == self.myImageView.identifier,
              let downloadedImage = ImageCacheManager.shared.cacheImage(with: identifier)
        else {
            return nil
        }
        
        self.myImageView.image = downloadedImage
        
        return identifier
    }
    
    /// 更新ImageView => 針對其它型別的加強處理
    /// - Returns: SuperViewType
    private func imageViewExtraUpdate() -> WWWebImage.Constant.SuperViewType {
        if (self.myImageView._parentView(of: UITableViewCell.self) != nil) { return extraUpdateForTableViewCell() }
        return .none
    }
    
    /// 更新ImageView => 針對UITableView上的UIImageView做加強處理
    /// - Returns: SuperViewType
    private func extraUpdateForTableViewCell() -> WWWebImage.Constant.SuperViewType {
        
        guard let cell = self.myImageView._parentView(of: UITableViewCell.self),
              let tableView = cell._parentView(of: UITableView.self),
              let indexPath = tableView.indexPath(for: cell)
        else {
            return .none
        }
        
        UIView._animationsEnabled(enabled: false)
        tableView.reloadRows(at: [indexPath], with: .none)
        UIView._animationsEnabled(enabled: true)

        return .tableViewCell
    }
}

