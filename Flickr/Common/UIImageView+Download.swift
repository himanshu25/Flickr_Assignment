//
//  UIImageView+download.swift
//  Flickr
//
//  Created by Himanshu on 04/04/18.
//  Copyright © 2018 Himanshu. All rights reserved.
//

import Foundation

// Using it for caching, we can invalidate it when we want or if don't want to use it then go for SDWebImage

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        self.image = UIImage(named: "placeholder")
        ImageDownloader.sharedInstance.downloadedFrom(url: url) { (image) in
            FlickrManager.imageURLDict[url.absoluteString] = image
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
}
