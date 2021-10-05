//
//  Constant.swift
//  WWWebImage
//
//  Created by William.Weng on 2021/10/4.
//

import UIKit

public protocol WWWebImageProtocol: UIImageView {}

extension WWWebImageProtocol {
    public var ww: WWWebImageWrapper<Self> { return WWWebImageWrapper(self) }
}

extension UIImageView: WWWebImageProtocol {}

public extension WWWebImage.Constant {
    
    typealias FileInfomation = (isExist: Bool, isDirectory: Bool)                                   // 檔案相關資訊
    typealias FileSizeInfomation = (count: Int, size: Int64)                                        // 檔案數量 / 大小
    typealias FileSizeList = (filename: String, fileSize: Int64)                                    // 檔案大小相關資訊 (檔案名稱 / 檔案大小)
    typealias ImageViewUpdateInformation = (identifier: String?, superViewType: SuperViewType)      // UIImageView的Key / SuperView的類型
    
    enum SizeMark {
        case width(_ number: CGFloat)
        case height(_ number: CGFloat)
    }
    
    enum MyError: Error {
        case unknown
        case notImage
    }
    
    enum SuperViewType {
        case none
        case tableViewCell
    }
}
