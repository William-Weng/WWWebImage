//
//  TableViewDemoController.swift
//  Example
//
//  Created by William.Weng on 2021/10/04.
//

import UIKit
import WWWebImage
import WWPrint

final class TableViewDemoController: UIViewController {

    @IBOutlet weak var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTableView.delegate = self
        myTableView.dataSource = self
        
        WWWebImage.configure(maximumCache: 1_000_000, compressionQuality: 0.8, sizeMark: .width(128))
    }
}

extension TableViewDemoController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MyTableViewCell.ImageUrlInfos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyTableViewCell", for: indexPath) as! MyTableViewCell
        cell.configure(with: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let result = WWWebImage.cachesDirectorySize()
        
        switch result {
        case .failure(let error): wwPrint(error)
        case .success(let info): wwPrint(info)
        }
    }
}
