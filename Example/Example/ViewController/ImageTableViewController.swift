//
//  ImageTableViewController.swift
//  Example
//
//  Created by William.Weng on 2026/6/5.
//

import UIKit
import WWWebImage

// MARK: - TableView Controller
final class ImageTableViewController: UITableViewController {
    
    private let imageUrls = [
        "https://api.cosmopolitan.com.hk/var/site/storage/images/_aliases/img_730w/2/3/1/8/7618132-1-chi-HK/1.jpg",
        "https://pbs.twimg.com/media/Evk1PiMVIAIOhtR?format=jpg&name=medium",
        "https://meet.eslite.com/CMS/Files/@M091/2024-11/2024_chiikawa/003_chiikawa.jpg",
        "https://meet.eslite.com/CMS/Files/@M091/2024-11/2024_chiikawa/001_chiikawa.jpg",
        "https://hips.hearstapps.com/hmg-prod/images/clipdown-app-333226746-761742381720284-1594220155962536035-n-6728a7fb848f6.jpg?crop=0.679xw:1.00xh;0.156xw,0&resize=1200:*",
        "https://api.cosmopolitan.com.hk/var/site/storage/images/_aliases/img_730w/2/0/4/8/7618402-1-chi-HK/2.jpg",
        "https://shoplineimg.com/media/663c6333a1cc270011604bc1/original.webp?source_format=jpg",
        "https://api.esquirehk.com/var/site/storage/images/_aliases/img_804_w/4/5/6/2/6152654-1-chi-HK/Untitled-2.jpg"
    ]
    
    private var tripledUrls: [String] { (0..<3).flatMap { _ in self.imageUrls } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 200
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tripledUrls.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ImageCell.identifier, for: indexPath) as! ImageCell
        let imageUrl = tripledUrls[indexPath.row]
        
        cell.configure(with: imageUrl)
        
        return cell
    }
}
