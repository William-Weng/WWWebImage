//
//  WWWebImage.swift
//  Example
//
//  Created by William.Weng on 2026/6/5.
//

import UIKit
import WWCacheManager

public class WWWebImage {
    static let cacheManager = WWCacheManager<String, UIImage>()
}

public extension WWWebImage {
    protocol `Protocol`: UIImageView {}
}

extension WWWebImage.`Protocol` {
    public var ww: WWWebImage.Wrapper<Self> { return WWWebImage.Wrapper(self) }
}

extension UIImageView: WWWebImage.`Protocol` {}
