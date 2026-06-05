//
//  ImageCell.swift
//  Example
//
//  Created by William.Weng on 2026/6/5.
//

import UIKit

// MARK: - 圖片 Cell
final class ImageCell: UITableViewCell {
    
    @IBOutlet weak var myImageView: UIImageView!
    
    static let identifier = "ImageCell"
        
    override func prepareForReuse() {
        super.prepareForReuse()
        
        myImageView.ww.cancel()
        myImageView.image = nil
    }
    
    func configure(with imageUrl: String) {
        Task { try await myImageView.ww.download(urlString: imageUrl) }
    }
}
