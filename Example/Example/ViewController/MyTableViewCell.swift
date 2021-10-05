//
//  MyTableViewCell.swift
//  Example
//
//  Created by William.Weng on 2021/10/04.
//

import UIKit
import WWPrint
import WWWebImage

final class MyTableViewCell: UITableViewCell {

    static let ImageUrlInfos: [String] = UIImage._randomUrlString(with: 20)
    
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var myLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        myImageView.image = nil
    }
    
    /// 畫面相關設定
    /// - Parameter indexPath: IndexPath
    func configure(with indexPath: IndexPath) {
        
        let urlString = Self.ImageUrlInfos[indexPath.row]
        
        myLabel.text = "\(indexPath.row)"
        
        myImageView.ww.downloadImage(with: urlString) { result in
            switch result {
            case .failure(let error): wwPrint(error)
            case .success(let info): wwPrint(info)
            }
        }
    }
}

// MARK: - UIImage (class function)
extension UIImage {
    
    /// [產生隨機的小圖片](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/collection-view-table-view-的網路圖片顯示問題-e83c5ca487c8)
    /// - https://via.placeholder.com/200/8C61ED
    /// - Parameter count: 圖片數量
    /// - Parameter size: 圖片大小
    /// - Parameter placeholderUrl: 圖片網址
    /// - Returns: [String]?
    static func _randomUrlString(with count: UInt = 10, size: UInt = 200, placeholderUrl: String = "https://via.placeholder.com") -> [String] {
        
        let photoUrls = (1...count).map { number -> String in
            
            let rgb = (1...3).reduce("") { result, _ in
                result.appending(String(Int.random(in: 0...255), radix: 16, uppercase: true))
            }
            
            return "\(placeholderUrl)/\(size)/\(rgb)"
        }

        return photoUrls
    }
}
