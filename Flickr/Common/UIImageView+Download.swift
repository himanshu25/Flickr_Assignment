//
//  UIImageView+download.swift
//  Flickr
//
//  Created by Himanshu on 04/04/18.
//  Copyright © 2018 Himanshu. All rights reserved.
//

import Foundation

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
